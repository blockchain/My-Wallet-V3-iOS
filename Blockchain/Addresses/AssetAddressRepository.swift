//
//  AssetAddressRepository.swift
//  Blockchain
//
//  Created by Chris Arriola on 5/22/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Repository for asset addresses
@objc class AssetAddressRepository: NSObject {

    static let shared = AssetAddressRepository()

    /// Accessor for obj-c compatibility
    @objc class func sharedInstance() -> AssetAddressRepository { return shared }

    private let walletManager: WalletManager

    init(walletManager: WalletManager = WalletManager.shared) {
        self.walletManager = walletManager
        super.init()
        self.walletManager.swipeAddressDelegate = self
    }

    // TODO: move latest multiaddress response here

    /// Fetches the swipe to receive addresses for all assets if possible
    func fetchSwipeToReceiveAddressesIfNeeded() {

        // Perform guard checks
        let appSettings = BlockchainSettings.App.shared
        guard appSettings.swipeToReceiveEnabled else {
            print("Swipe to receive is disabled.")
            return
        }

        let wallet = walletManager.wallet

        guard wallet.isInitialized() else {
            print("Wallet is not yet initialized.")
            return
        }

        guard wallet.didUpgradeToHd() else {
            print("Wallet has not yet been upgraded to HD.")
            return
        }

        // Only one address for ethereum
        appSettings.swipeAddressForEther = wallet.getEtherAddress()

        // Retrieve swipe addresses for bitcoin and bitcoin cash
        let assetTypesWithHDAddresses = [AssetType.bitcoin, AssetType.bitcoinCash]
        assetTypesWithHDAddresses.forEach {
            let swipeAddresses = swipeToReceiveAddresses(for: $0)
            let numberOfAddressesToDerive = Constants.Wallet.swipeToReceiveAddressCount - swipeAddresses.count
            if numberOfAddressesToDerive > 0 {
                wallet.getSwipeAddresses(Int32(numberOfAddressesToDerive), assetType: $0.legacy)
            }
        }
    }

    /// Gets the swipe addresses for the provided asset type
    ///
    /// - Parameter assetType: the AssetType
    /// - Returns: the swipe addresses
    @objc func swipeToReceiveAddresses(for assetType: AssetType) -> [String] {
        if assetType == .ethereum {
            if let swipeAddressForEther = BlockchainSettings.App.shared.swipeAddressForEther {
                return [swipeAddressForEther]
            } else {
                return []
            }
        }

        return KeychainItemWrapper.getSwipeAddresses(for: assetType.legacy) as? [String] ?? []
    }

    /// Removes the first swipe address for assetType.
    ///
    /// - Parameter assetType: the AssetType
    @objc func removeFirstSwipeAddress(for assetType: AssetType) {
        KeychainItemWrapper.removeFirstSwipeAddress(for: assetType.legacy)
    }

    /// Removes all swipe addresses for all assets
    @objc func removeAllSwipeAddresses() {
        KeychainItemWrapper.removeAllSwipeAddresses()
    }

    /// removes all swipe addresses for the provided AssetType
    ///
    /// - Parameter assetType: the AssetType
    @objc func removeAllSwipeAddresses(for assetType: AssetType) {
        KeychainItemWrapper.removeAllSwipeAddresses(for: assetType.legacy)
    }
}

extension AssetAddressRepository: WalletSwipeAddressDelegate {
    func onRetrievedSwipeToReceive(addresses: [String], assetType: AssetType) {
        addresses.forEach {
            KeychainItemWrapper.addSwipeAddress($0, assetType: assetType.legacy)
        }
    }
}
