// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BlockchainComponentLibrary
import SnapshotTesting
import SwiftUI
import XCTest

#if os(iOS)
final class BottomSheetTests: XCTestCase {

    override func setUp() {
        super.setUp()
        isRecording = false
    }

    func testBottomSheet() {

        let view = BottomSheetView {
            VStack {
                Text("Bottom Sheet")
                    .typography(.title3)
                ForEach(1...10, id: \.self) { i in
                    PrimaryRow(title: "Row \(i)")
                    if i != 10 {
                        PrimaryDivider()
                    }
                }
            }
        }
        .frame(width: 320)
        .background(Color.gray)

        assertSnapshots(
            matching: view,
            as: [
                .image(layout: .sizeThatFits, traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(layout: .sizeThatFits, traits: UITraitCollection(userInterfaceStyle: .dark))
            ]
        )
    }
}
#endif
