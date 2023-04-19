// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BlockchainComponentLibrary
import SnapshotTesting
import XCTest

#if os(iOS)
final class ColorsTests: XCTestCase {

    override func setUp() {
        super.setUp()
        isRecording = false
    }

    func testSnapshot() {
        let view = Colors_Previews.previews
            .frame(width: 320)
            .fixedSize()

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
}
#endif
