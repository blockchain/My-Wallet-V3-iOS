// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DelegatedSelfCustodyDomain
import Dependencies
import DIKit
import Errors
import FeatureDexDomain
import Foundation
import MoneyKit

public protocol TransactionCreationServiceAPI {

    func buildAllowance(
        token: CryptoCurrency
    ) -> AnyPublisher<Result<DelegatedCustodyTransactionOutput, UX.Error>, Never>

    func build(
        quote: DexQuoteOutput
    ) -> AnyPublisher<Result<DelegatedCustodyTransactionOutput, UX.Error>, Never>

    func signAndPush(
        token: CryptoCurrency,
        output: DelegatedCustodyTransactionOutput?
    ) -> AnyPublisher<Result<String, UX.Error>, Never>
}

final class TransactionCreationService: TransactionCreationServiceAPI {
    var service: DelegatedCustodyTransactionServiceAPI = DIKit.resolve()
    var privateKeyProvider: EVMPrivateKeyProviderAPI = DIKit.resolve()
    let currenciesService = EnabledCurrenciesService.default

    private let account: Int = 0

    func buildAllowance(
        token: CryptoCurrency
    ) -> AnyPublisher<Result<DelegatedCustodyTransactionOutput, UX.Error>, Never> {
        guard let contractAddress = token.assetModel.kind.erc20ContractAddress else {
            fatalError()
        }
        guard let network = currenciesService.network(for: token) else {
            fatalError()
        }
        let input = DelegatedCustodyTransactionInput(
            account: account,
            amount: .max,
            currency: network.nativeAsset.code,
            destination: contractAddress,
            fee: .normal,
            feeCurrency: network.nativeAsset.code,
            maxVerificationVersion: .v1,
            memo: "",
            type: .tokenApproval(spender: Constants.spender)
        )
        return service.buildTransaction(input)
            .mapError(UX.Error.init(error:))
            .result()
    }

    func build(
        quote: DexQuoteOutput
    ) -> AnyPublisher<Result<DelegatedCustodyTransactionOutput, UX.Error>, Never> {
        let currency = quote.sellAmount.currency
        guard let network = currenciesService.network(for: currency) else {
            fatalError()
        }
        let input = DelegatedCustodyTransactionInput(
            account: account,
            amount: nil,
            currency: network.nativeAsset.code,
            destination: quote.response.tx.to,
            fee: .normal,
            feeCurrency: network.nativeAsset.code,
            maxVerificationVersion: .v1,
            memo: "",
            type: .swap(
                data: quote.response.tx.data,
                gasLimit: quote.response.tx.gasLimit,
                value: quote.response.tx.value
            )
        )
        return service.buildTransaction(input)
            .mapError(UX.Error.init(error:))
            .result()
    }

    func signAndPush(
        token: CryptoCurrency,
        output: DelegatedCustodyTransactionOutput?
    ) -> AnyPublisher<Result<String, UX.Error>, Never> {
        guard let output else {
            fatalError()
        }
        return privateKeyProvider
            .privateKey(account: account)
            .flatMap { [service] privateKey in
                service.sign(output, privateKey: privateKey)
                    .publisher
                    .flatMap { signedOutput in
                        service.pushTransaction(signedOutput, currency: token)
                    }
                    .eraseError()
            }
            .mapError(UX.Error.init(error:))
            .result()
    }
}

public protocol EVMPrivateKeyProviderAPI {
    func privateKey(account: Int) -> AnyPublisher<Data, Error>
}

struct TransactionCreationServiceDependencyKey: DependencyKey {
    static var liveValue: TransactionCreationServiceAPI = TransactionCreationService()

    static var previewValue: TransactionCreationServiceAPI = TransactionCreationServicePreview(
        buildAllowance: .success(.preview),
        signAndPush: .success("0x")
    )

    static var testValue: TransactionCreationServiceAPI { previewValue }
}

extension DependencyValues {
    public var transactionCreationService: TransactionCreationServiceAPI {
        get { self[TransactionCreationServiceDependencyKey.self] }
        set { self[TransactionCreationServiceDependencyKey.self] = newValue }
    }
}

public final class TransactionCreationServicePreview: TransactionCreationServiceAPI {

    var buildAllowance: Result<DelegatedCustodyTransactionOutput, UX.Error>?
    var build: Result<DelegatedCustodyTransactionOutput, UX.Error>?
    var signAndPush: Result<String, UX.Error>?

    public init(
        buildAllowance: Result<DelegatedCustodyTransactionOutput, UX.Error>?,
        signAndPush: Result<String, UX.Error>?
    ) {
        self.buildAllowance = buildAllowance
        self.signAndPush = signAndPush
    }

    public func buildAllowance(
        token: CryptoCurrency
    ) -> AnyPublisher<Result<DelegatedCustodyTransactionOutput, UX.Error>, Never> {
        guard let buildAllowance else {
            return .empty()
        }
        return .just(buildAllowance)
    }

    public func build(
        quote: DexQuoteOutput
    ) -> AnyPublisher<Result<DelegatedCustodyTransactionOutput, UX.Error>, Never> {
        guard let build else {
            return .empty()
        }
        return .just(build)
    }

    public func signAndPush(
        token: CryptoCurrency,
        output: DelegatedCustodyTransactionOutput?
    ) -> AnyPublisher<Result<String, UX.Error>, Never> {
        guard let signAndPush else {
            return .empty()
        }
        return .just(signAndPush)
    }
}

extension DelegatedCustodyTransactionOutput {
    public static var preview: DelegatedCustodyTransactionOutput {
        .init(
            relativeFee: "0",
            absoluteFeeMaximum: "0",
            absoluteFeeEstimate: "31415926500000000",
            amount: "0",
            balance: "0",
            rawTx: .null,
            preImages: []
        )
    }
}
