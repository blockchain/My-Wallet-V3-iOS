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
                .image(
                    perceptualPrecision: 0.98,
                    traits: UITraitCollection(userInterfaceStyle: .light)
                ),
                .image(
                    perceptualPrecision: 0.98,
                    traits: UITraitCollection(userInterfaceStyle: .dark)
                )
            ]
        )
    }

    func testAttributedText() {
        let view = Group {
            Text("Attributed ").typography(.body1) +
                Text("Text").typography(.body1).foregroundColor(.semantic.success)
        }
        .fixedSize()

        assertSnapshot(matching: view, as: .image(perceptualPrecision: 0.98))
    }
}
#endif
