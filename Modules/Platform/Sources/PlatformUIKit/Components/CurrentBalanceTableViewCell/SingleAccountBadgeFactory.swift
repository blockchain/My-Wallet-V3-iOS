// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitectureExtensions
import DIKit
import Localization
import PlatformKit
import RxSwift

public final class SingleAccountBadgeFactory {

    let withdrawalService: WithdrawalServiceAPI

    public init(withdrawalService: WithdrawalServiceAPI = resolve()) {
        self.withdrawalService = withdrawalService
    }

    public func badge(account: SingleAccount, action: AssetAction) -> Single<[BadgeAssetPresenting]> {
        switch action {
        case .swap:
            return swapBadges(account: account)
        case .withdraw:
            return withdrawBadges(account: account)
        default:
            return .just([])
        }
    }

    private func swapBadges(account: BlockchainAccount) -> Single<[BadgeAssetPresenting]> {
        if account is CryptoTradingAccount {
            let badges = [
                DefaultBadgeAssetPresenter.makeLowFeesBadge(),
                DefaultBadgeAssetPresenter.makeFasterBadge()
            ]
            return .just(badges)
        } else {
            return .just([])
        }
    }

    private func withdrawBadges(account: BlockchainAccount) -> Single<[BadgeAssetPresenting]> {
        guard let linkedBankAccount = account as? LinkedBankAccount else {
            fatalError("Expected a `LinkedBankAccount`")
        }
        return withdrawalService
            .withdrawFeeAndLimit(
                for: linkedBankAccount.fiatCurrency,
                paymentMethodType: linkedBankAccount.paymentType
            )
            .map { feeAndLimit -> [BadgeAssetPresenting] in
                let fee = feeAndLimit.fee
                let limit = feeAndLimit.minLimit

                let feeBadge: DefaultBadgeAssetPresenter
                if fee.isZero {
                    feeBadge = DefaultBadgeAssetPresenter.makeNoFeesBadge()
                } else {
                    feeBadge = DefaultBadgeAssetPresenter.makeWireFeeBadge()
                }

                let minLimitBadge: DefaultBadgeAssetPresenter?
                if limit.isZero {
                    minLimitBadge = nil
                } else {
                    minLimitBadge = DefaultBadgeAssetPresenter.makeMinWithdrawFeeBadge(amount: limit.displayString)
                }

                guard let min = minLimitBadge else {
                    return [feeBadge]
                }
                return [min, feeBadge]
            }
    }
}

extension DefaultBadgeAssetPresenter {
    private typealias LocalizedString = LocalizationConstants.Account
    private typealias BadgeItem = BadgeAsset.Value.Interaction.BadgeItem

    fileprivate static func makeNoFeesBadge() -> DefaultBadgeAssetPresenter {
        let item = BadgeItem(type: .verified, description: LocalizedString.noFees)
        let interactor = DefaultBadgeAssetInteractor(initialState: .loaded(next: item))
        return DefaultBadgeAssetPresenter(interactor: interactor)
    }

    fileprivate static func makeWireFeeBadge() -> DefaultBadgeAssetPresenter {
        let item = BadgeItem(type: .warning, description: LocalizedString.wireFee)
        let interactor = DefaultBadgeAssetInteractor(initialState: .loaded(next: item))
        return DefaultBadgeAssetPresenter(interactor: interactor)
    }

    fileprivate static func makeMinWithdrawFeeBadge(amount: String) -> DefaultBadgeAssetPresenter {
        let item = BadgeItem(
            type: .default(accessibilitySuffix: "minWithdraw"),
            description: "\(amount) \(LocalizedString.minWithdraw)"
        )
        let interactor = DefaultBadgeAssetInteractor(initialState: .loaded(next: item))
        return DefaultBadgeAssetPresenter(interactor: interactor)
    }

    static func makeLowFeesBadge() -> DefaultBadgeAssetPresenter {
        let item = BadgeItem(type: .verified, description: LocalizedString.lowFees)
        let interactor = DefaultBadgeAssetInteractor(initialState: .loaded(next: item))
        return DefaultBadgeAssetPresenter(interactor: interactor)
    }

    static func makeFasterBadge() -> DefaultBadgeAssetPresenter {
        let item = BadgeItem(type: .verified, description: LocalizedString.faster)
        let interactor = DefaultBadgeAssetInteractor(initialState: .loaded(next: item))
        return DefaultBadgeAssetPresenter(interactor: interactor)
    }
}
