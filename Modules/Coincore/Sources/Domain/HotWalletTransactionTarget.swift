// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit

/**
 An TransactionTarget for the hot wallet, encapsulating the hot wallet address
 and an address for which a resulting transaction should be attributed to.

 - Parameter realAddress: Single that emits a tuple with the destination address (`destination`) and the reference address
 (`referenceAddress`) for the current `transactionTarget`.

 When sending a transaction to one of Blockchain's custodial products, we check if a hot wallet address for that product
 is available. If that is not available, reference address is null and the transaction happens as it normally would. If it is available,
 we will send the fund directly to the hot wallet address, and then attribute the transaction to the original address (real address) in a predefined way.
 You can check how this works and the reasons for its implementation here:
 https://www.notion.so/blockchaincom/Up-to-75-cheaper-EVM-wallet-private-key-to-custody-transfers-9675695a02ec49b893af1095ead6cc07
 */
public struct HotWalletTransactionTarget: TransactionTarget {
    public var label: String {
        realAddress.label
    }

    public var assetName: String {
        realAddress.assetName
    }

    public var currencyType: CurrencyType {
        realAddress.currencyType
    }

    public var accountType: AccountType = .trading

    /// The address for which the resulting transaction should be attributed to.
    public var realAddress: CryptoReceiveAddress
    /// The Hot Wallet address, where the transaction should be sent.
    public var hotWalletAddress: CryptoReceiveAddress

    public init(realAddress: CryptoReceiveAddress, hotWalletAddress: CryptoReceiveAddress) {
        self.realAddress = realAddress
        self.hotWalletAddress = hotWalletAddress
    }
}
