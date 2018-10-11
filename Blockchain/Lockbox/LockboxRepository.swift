//
//  LockboxRepository.swift
//  Blockchain
//
//  Created by Chris Arriola on 9/28/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Repository for accessing `Lockbox` objects
class LockboxRepository {

    private let wallet: Wallet

    init(wallet: Wallet = WalletManager.shared.wallet) {
        self.wallet = wallet
    }

    /// Returns a list of `Lockbox` instances that have been synced with this
    /// Blockchain wallet.
    ///
    /// - Returns: the Lockbox instances
    func lockboxes() -> [Lockbox] {
        let lockboxDevicesRaw = wallet.getLockboxDevices()

        guard !lockboxDevicesRaw.isEmpty else {
            return []
        }

        let jsonDecoder = JSONDecoder()
        return lockboxDevicesRaw.compactMap {
            guard let jsonObj = $0 as? [String: Any] else {
                Logger.shared.warning("Failed to serialize lockbox dictionary.")
                return nil
            }

            guard let data = try? JSONSerialization.data(withJSONObject: jsonObj, options: []) else {
                Logger.shared.warning("Failed to serialize lockbox dictionary.")
                return nil
            }

            do {
                return try jsonDecoder.decode(Lockbox.self, from: data)
            } catch {
                Logger.shared.error("Failed to decode lockbox \(error)")
            }
            
            return nil
        }
    }
}
