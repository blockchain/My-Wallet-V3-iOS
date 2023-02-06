// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BlockchainComponentLibrary
import SnapshotTesting
import XCTest

#if os(iOS)
final class IconsTests: XCTestCase {

    override func setUp() {
        super.setUp()
        isRecording = false
    }

    func testIcons() {

        let view = VStack {
            ForEach(Icon.allIcons.prefix(5), id: \.self) { icon in
                HStack {
                    Spacer()
                    icon.micro()
                    Spacer()
                    icon.small()
                    Spacer()
                    icon.medium()
                    Spacer()
                    icon.large()
                    Spacer()
                }
                .padding()
                HStack {
                    Spacer()
                    icon.circle().micro()
                    Spacer()
                    icon.circle().small()
                    Spacer()
                    icon.circle().medium()
                    Spacer()
                    icon.circle().large()
                    Spacer()
                }
                .padding()
            }
        }

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

        let all = VStack {
            ForEach(Icon.allIcons.chunks(ofCount: 5), id: \.self) { icons in
                HStack {
                    ForEach(icons, id: \.self) { icon in
                        icon.small()
                    }
                }
            }
        }

        assertSnapshots(
            matching: all,
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

    func testScaling() {
        assertSnapshot(matching: Icon.send.large(), as: .image)
        assertSnapshot(matching: Icon.send.micro(), as: .image)
    }

    func testColor() {
        assertSnapshot(matching: Icon.send.color(.semantic.success).medium(), as: .image)
    }

    func testCircle() {
        assertSnapshot(matching: Icon.walletSwap.circle().medium(), as: .image)
    }
}
#endif
