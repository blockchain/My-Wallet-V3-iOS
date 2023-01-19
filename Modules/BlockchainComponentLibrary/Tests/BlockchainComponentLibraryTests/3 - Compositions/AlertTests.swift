@testable import BlockchainComponentLibrary
import SnapshotTesting
import SwiftUI
import XCTest

final class AlertTests: XCTestCase {

    override func setUp() {
        super.setUp()
        isRecording = false
    }

    func testSnapshot() {
        let view = Alert_Previews.previews
            .frame(width: 320)
            .fixedSize()

        assertSnapshot(
            matching: view,
            as: .image(
                perceptualPrecision: 0.98,
                layout: .sizeThatFits
            )
        )
    }

    func testSnapshot_largeDevices() {
        let view = Alert_Previews.previews
            .frame(width: 1024)
            .fixedSize()

        assertSnapshot(
            matching: view,
            as: .image(
                perceptualPrecision: 0.98,
                layout: .sizeThatFits
            )
        )
    }
}
