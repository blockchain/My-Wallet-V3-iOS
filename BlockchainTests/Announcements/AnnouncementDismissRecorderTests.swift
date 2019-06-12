//
//  AnnouncementDismissRecorderTests.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 6/12/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
@testable import Blockchain

class AnnouncementDismissRecorderTests: XCTestCase {

    private var userDefaults: MockUserDefaults!
    private var dismissRecorder: AnnouncementDismissRecorder!

    override func setUp() {
        super.setUp()
        userDefaults = MockUserDefaults()
        dismissRecorder = AnnouncementDismissRecorder(userDefaults: userDefaults)
    }

    func testEntryMarkedAsDismissInUserDefaults() {
        let entry = dismissRecorder["test_key"]
        entry.isDismissed = true
        XCTAssertTrue(userDefaults.bool(forKey: "test_key"))
    }

    func testEntryIsFirstNotDismissed() {
        let entry = dismissRecorder["test_key"]
        XCTAssertFalse(entry.isDismissed)
        XCTAssertFalse(userDefaults.bool(forKey: "test_key"))
    }
}
