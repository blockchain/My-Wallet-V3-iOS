#if canImport(UIKit)
import BlockchainComponentLibrary
import BlockchainNamespace
import ErrorsUI
import SnapshotTesting
import SwiftUI
import XCTest

final class ErrorViewSnapshotTests: XCTestCase {

    let error = UX.Error(
        source: nil,
        title: "Oops! Something went wrong!",
        message: "Don’t worry. Your crypto is safe. Please try again or contact our Support Team for help.",
        icon: nil,
        metadata: [
            "ID": "error-id"
        ],
        actions: .default
    )

    override static func setUp() {
        super.setUp()
        isRecording = false
    }

    func x_test() {

        let view = PrimaryNavigationView {
            ErrorView(
                ux: error,
                dismiss: {}
            )
        }
        .app(App.test)
        .frame(width: 375, height: 800)

        assertSnapshots(
            matching: view,
            as: [
                .image(
                    perceptualPrecision: 0.98,
                    traits: .init(userInterfaceStyle: .light)
                ),
                .image(
                    perceptualPrecision: 0.98,
                    traits: .init(userInterfaceStyle: .dark)
                )
            ]
        )
    }
}
#endif
