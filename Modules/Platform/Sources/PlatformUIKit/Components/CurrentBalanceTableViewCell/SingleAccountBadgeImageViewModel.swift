// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Localization
import MoneyKit
import PlatformKit
import RxCocoa
import RxSwift
import ToolKit

public enum SingleAccountBadgeImageViewModel {

    private typealias AccessibilityId = Accessibility.Identifier.AccountPicker.AccountCell

    public static func badgeModel(
        account: SingleAccount
    ) -> BadgeImageViewModel {
        let model: BadgeImageViewModel = switch account.currencyType {
        case .fiat(let fiatCurrency):
            .primary(
                image: fiatCurrency.logoResource,
                contentColor: .semantic.background,
                backgroundColor: fiatCurrency.brandColor,
                accessibilityIdSuffix: AccessibilityId.badgeImageView
            )
        case .crypto(let cryptoCurrency):
            .default(
                image: cryptoCurrency.logoResource,
                cornerRadius: .round,
                accessibilityIdSuffix: AccessibilityId.badgeImageView
            )
        }
        model.marginOffsetRelay.accept(0)
        return model
    }

    public static func iconModel(
        account: SingleAccount,
        action: AssetAction,
        service: EnabledCurrenciesServiceAPI = EnabledCurrenciesService.default
    ) -> BadgeImageViewModel? {
        let model: BadgeImageViewModel
        switch account {
        case is BankAccount:
            model = .template(
                image: .local(name: "ic-trading-account", bundle: .platformUIKit),
                templateColor: account.currencyType.brandUIColor,
                backgroundColor: .red,
                cornerRadius: .round,
                accessibilityIdSuffix: ""
            )
        case is TradingAccount:
            if action == .send {
                return nil
            } else {
                model = .template(
                    image: .local(name: "ic-trading-account", bundle: .platformUIKit),
                    templateColor: account.currencyType.brandUIColor,
                    backgroundColor: .semantic.background,
                    cornerRadius: .round,
                    accessibilityIdSuffix: ""
                )
            }
        case is CryptoInterestAccount, is CryptoStakingAccount, is CryptoActiveRewardsAccount:
            model = .template(
                image: .local(name: "ic-interest-account", bundle: .platformUIKit),
                templateColor: account.currencyType.brandUIColor,
                backgroundColor: .semantic.background,
                cornerRadius: .round,
                accessibilityIdSuffix: ""
            )
        case is ExchangeAccount:
            model = .template(
                image: .local(name: "ic-exchange-account", bundle: .platformUIKit),
                templateColor: account.currencyType.brandUIColor,
                backgroundColor: .semantic.background,
                cornerRadius: .round,
                accessibilityIdSuffix: ""
            )
        case let account as CryptoNonCustodialAccount:
            if let network = service.network(for: account.asset) {
                model = .default(
                    image: network.logoResource,
                    backgroundColor: .semantic.background,
                    cornerRadius: .round,
                    accessibilityIdSuffix: ""
                )
            } else {
                model = .template(
                    image: .local(name: "ic-private-account", bundle: .platformUIKit),
                    templateColor: account.currencyType.brandUIColor,
                    backgroundColor: .semantic.background,
                    cornerRadius: .round,
                    accessibilityIdSuffix: ""
                )
            }
        case is FiatAccount:
            model = .template(
                image: .local(name: "ic-trading-account", bundle: .platformUIKit),
                templateColor: account.currencyType.brandUIColor,
                backgroundColor: .white,
                cornerRadius: .round,
                accessibilityIdSuffix: ""
            )
        default:
            return nil
        }
        model.marginOffsetRelay.accept(1)
        return model
    }
}
