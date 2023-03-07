// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BlockchainComponentLibrary
import SnapshotTesting
import XCTest

#if os(iOS)
final class RichTextTests: XCTestCase {

    override func setUp() {
        super.setUp()
        isRecording = false
    }

    func testRichText() {
        let view = RichText_Previews.previews
            .frame(width: 640)
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
