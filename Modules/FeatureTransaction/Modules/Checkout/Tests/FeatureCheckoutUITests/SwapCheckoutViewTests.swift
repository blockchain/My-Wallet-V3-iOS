// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#if os(iOS)

@testable import FeatureCheckoutUI

import Combine
import SnapshotTesting
import SwiftUI
import XCTest

final class SwapCheckoutViewTests: XCTestCase {

    override func setUp() {
        super.setUp()
        isRecording = false
    }

    func test_SwapCheckoutView() {
        let swap = SwapCheckoutView(.preview)
        assertSnapshot(
            matching: swap,
            as: .image(layout: .device(config: .iPhone8))
        )
    }
}
#endif
