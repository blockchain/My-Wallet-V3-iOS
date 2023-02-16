// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import FeatureAppUpgradeUI
import SnapshotTesting
import SwiftUI
import XCTest

final class AppUpgradeViewSnapshotTests: XCTestCase {

    override func setUp() {
        super.setUp()
        isRecording = false
    }

    func testUnsupportedOS() {
        let view = view(state: .unsupportedOS)
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

    func testSoftUpgrade() {
        let view = view(state: .softUpgrade)
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

    func testHardUpgrade() {
        let view = view(state: .hardUpgrade)
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

    func testAppMaintenance() {
        let view = view(state: .appMaintenance)
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

    func testMaintenance() {
        let view = view(state: .maintenance)
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

    func view(state: AppUpgradeState.Style) -> some View {
        AppUpgradeView(
            store: .init(
                initialState: AppUpgradeState(style: state, url: ""),
                reducer: appUpgradeReducer,
                environment: ()
            )
        )
        .frame(width: 100.vw, height: 600.pt)
    }
}
