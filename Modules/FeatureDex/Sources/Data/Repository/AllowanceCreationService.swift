// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureDexDomain
import DelegatedSelfCustodyDomain
import Dependencies
import MoneyKit
import Combine
import Errors

public protocol AllowanceCreationServiceAPI {

    func buildAllowance(
        token: CryptoCurrency
    ) -> AnyPublisher<Result<DelegatedCustodyTransactionOutput, UX.Error>, Never>
}

final class AllowanceCreationService: AllowanceCreationServiceAPI {
    var service: DelegatedCustodyTransactionServiceAPI = DIKit.resolve()
    let currenciesService = EnabledCurrenciesService.default

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
            account: 0,
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
}

struct AllowanceCreationServiceDependencyKey: DependencyKey {
    static var liveValue: AllowanceCreationServiceAPI = AllowanceCreationService()

    static var previewValue: AllowanceCreationServiceAPI = AllowanceCreationServicePreview(result: .success(.preview))

    static var testValue: AllowanceCreationServiceAPI { previewValue }
}

extension DependencyValues {
    public var allowanceCreationService: AllowanceCreationServiceAPI {
        get { self[AllowanceCreationServiceDependencyKey.self] }
        set { self[AllowanceCreationServiceDependencyKey.self] = newValue }
    }
}

public final class AllowanceCreationServicePreview: AllowanceCreationServiceAPI {

    var result: Result<DelegatedCustodyTransactionOutput, UX.Error>?

    public init(result: Result<DelegatedCustodyTransactionOutput, UX.Error>?) {
        self.result = result
    }

    public func buildAllowance(
        token: CryptoCurrency
    ) -> AnyPublisher<Result<DelegatedCustodyTransactionOutput, UX.Error>, Never> {
        guard let result else {
            return .empty()
        }
        return .just(result)
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
