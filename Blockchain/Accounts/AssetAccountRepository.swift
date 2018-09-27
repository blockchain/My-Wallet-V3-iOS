//
//  AssetAccountRepository.swift
//  Blockchain
//
//  Created by Chris Arriola on 9/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// A repository for `AssetAccount` objects
class AssetAccountRepository {

    static let shared = AssetAccountRepository()

    private let wallet: Wallet

    init(wallet: Wallet = WalletManager.shared.wallet) {
        self.wallet = wallet
    }

    // MARK: Public Methods

    func accounts(for assetType: AssetType) -> [AssetAccount] {

        // A crash occurs in the for loop if wallet.getActiveAccountsCount returns 0
        // "Fatal error: Can't form Range with upperBound < lowerBound"
        if !wallet.isInitialized() {
            return []
        }

        // Handle ethereum
        if assetType == .ethereum {
            if let ethereumAccount = defaultEthereumAccount() {
                return [ethereumAccount]
            }
            return []
        }

        // Handle BTC and BCH
        // TODO pull in legacy addresses.
        // TICKET: IOS-1290
        var accounts: [AssetAccount] = []
        for index in 0...wallet.getActiveAccountsCount(assetType.legacy)-1 {
            let index = wallet.getIndexOfActiveAccount(index, assetType: assetType.legacy)
            if let assetAccount = AssetAccount.create(assetType: assetType, index: index, wallet: wallet) {
                accounts.append(assetAccount)
            }
        }
        return accounts
    }

    func allAccounts() -> [AssetAccount] {
        var allAccounts: [AssetAccount] = []
        AssetType.all.forEach {
            allAccounts.append(contentsOf: accounts(for: $0))
        }
        return allAccounts
    }

    func defaultAccount(for assetType: AssetType) -> AssetAccount? {
        if assetType == .ethereum {
            return defaultEthereumAccount()
        }
        let index = wallet.getDefaultAccountIndex(for: assetType.legacy)
        return AssetAccount.create(assetType: assetType, index: index, wallet: wallet)
    }

    func defaultEthereumAccount() -> AssetAccount? {
        guard let ethereumAddress = wallet.getEtherAddress(), wallet.hasEthAccount() else {
            Logger.shared.debug("This wallet has no ethereum address.")
            return nil
        }

        let ethBalance: Decimal
        if let ethStringBalance = wallet.getEthBalance() {
            ethBalance = Decimal(string: ethStringBalance) ?? Decimal(0)
        } else {
            ethBalance = 0
        }

        return AssetAccount(
            index: 0,
            address: AssetAddressFactory.create(fromAddressString: ethereumAddress, assetType: .ethereum),
            balance: ethBalance,
            name: LocalizationConstants.myEtherWallet
        )
    }
}

extension AssetAccount {

    /// Creates a new AssetAccount. This method only supports creating an AssetAccount for
    /// BTC or BCH. For ETH, use `defaultEthereumAccount`.
    static func create(assetType: AssetType, index: Int32, wallet: Wallet) -> AssetAccount? {
        guard let address = wallet.getReceiveAddress(forAccount: index, assetType: assetType.legacy) else {
            return nil
        }
        let name = wallet.getLabelForAccount(index, assetType: assetType.legacy)
        let balanceFromWalletObject = wallet.getBalanceForAccount(index, assetType: assetType.legacy)
        let balance: Decimal
        if assetType == .bitcoin || assetType == .bitcoinCash {
            let balanceLong = balanceFromWalletObject as? CUnsignedLongLong ?? 0
            balance = Decimal(balanceLong) / Decimal(Constants.Conversions.satoshi)
        } else {
            let balanceString = balanceFromWalletObject as? String ?? "0"
            balance = NSDecimalNumber(string: balanceString).decimalValue
        }
        return AssetAccount(
            index: index,
            address: AssetAddressFactory.create(fromAddressString: address, assetType: assetType),
            balance: balance,
            name: name ?? ""
        )
    }
}

extension AssetAccountRepository {
    func nameOfAccountContaining(address: String) -> String {
        let accounts = allAccounts()

        // TICKET: IOS-1326 - Destination Name on Exchange Locked Screen Should Match Withdrawal Address
        let destination = accounts.filter({
            return $0.address.address.lowercased() == address.lowercased()
        }).first
        return destination?.name ?? ""
    }
}
