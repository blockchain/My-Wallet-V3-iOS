//
//  WalletUpgradeService.swift
//  Blockchain
//
//  Created by Paulo on 17/03/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import RxSwift
import ToolKit

public protocol WalletUpgradeServicing {
    /// Indicates if the wallet needs any payload upgrade.
    /// Crashes if the wallet is not initalized.
    var needsWalletUpgrade: Bool { get }

    /// Upgrades the user wallet to the most recent version.
    /// Emits the current version being upgrade.
    /// Completes when the work is done.
    /// Errors when something went wrong.
    func upgradeWallet() -> Observable<String>
}

public protocol WalletUpgradingProvider {
    var walletUpgrading: WalletUpgradingAPI { get }
}

public protocol WalletUpgradingAPI {
    /// If the wallet is already initialized.
    func isInitialized() -> Bool

    /// If the Wallet is already a HD Wallet (V3+).
    func didUpgradeToHd() -> Bool
}

final class WalletUpgradeService: WalletUpgradeServicing {

    // MARK: Types

    enum PayloadVersion: String {
        case v3
    }

    enum WalletError: Error {
        case walletNotInitialized
    }

    // MARK: Private Properties

    private let errorRecorder: ErrorRecording
    private let walletUpgradeJSService: WalletUpgradeJSServicing
    private let walletProvider: WalletUpgradingProvider
    private var wallet: WalletUpgradingAPI {
        walletProvider.walletUpgrading
    }

    // MARK: Init

    init(walletProvider: WalletUpgradingProvider = resolve(),
         walletUpgradeJSService: WalletUpgradeJSServicing = resolve(),
         errorRecorder: ErrorRecording = resolve()) {
        self.walletProvider = walletProvider
        self.walletUpgradeJSService = walletUpgradeJSService
        self.errorRecorder = errorRecorder
    }

    // MARK: WalletUpgradeServicing

    var needsWalletUpgrade: Bool {
        guard wallet.isInitialized() else {
            // TODO: SegWit/V4 Wallet - Consumer must wait for wallet to be ready.
            errorRecorder.error(WalletError.walletNotInitialized)
            return false
        }
        return !necessaryUpgrades.isEmpty
    }

    func upgradeWallet() -> Observable<String> {
        return wait(for: necessaryWorkflows())
    }

    // MARK: Private Methods

    private func workflow(for version: PayloadVersion) -> Single<String> {
        switch version {
        case .v3:
            return walletUpgradeJSService.upgradeToV3()
        }
    }

    /// - Returns: Ordered array of necessary payload upgrades.
    private var necessaryUpgrades: [PayloadVersion] {
        var upgrades: [PayloadVersion] = []
        guard wallet.isInitialized() else {
            return upgrades
        }
        // Check if v3 upgrade is necessary.
        if !wallet.didUpgradeToHd() {
            upgrades.append(.v3)
        }
        return upgrades
    }

    private func wait(for workflows: [Observable<String>]) -> Observable<String> {
        Observable.concat(workflows)
    }

    /// Maps the list of necessary upgrades into their workflows.
    /// Because we want the version to be updated to be emitted before the work is started, we `.startWith` it.
    /// We catch any error and throw `WalletUpgradeError.errorUpgrading` instead.
    private func necessaryWorkflows() -> [Observable<String>] {
        necessaryUpgrades
            .map { version in
                workflow(for: version)
                    .asObservable()
                    .startWith(version.rawValue)
                    .catchError { error -> Observable<String> in
                        .error(WalletUpgradeError.errorUpgrading(version: version.rawValue))
                    }
            }
    }
}
