//Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// I'm adding this special enum here so that we have access from most places where Localization module is imported.
/// This is a part of moving away from the term `Private Key Wallet` and replacing it with `DeFi Wallet` which we don't
/// want to translate.
public enum NonLocalizedConstants {

    /// Returns the string of `DeFi Wallet` which is not translated.
    public static let defiWalletTitle = "DeFi Wallet"

    public enum ExternalTradingMigration {}
    public enum Bakkt {
        public enum Checkout {}
    }
}

