//
//  CryptoCurrency+Account.swift
//  PlatformKit
//
//  Created by Paulo on 20/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization

extension CryptoCurrency {
    private typealias LocalizedString = LocalizationConstants.Account

    public var defaultInterestWalletName: String {
        LocalizedString.myInterestWallet
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
        LocalizedString.fiatAccount(displayCode)
    }
}
