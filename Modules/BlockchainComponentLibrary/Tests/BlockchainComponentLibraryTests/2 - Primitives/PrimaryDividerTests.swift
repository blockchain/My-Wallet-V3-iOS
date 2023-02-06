// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BlockchainComponentLibrary
import SnapshotTesting
import XCTest

#if os(iOS)
final class PrimaryDividerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        isRecording = false
    }

    func testPrimaryDivider() {
        let view = PrimaryDivider_Previews.previews
            .fixedSize()

        assertSnapshots(
            matching: view,
            as: [
                .image(layout: .sizeThatFits, traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(layout: .sizeThatFits, traits: UITraitCollection(userInterfaceStyle: .dark))
            ]
        )
    }
}
#endif
