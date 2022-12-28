@testable import BlockchainComponentLibrary
import SnapshotTesting
import SwiftUI
import XCTest

final class MinimalButtonTests: XCTestCase {

    override func setUp() {
        super.setUp()
        isRecording = false
    }

    func testSnapshot() {
        let view = VStack(spacing: 5) {
            MinimalButton_Previews.previews
        }
        .frame(width: 320)
        .fixedSize()
        .padding()

        assertSnapshots(
            matching: view,
            as: [
                .image(
                    perceptualPrecision: 0.98,
                    traits: UITraitCollection(userInterfaceStyle: .light)
                ),
                .image(
                    perceptualPrecision: 0.98,
                    traits: UITraitCollection(userInterfaceStyle: .dark)
                )
            ]
        )
    }
}
