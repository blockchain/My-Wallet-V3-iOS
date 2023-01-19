// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import MoneyKit

extension CryptoCurrency {
    private typealias LocalizedString = LocalizationConstants.Account

    public var defaultInterestWalletName: String {
        LocalizedString.myInterestWallet
    }

    public var defaultStakingWalletName: String {
        LocalizedString.myStakingWallet
    }

    public var defaultActiveRewardsWalletName: String {
        LocalizedString.myActiveRewardsWallet
    }

    public var defaultTradingWalletName: String {
        LocalizedString.myTradingAccount
    }

    public var defaultWalletName: String {
        LocalizedString.myWallet
    }

    public var defaultExchangeWalletName: String {
        LocalizedString.myExchangeAccount
    }
}

extension FiatCurrency {
    private typealias LocalizedString = LocalizationConstants.Account

    public var defaultWalletName: String {
        name
    }
}
