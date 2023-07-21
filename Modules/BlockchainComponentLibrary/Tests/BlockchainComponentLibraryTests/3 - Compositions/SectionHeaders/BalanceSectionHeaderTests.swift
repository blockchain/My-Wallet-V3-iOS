// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BlockchainComponentLibrary
import SnapshotTesting
import SwiftUI
import XCTest

#if os(iOS)
final class BalanceSectionHeaderTests: XCTestCase {

    override func setUp() {
        super.setUp()
        isRecording = false
    }

    func testSnapshot() {
        let view = VStack(spacing: Spacing.baseline) {
            BalanceSectionHeader_Previews.previews
        }
        .background(Color.pink)
        .fixedSize()

        assertSnapshots(
            matching: view,
            as: [
                .image(precision: 0.98, layout: .sizeThatFits, traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(precision: 0.98, layout: .sizeThatFits, traits: UITraitCollection(userInterfaceStyle: .dark))
            ]
        )
    }
}
#endif
