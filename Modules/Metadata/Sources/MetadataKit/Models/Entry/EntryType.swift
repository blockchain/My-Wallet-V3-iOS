// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// The derivation index of each metadata entry currently in use.
///
/// The following entry indexes are reserved but deprecated:
/// -  `2`: `What's New`
/// -  `3`: `Buy/Sell`
/// -  `4`: `Contacts`
/// -  `6`: `Shapeshift`
/// -  `9`: `Lockbox`
///
public enum EntryType: Int32 {

    /// Second password node
    case root = -1

    /// Ethereum
    case ethereum = 5

    /// Bitcoin Cash
    case bitcoinCash = 7

    /// Bitcoin
    case bitcoin = 8

    /// Nabu User Credentials - **deprecated**
    case userCredentials = 10

    /// Stellar
    case stellar = 11

    /// Wallet Credentials - Used for wallet recovery
    case walletCredentials = 12

    /// WalletConnect - **deprecated**
    case walletConnect = 13

    /// Account Credentials for unified accounts
    case accountCredentials = 14
}
