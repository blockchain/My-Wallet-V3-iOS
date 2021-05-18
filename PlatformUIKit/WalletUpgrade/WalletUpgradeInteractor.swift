//
//  WalletUpgradeInteractor.swift
//  Blockchain
//
//  Created by Paulo on 17/03/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import RxSwift
import WalletPayloadKit

public final class WalletUpgradeInteractor {

    // MARK: Private Properties

    private let service: WalletUpgradeServicing
    private let completion: () -> Void

    // MARK: Init

    public init(service: WalletUpgradeServicing = resolve(), completion: @escaping () -> Void) {
        self.service = service
        self.completion = completion
    }

    // MARK: Methods

    /// Upgrades the user wallet to the most recent version.
    /// Stream the current version upgrade.
    /// Completes when the work is done.
    /// Errors when something went wrong.
    func upgradeWallet() -> Observable<String> {
        service.upgradeWallet()
            .do(afterCompleted: { [weak self] in
                self?.completion()
            })
    }
}
