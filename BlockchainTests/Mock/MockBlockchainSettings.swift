//
//  MockBlockchainSettings.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 10/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class MockBlockchainSettingsApp: BlockchainSettings.App {
    var mockDidTapOnAirdropDeepLink: Bool = false

    override init() {
        super.init()
    }

    override var didTapOnAirdropDeepLink: Bool {
        get {
            return mockDidTapOnAirdropDeepLink
        }
        set {
            mockDidTapOnAirdropDeepLink = newValue
        }
    }
}
