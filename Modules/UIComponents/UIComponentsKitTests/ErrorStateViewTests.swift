// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SnapshotTesting
import UIComponentsKit
import XCTest

final class ErrorStateViewTests: XCTestCase {

    override func setUp() {
        super.setUp()
        isRecording = false
    }

    func testErrorStateView() {
        let view = ErrorStateView(title: "An error has occurred.")
        assertSnapshot(matching: view, as: .image(layout: .device(config: .iPhone8)))
    }

    func testRetryButton() {
        let view = ErrorStateView(
            title: "An error has occurred.",
            button: ("Retry", {})
        )

        assertSnapshot(
            matching: view,
            as: .image(
                perceptualPrecision: 0.98,
                layout: .device(config: .iPhone8)
            )
        )
    }
}
