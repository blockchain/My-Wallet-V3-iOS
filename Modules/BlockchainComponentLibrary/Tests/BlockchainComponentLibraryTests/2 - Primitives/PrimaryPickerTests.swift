// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BlockchainComponentLibrary
import SnapshotTesting
import XCTest

#if os(iOS)
final class PrimaryPickerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        isRecording = false
    }

    func testPicker() {
        let view = PrimaryPicker_Previews.previews
            .frame(width: 375)
            .fixedSize()

        assertSnapshots(
            matching: view,
            as: [
                .image(perceptualPrecision: 0.98, layout: .sizeThatFits, traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(perceptualPrecision: 0.98, layout: .sizeThatFits, traits: UITraitCollection(userInterfaceStyle: .dark))
            ]
        )
    }
}
#endif
