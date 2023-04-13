// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BlockchainComponentLibrary
import SnapshotTesting
import XCTest

#if os(iOS)
final class InputTests: XCTestCase {

    override func setUp() {
        super.setUp()
        isRecording = false
    }

    func testInput() {
        let view = Input_Previews.previews
            .frame(width: 300)

        assertSnapshots(
            matching: view,
            as: [
                .image(
                    perceptualPrecision: 0.98,
                    layout: .sizeThatFits,
                    traits: UITraitCollection(userInterfaceStyle: .light)
                ),
                .image(
                    perceptualPrecision: 0.98,
                    layout: .sizeThatFits,
                    traits: UITraitCollection(userInterfaceStyle: .dark)
                )
            ]
        )
    }
}
#endif
