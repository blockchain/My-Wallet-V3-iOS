// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SnapshotTesting
import UIComponentsKit
import XCTest

final class LoadingStateViewTests: XCTestCase {

    override func setUp() {
        super.setUp()
        isRecording = false
    }

    func testLoadingStateView() {
        let view = LoadingStateView(title: "Loading...")
        assertSnapshot(matching: view, as: .image(perceptualPrecision: 0.98, layout: .device(config: .iPhone8)))
    }
}
