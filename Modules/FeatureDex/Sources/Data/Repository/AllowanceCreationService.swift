// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DelegatedSelfCustodyDomain
import Dependencies
import DIKit
import Errors
import FeatureDexDomain
import Foundation
import MoneyKit

public protocol AllowanceCreationServiceAPI {

    func buildAllowance(
        token: CryptoCurrency
    ) -> AnyPublisher<Result<DelegatedCustodyTransactionOutput, UX.Error>, Never>

    func signAndPush(
        token: CryptoCurrency,
        output: DelegatedCustodyTransactionOutput?
    ) -> AnyPublisher<Result<String, UX.Error>, Never>
}

final class AllowanceCreationService: AllowanceCreationServiceAPI {
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
            currency: token.code,
            destination: contractAddress,
            fee: .high,
            feeCurrency: network.nativeAsset.code,
            maxVerificationVersion: .v1,
            memo: "",
            type: .tokenApproval(spender: Constants.spender)
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

struct AllowanceCreationServiceDependencyKey: DependencyKey {
    static var liveValue: AllowanceCreationServiceAPI = AllowanceCreationService()

    static var previewValue: AllowanceCreationServiceAPI = AllowanceCreationServicePreview(
        buildAllowance: .success(.preview),
        signAndPush: .success("0x")
    )

    static var testValue: AllowanceCreationServiceAPI { previewValue }
}

extension DependencyValues {
    public var allowanceCreationService: AllowanceCreationServiceAPI {
        get { self[AllowanceCreationServiceDependencyKey.self] }
        set { self[AllowanceCreationServiceDependencyKey.self] = newValue }
    }
}

public final class AllowanceCreationServicePreview: AllowanceCreationServiceAPI {

    var buildAllowance: Result<DelegatedCustodyTransactionOutput, UX.Error>?
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
