//
//  BuySellCoordinator.swift
//  Blockchain
//
//  Created by Chris Arriola on 7/12/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Coordinator for buying and selling cryptos.
class BuySellCoordinator: Coordinator {

    private let createAccountCoordinator: BuySellCreateAccountCoordinator
    private let overviewCoordinator: BuySellOverviewCoordinator

    // MARK: - Computed Properties

    private var hasCoinifyAccount: Bool {
        // TODO: this value needs to be retrieved from the wallet metadata - return false for now
        return false
    }

    init(
        createAccountCoordinator: BuySellCreateAccountCoordinator,
        overviewCoordinator: BuySellOverviewCoordinator
    ) {
        self.createAccountCoordinator = createAccountCoordinator
        self.overviewCoordinator = overviewCoordinator
    }

    func start() {
        if hasCoinifyAccount {
            overviewCoordinator.start()
        } else {
            createAccountCoordinator.start()
        }
    }
}
