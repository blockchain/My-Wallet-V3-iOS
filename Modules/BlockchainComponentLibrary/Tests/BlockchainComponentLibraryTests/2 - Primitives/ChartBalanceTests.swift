// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BlockchainComponentLibrary
import SnapshotTesting
import XCTest

#if os(iOS)
final class ChartBalanceTests: XCTestCase {

    override func setUp() {
        super.setUp()
        isRecording = false
    }

    func testChartBalance() {
        let view = ChartBalance_Previews.previews
            .fixedSize()

        assertSnapshot(matching: view, as: .image)
    }
}
#endif
