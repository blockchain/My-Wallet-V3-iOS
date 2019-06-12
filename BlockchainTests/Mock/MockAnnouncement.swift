//
//  MockAnnouncement.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 6/12/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
@testable import Blockchain

class MockAnnouncementPresenter: AnnouncementPresenter { }

class MockAnnouncement: Announcement {
    typealias Presenter = MockAnnouncementPresenter

    var showInvoked: XCTestExpectation?

    init(shouldShow: Bool) {
        self.shouldShow = shouldShow
    }

    // MARK: - Announcement

    var shouldShow: Bool

    func show(_ presenter: MockAnnouncementPresenter) {
        showInvoked?.fulfill()
    }
}
