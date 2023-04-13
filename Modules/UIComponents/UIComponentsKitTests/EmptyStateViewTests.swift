// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SnapshotTesting
import UIComponentsKit
import XCTest

final class EmptyStateViewTests: XCTestCase {

    override func setUp() {
        super.setUp()
        isRecording = false
    }

    func testEmptyStateView() {
        let view = EmptyStateView(
            title: "You Have No Activity",
            subHeading: "All your transactions will show up here.",
            image: ImageAsset.emptyActivity.image
        )

        assertSnapshot(matching: view, as: .image(perceptualPrecision: 0.98, layout: .device(config: .iPhone8)))
    }
}
