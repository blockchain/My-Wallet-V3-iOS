//
//  AnnouncementListTests.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 6/12/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
@testable import Blockchain

class AnnouncementListTests: XCTestCase {

    private var presenter: MockAnnouncementPresenter!
    private var list: AnnouncementList<MockAnnouncementPresenter>!

    override func setUp() {
        super.setUp()
        presenter = MockAnnouncementPresenter()
        list = AnnouncementList<MockAnnouncementPresenter>(presenter: presenter)
    }

    func testAnnouncementIsShown() {
        let announcement = MockAnnouncement(shouldShow: true)
        announcement.showInvoked = XCTestExpectation(description: "`show` should be invoked")

        list.add(announcement: AnyAnnouncement<MockAnnouncementPresenter>(announcement: announcement))
        let nextAnnouncement = list.showNextAnnouncement()

        XCTAssertNotNil(nextAnnouncement)
    }

    func testNoAnnouncementIsShown() {
        let announcement1 = MockAnnouncement(shouldShow: false)
        let announcement2 = MockAnnouncement(shouldShow: false)

        list.add(announcement: AnyAnnouncement<MockAnnouncementPresenter>(announcement: announcement1))
            .add(announcement: AnyAnnouncement<MockAnnouncementPresenter>(announcement: announcement2))
        let nextAnnouncement = list.showNextAnnouncement()

        XCTAssertNil(nextAnnouncement)
    }

    func testOnlyOneAnnouncementIsShown() {
        let announcement1 = MockAnnouncement(shouldShow: true)
        announcement1.showInvoked = XCTestExpectation(description: "`show` should be invoked")

        let announcement2 = MockAnnouncement(shouldShow: true)

        list.add(announcement: AnyAnnouncement<MockAnnouncementPresenter>(announcement: announcement1))
            .add(announcement: AnyAnnouncement<MockAnnouncementPresenter>(announcement: announcement2))
        let nextAnnouncement = list.showNextAnnouncement()

        XCTAssertNotNil(nextAnnouncement)
    }
}
