//
//  BuySellCreateAccountCoordinator.swift
//  Blockchain
//
//  Created by Chris Arriola on 7/12/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Coordinator for verifying a user's identity for buying and selling cryptos.
class BuySellCreateAccountCoordinator: Coordinator {

    private var hasCoinifyData: Bool {
        // TODO: this value needs to be retrieved from the wallet metadata - return false for now
        return false
    }

    func start() {
        if hasCoinifyData {
            // TODO: route user to correct screen depending on which information they have provided
            // Visualization for the different routes: https://cloudup.com/cmLWAVFzIHa
        } else {
            showWelcomeScreen()
        }
    }

    private func showWelcomeScreen() {
        // TODO
    }
}
