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
             .stakingDeposit:
            return Single.just(sourceAccount)
                .flatMap(weak: self) { (self, account) -> Single<[SingleAccount]> in
                    self.coincore
                        .getTransactionTargets(
                            sourceAccount: account,
                            action: action
                        )
                        .asSingle()
                }
        case .deposit:
            return linkedBanksFactory.nonWireTransferBanks.map { $0.map { $0 as SingleAccount } }
        case .withdraw:
            return linkedBanksFactory.linkedBanks.map { $0.map { $0 as SingleAccount } }
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
        account: BlockchainAccount
    ) -> Single<Result<ReceiveAddress, Error>> {
        guard let crypto = account as? CryptoAccount else {
            fatalError("You cannot validate an address using this account type: \(account)")
        }
        let asset = coincore[crypto.asset]
        return asset
            .parse(address: address)
            .flatMap { [validate] validatedAddress
                -> AnyPublisher<Result<ReceiveAddress, Error>, Never> in
                guard let validatedAddress else {
                    return validate(address, crypto.asset)
                }
                return .just(.success(validatedAddress))
            }
            .asSingle()
    }

    private func validate(
        domainName: String,
        currency: CryptoCurrency
    ) -> AnyPublisher<Result<ReceiveAddress, Error>, Never> {
        nameResolutionService
            .validate(domainName: domainName, currency: currency)
            .map { receiveAddress -> Result<ReceiveAddress, Error> in
                switch receiveAddress {
                case .some(let receiveAddress):
                    return .success(receiveAddress)
                case .none:
                    return .failure(CryptoAssetError.addressParseFailure)
                }
            }
            .handleEvents(receiveOutput: { [analyticsRecorder] _ in
                analyticsRecorder.record(event: AnalyticsEvents.New.Send.sendDomainResolved)
            })
            .eraseToAnyPublisher()
    }
}
