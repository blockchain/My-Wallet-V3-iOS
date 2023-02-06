// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BlockchainComponentLibrary
import SnapshotTesting
import SwiftUI
import XCTest

#if os(iOS)
final class TypographyTests: XCTestCase {

    override func setUp() {
        super.setUp()
        isRecording = false
    }

    func testSnapshot() {
        let view = Typography_Previews.previews.fixedSize()

        assertSnapshots(
            matching: view,
            as: [
                .image(traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(traits: UITraitCollection(userInterfaceStyle: .dark))
            ]
        )
    }

    func testAttributedText() {
        let view = Group {
            Text("Attributed ").typography(.body1) +
                Text("Text").typography(.body1).foregroundColor(.semantic.success)
        }
        .fixedSize()

        assertSnapshot(matching: view, as: .image)
    }
}
#endif
