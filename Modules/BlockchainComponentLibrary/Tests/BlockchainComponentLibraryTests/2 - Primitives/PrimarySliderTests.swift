// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BlockchainComponentLibrary
import SnapshotTesting
import XCTest

#if os(iOS)
final class PrimarySliderTests: XCTestCase {

    override func setUp() {
        super.setUp()
        isRecording = false
    }

    func testSlider() {
        let view = PrimarySlider_Previews.previews
            .frame(width: 375)
            .fixedSize()

        assertSnapshot(matching: view, as: .image(perceptualPrecision: 0.98))
    }
}
#endif
