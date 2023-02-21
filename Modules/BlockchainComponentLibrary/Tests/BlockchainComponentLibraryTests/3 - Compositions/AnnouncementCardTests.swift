// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BlockchainComponentLibrary
import SnapshotTesting
import SwiftUI
import XCTest

#if os(iOS)
final class AnnouncementCardTests: XCTestCase {

    override func setUp() {
        super.setUp()
        isRecording = false
    }

    func x_testSnapshot() {
        let view = AnnouncementCard(
            title: "New Asset",
            message: "Dogecoin (DOGE) is now available on Blockchain.",
            onCloseTapped: {},
            leading: {
                Icon.wallet
                    .color(.semantic.gold)
            }
        )
        .frame(width: 375)

        assertSnapshot(matching: view, as: .image)
    }
}
#endif
