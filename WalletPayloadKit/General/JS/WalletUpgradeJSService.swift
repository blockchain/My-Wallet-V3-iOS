//
//  WalletUpgradeJSService.swift
//  Blockchain
//
//  Created by Paulo on 17/03/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import Localization
import RxSwift
import ToolKit

protocol WalletUpgradeJSServicing: AnyObject {
    /// Upgrades the wallet to V3 and emits "V3"
    /// Fails with `WalletUpgradeError.failedV3Upgrade` if anything went wrong.
    func upgradeToV3() -> Single<String>
}

enum WalletUpgradeJSError: Error {
    case failedV3Upgrade
}

final class WalletUpgradeJSService: WalletUpgradeJSServicing {

    // MARK: Types

    private enum JSCallback {
        enum V3Payload: NSString {
            case upgrade = "objc_upgrade_V3_success"
            case didFail = "objc_upgrade_V3_error"
        }
    }

    private enum JSFunction {
        enum V3Payload {
            static func upgrade(with newWalletName: String) -> String {
                "MyWalletPhone.upgradeToV3(\"\(newWalletName)\")"
            }
        }
    }

    // MARK: Private Properties

    private let contextProvider: JSContextProviderAPI

    // MARK: Init

    init(contextProvider: JSContextProviderAPI = resolve()) {
        self.contextProvider = contextProvider
    }

    // MARK: WalletUpgradeJSServicing

    func upgradeToV3() -> Single<String> {
        Single.create(weak: self) { (self, observer) -> Disposable in
            let context = self.contextProvider.jsContext
            let walletName = LocalizationConstants.Account.myWallet
            context.invokeOnce(
                functionBlock: {
                    observer(.success("V3"))
                },
                forJsFunctionName: JSCallback.V3Payload.upgrade.rawValue
            )
            context.invokeOnce(
                functionBlock: {
                    observer(.error(WalletUpgradeJSError.failedV3Upgrade))
                },
                forJsFunctionName: JSCallback.V3Payload.didFail.rawValue
            )
            context.evaluateScript(JSFunction.V3Payload.upgrade(with: walletName))
            return Disposables.create()
        }
    }
}
