// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import DIKit
import FeatureTransactionDomain
import MoneyKit
import PlatformKit
import RxSwift
import ToolKit

final class TargetSelectionInteractor {

    private let coincore: CoincoreAPI
    private let linkedBanksFactory: LinkedBanksFactoryAPI
    private let nameResolutionService: BlockchainNameResolutionServiceAPI
    private let analyticsRecorder: AnalyticsEventRecorderAPI

    init(
        coincore: CoincoreAPI = resolve(),
        nameResolutionService: BlockchainNameResolutionServiceAPI = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        linkedBanksFactory: LinkedBanksFactoryAPI = resolve()
    ) {
        self.coincore = coincore
        self.linkedBanksFactory = linkedBanksFactory
        self.nameResolutionService = nameResolutionService
        self.analyticsRecorder = analyticsRecorder
    }

    func getBitPayInvoiceTarget(
        data: String,
        asset: CryptoCurrency
    ) -> Single<BitPayInvoiceTarget> {
        BitPayInvoiceTarget
            .make(from: data, asset: asset)
            .asSingle()
    }

    func getAvailableTargetAccounts(
        sourceAccount: BlockchainAccount,
        action: AssetAction
    ) -> Single<[SingleAccount]> {
        switch action {
        case .swap,
             .send,
             .interestWithdraw,
             .interestTransfer,
             .stakingWithdraw,
             .stakingDeposit,
             .activeRewardsDeposit,
             .activeRewardsWithdraw:
            Single.just(sourceAccount)
                .flatMap(weak: self) { (self, account) -> Single<[SingleAccount]> in
                    self.coincore
                        .getTransactionTargets(
                            sourceAccount: account,
                            action: action
                        )
                        .asSingle()
                }
        case .deposit:
            linkedBanksFactory.nonWireTransferBanks.map { $0.map { $0 as SingleAccount } }
        case .withdraw:
            linkedBanksFactory.linkedBanks.map { $0.map { $0 as SingleAccount } }
        case .sign,
             .receive,
             .buy,
             .sell,
             .viewActivity:
            unimplemented()
        }
    }

    func validateCrypto(
        address: String,
        memo: String?,
        account: BlockchainAccount
    ) -> Single<Result<ReceiveAddress, Error>> {
        guard let crypto = account as? CryptoAccount, let asset = coincore[crypto.asset] else {
            fatalError("You cannot validate an address using this account type: \(account)")
        }
        return asset
            .parse(address: address, memo: memo)
            .flatMap { [nameResolutionService, analyticsRecorder] validatedAddress
                -> AnyPublisher<Result<ReceiveAddress, Error>, Never> in
                guard let validatedAddress else {
                    return validateDomain(
                        service: nameResolutionService,
                        analyticsRecorder: analyticsRecorder,
                        domainName: address,
                        memo: memo,
                        currency: crypto.asset
                    )
                }
                return .just(.success(validatedAddress))
            }
            .asSingle()
    }
}

private func validateDomain(
    service: BlockchainNameResolutionServiceAPI,
    analyticsRecorder: AnalyticsEventRecorderAPI,
    domainName: String,
    memo: String?,
    currency: CryptoCurrency
) -> AnyPublisher<Result<ReceiveAddress, Error>, Never> {
    service
        .validate(domainName: domainName, memo: memo, currency: currency)
        .map { receiveAddress -> Result<ReceiveAddress, Error> in
            switch receiveAddress {
            case .some(let receiveAddress):
                .success(receiveAddress)
            case .none:
                .failure(CryptoAssetError.addressParseFailure)
            }
        }
        .handleEvents(receiveOutput: { [analyticsRecorder] _ in
            analyticsRecorder.record(event: AnalyticsEvents.New.Send.sendDomainResolved)
        })
        .eraseToAnyPublisher()
    }
