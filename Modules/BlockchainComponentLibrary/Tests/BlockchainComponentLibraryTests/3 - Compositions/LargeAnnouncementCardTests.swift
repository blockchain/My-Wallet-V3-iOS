// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BlockchainComponentLibrary
import SnapshotTesting
import SwiftUI
import XCTest

#if os(iOS)
final class LargeAnnouncementCardTests: XCTestCase {

    override func setUp() {
        super.setUp()
        isRecording = false
    }

    func testSnapshot() {
        let view = VStack(spacing: Spacing.baseline) {
            LargeAnnouncementCard_Previews.previews
        }
        .frame(width: 375)
        .fixedSize()

        assertSnapshot(
            matching: view,
            as: .image(
                perceptualPrecision: 0.98,
                layout: .sizeThatFits
            )
        )
    }
}
#endif
