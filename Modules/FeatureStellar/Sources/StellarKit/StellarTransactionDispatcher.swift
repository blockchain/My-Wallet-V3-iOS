// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import BigInt
import MoneyKit
import stellarsdk
import ToolKit

protocol StellarTransactionDispatcherAPI {

    func dryRunTransaction(sendDetails: SendDetails) -> AnyPublisher<Void, Error>

    func isAddressValid(address: String) -> Bool

    func sendFunds(sendDetails: SendDetails) -> AnyPublisher<SendConfirmationDetails, Error>
}

final class StellarTransactionDispatcher: StellarTransactionDispatcherAPI {

    // MARK: Types

    private typealias StellarTransaction = stellarsdk.Transaction

    // MARK: Private Properties

    private let accountRepository: StellarWalletAccountRepositoryAPI
    private let horizonProxy: HorizonProxyAPI
    private let app: AppProtocol
    private let minSend = CryptoValue.create(minor: 1, currency: .stellar)
    
    init(
        app: AppProtocol,
        accountRepository: StellarWalletAccountRepositoryAPI,
        horizonProxy: HorizonProxyAPI
    ) {
        self.app = app
        self.accountRepository = accountRepository
        self.horizonProxy = horizonProxy
    }

    // MARK: Methods

    func dryRunTransaction(sendDetails: SendDetails) -> AnyPublisher<Void, Error> {
        Deferred { () -> AnyPublisher<Void, Error> in
            do {
                try checkInput(sendDetails: sendDetails)
                try checkDestinationAddress(sendDetails: sendDetails)
            } catch {
                return .failure(error)
            }
            return self.checkDestinationAccount(sendDetails: sendDetails)
                .flatMap { self.checkSourceAccount(sendDetails: sendDetails) }
                .flatMap { self.transaction(sendDetails: sendDetails).mapToVoid() }
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    func isAddressValid(address: String) -> Bool {
        do {
            _ = try stellarsdk.KeyPair(accountId: address)
            return true
        } catch {
            return false
        }
    }

    func sendFunds(sendDetails: SendDetails) -> AnyPublisher<SendConfirmationDetails, Error> {
        keyPair.zip(transaction(sendDetails: sendDetails))
            .flatMap { [horizonProxy] keyPair, transaction -> AnyPublisher<TransactionPostResponseEnum, Error> in
                horizonProxy
                    .sign(transaction: transaction, keyPair: keyPair)
                    .flatMap { horizonProxy.submitTransaction(transaction: transaction) }
                    .eraseToAnyPublisher()
            }
            .tryMap { response -> SendConfirmationDetails in
                try response.toSendConfirmationDetails(sendDetails: sendDetails)
            }
            .eraseToAnyPublisher()
    }

    // MARK: Private Methods

    private var keyPair: AnyPublisher<stellarsdk.KeyPair, Error> {
        accountRepository.loadKeyPair()
            .tryMap { try stellarsdk.KeyPair(secretSeed: $0.privateKey.secret) }
            .eraseToAnyPublisher()
    }

    private func checkSourceAccount(sendDetails: SendDetails) -> AnyPublisher<Void, Error> {
        horizonProxy.accountResponse(for: sendDetails.fromAddress)
            .tryMap { response -> AccountResponse in
                let total = try sendDetails.value + sendDetails.fee
                let minBalance = stellarMinimumBalance(subentryCount: response.subentryCount)
                if try response.totalBalance < (total + minBalance) {
                    throw SendFailureReason.insufficientFunds(response.totalBalance.moneyValue, total.moneyValue)
                }
                return response
            }
            .mapToVoid()
    }

    private func checkDestinationAccount(sendDetails: SendDetails) -> AnyPublisher<Void, Error> {
        let minBalance = stellarMinimumBalance(subentryCount: 0)
        return horizonProxy.accountResponse(for: sendDetails.toAddress)
            .mapToVoid()
            .catch { stellarError -> AnyPublisher<Void, Error> in
                switch stellarError {
                case .notFound:
                    do {
                        if try sendDetails.value < minBalance {
                            return .failure(SendFailureReason.belowMinimumSendNewAccount(minBalance.moneyValue))
                        }
                        return .just(())
                    } catch {
                        return .failure(error)
                    }
                default:
                    return .failure(stellarError)
                }
            }
            .eraseError()
    }

    private func transaction(sendDetails: SendDetails) -> AnyPublisher<StellarTransaction, Error> {
        horizonProxy.accountResponse(for: sendDetails.fromAddress)
            .eraseError()
            .flatMap { sourceAccount -> AnyPublisher<StellarTransaction, Error> in
                guard sendDetails.value.currencyType == .stellar else {
                    return .failure(StellarKitError.illegalArgument)
                }
                guard sendDetails.fee.currencyType == .stellar else {
                  return .failure(StellarKitError.illegalArgument)
                }
                return self.createTransaction(sendDetails: sendDetails, sourceAccount: sourceAccount)
            }
            .eraseToAnyPublisher()
    }

    private var sendTimeOutSeconds: AnyPublisher<Int, Never> {
        app.publisher(for: blockchain.app.configuration.xlm.timeout, as: Int.self)
            .prefix(1)
            .map { $0.value ?? 600 }
            .eraseToAnyPublisher()
    }

    private func createTransaction(
        sendDetails: SendDetails,
        sourceAccount: AccountResponse
    ) -> AnyPublisher<StellarTransaction, Error> {
        operation(sendDetails: sendDetails)
            .zip(sendTimeOutSeconds.eraseError())
            .tryMap { operation, sendTimeOutSeconds -> StellarTransaction in
                var timeBounds: TimeBounds?
                let expirationDate = Calendar.current.date(
                    byAdding: .second,
                    value: sendTimeOutSeconds,
                    to: Date()
                )
                if let expirationDate = expirationDate?.timeIntervalSince1970 {
                    timeBounds = TimeBounds(
                        minTime: 0,
                        maxTime: UInt64(expirationDate)
                    )
                }
                let transaction = try StellarTransaction(
                    sourceAccount: sourceAccount,
                    operations: [operation],
                    memo: sendDetails.horizonMemo,
                    preconditions: TransactionPreconditions(timeBounds: timeBounds),
                    maxOperationFee: UInt32(sendDetails.fee.minorString)!
                )
                return transaction
            }
            .eraseToAnyPublisher()
    }

    /// Returns the appropriate operation depending if the destination account already exists or not.
    private func operation(sendDetails: SendDetails) -> AnyPublisher<stellarsdk.Operation, Error> {
        horizonProxy.accountResponse(for: sendDetails.toAddress)
            .tryMap { response -> stellarsdk.Operation in
                try stellarsdk.PaymentOperation(
                    sourceAccountId: sendDetails.fromAddress,
                    destinationAccountId: response.accountId,
                    asset: stellarsdk.Asset(type: stellarsdk.AssetType.ASSET_TYPE_NATIVE)!,
                    amount: sendDetails.value.displayMajorValue
                )
            }
            .catch { error -> AnyPublisher<stellarsdk.Operation, Error> in
                // Build operation
                switch error {
                case StellarNetworkError.notFound:
                    let destination: KeyPair
                    do { destination =  try KeyPair(accountId: sendDetails.toAddress) }
                    catch _ { return .failure(error) }
                    let createAccountOperation = stellarsdk.CreateAccountOperation(
                        sourceAccountId: sendDetails.fromAddress,
                        destination: destination,
                        startBalance: sendDetails.value.displayMajorValue
                    )
                    return .just(createAccountOperation)
                default:
                    return .failure(error)
                }
            }
            .eraseToAnyPublisher()
    }
}

private func checkInput(sendDetails: SendDetails) throws {
    guard sendDetails.value.currencyType == .stellar else {
        throw SendFailureReason.unknown
    }
    guard sendDetails.fee.currencyType == .stellar else {
        throw SendFailureReason.unknown
    }
}

private func checkDestinationAddress(sendDetails: SendDetails) throws {
    do { _ = try stellarsdk.KeyPair(accountId: sendDetails.toAddress) }
    catch { throw SendFailureReason.badDestinationAccountID }
}

extension stellarsdk.TransactionPostResponseEnum {
    fileprivate func toSendConfirmationDetails(sendDetails: SendDetails) throws -> SendConfirmationDetails {
        switch self {
        case .success(let details):
            let feeCharged = CryptoValue.create(
                minor: BigInt(details.transactionResult.feeCharged),
                currency: .stellar
            )
            return SendConfirmationDetails(
                sendDetails: sendDetails,
                fees: feeCharged,
                transactionHash: details.transactionHash
            )
        case .destinationRequiresMemo:
            throw StellarNetworkError.destinationRequiresMemo
        case .failure(let error):
            throw error.stellarNetworkError
        }
    }
}

extension SendDetails {
    fileprivate var horizonMemo: stellarsdk.Memo {
        guard let value = memo?.nilIfEmpty else {
            return .none
        }
        return .text(value)
    }
}
