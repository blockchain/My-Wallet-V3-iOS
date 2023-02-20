// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import SnapshotTesting
import XCTest

#if os(iOS)
final class IconButtonTexts: XCTestCase {

    override func setUp() {
        super.setUp()
        isRecording = false
    }

    func testDefault() {
        assertSnapshot(
            matching: IconButton(icon: .qrCode) {}.frame(width: 32, height: 32),
            as: .image
        )
    }

    func testDisabled() {
        assertSnapshot(
            matching: IconButton(icon: .qrCode) {}.frame(width: 32, height: 32).disabled(true),
            as: .image
        )
    }

    func testCircle() {
        let button = IconButton(icon: .qrCode.circle()) {}.frame(width: 32, height: 32)
        assertSnapshot(matching: button, as: .image)
    }
}
#endif
