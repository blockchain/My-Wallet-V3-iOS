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

        // Handle ethereum
        if assetType == .ethereum {
            if let ethereumAccount = defaultEthereumAccount() {
                return [ethereumAccount]
            }
            return []
        }

        // Handle BTC and BCH
        // TODO pull in legacy addresses
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
        let allTypes: [AssetType] = [.bitcoin, .ethereum, .bitcoinCash]
        allTypes.forEach {
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

    // MARK: Private Methods

    private func defaultEthereumAccount() -> AssetAccount? {
        guard let ethereumAddress = wallet.getEtherAddress(), wallet.hasEthAccount() else {
            Logger.shared.debug("This wallet has no ethereum address.")
            return nil
        }

        // TODO set balance
        let ethBalance = wallet.getEthBalance()
        Logger.shared.debug("Ethereum balance: '\(ethBalance ?? "0")'")

        return AssetAccount(
            index: 0,
            address: AssetAddressFactory.create(fromAddressString: ethereumAddress, assetType: .ethereum),
            balance: 0,
            name: LocalizationConstants.myEtherWallet
        )
    }
}

extension AssetAccount {

    static func create(assetType: AssetType, index: Int32, wallet: Wallet) -> AssetAccount? {
        guard let address = wallet.getReceiveAddress(forAccount: index, assetType: type.legacy) else {
            return nil
        }
        let name = wallet.getLabelForAccount(index, assetType: type.legacy)
        let balance = wallet.getBalanceForAccount(index, assetType: type.legacy) as? CLongLong ?? 0
        return AssetAccount(
            index: index,
            address: AssetAddressFactory.create(fromAddressString: address, assetType: type),
            balance: balance,
            name: name ?? ""
        )
    }
}
