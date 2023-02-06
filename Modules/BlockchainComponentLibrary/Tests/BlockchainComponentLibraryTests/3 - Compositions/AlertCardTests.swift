// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BlockchainComponentLibrary
import SnapshotTesting
import SwiftUI
import XCTest

#if os(iOS)
final class AlertCardTests: XCTestCase {

    override func setUp() {
        super.setUp()
        isRecording = false
    }

    func testSnapshot() {
        let view = VStack(spacing: Spacing.baseline) {
            AlertCard_Previews.previews
        }
        .fixedSize()

        assertSnapshot(matching: view, as: .image(layout: .sizeThatFits))
    }
}
#endif
