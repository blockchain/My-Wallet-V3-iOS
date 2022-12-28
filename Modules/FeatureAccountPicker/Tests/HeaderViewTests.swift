// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import FeatureAccountPickerUI
import Localization
import SnapshotTesting
import SwiftUI
import UIComponentsKit
import XCTest

class HeaderViewTests: XCTestCase {

    override func setUp() {
        super.setUp()
        isRecording = false
    }

    func testNormal() {
        let view = HeaderView(
            viewModel: .normal(
                title: "Send Crypto Now",
                subtitle: "Choose a Wallet to send cypto from.",
                image: ImageAsset.iconSend.image,
                tableTitle: "Select a Wallet",
                searchable: false
            ),
            searchText: .constant(nil),
            isSearching: .constant(false),
            toggleIsOn: .constant(false)
        )
        .fixedSize()

        assertSnapshot(matching: view, as: .image)
    }

    func testNormalNoImage() {
        let view = HeaderView(
            viewModel: .normal(
                title: "Send Crypto Now",
                subtitle: "Choose a Wallet to send cypto from.",
                image: nil,
                tableTitle: "Select a Wallet",
                searchable: false
            ),
            searchText: .constant(nil),
            isSearching: .constant(false),
            toggleIsOn: .constant(false)
        )
        .fixedSize()

        assertSnapshot(matching: view, as: .image)
    }

    func testNormalNoTableTitle() {
        let view = HeaderView(
            viewModel: .normal(
                title: "Send Crypto Now",
                subtitle: "Choose a Wallet to send cypto from.",
                image: ImageAsset.iconSend.image,
                tableTitle: nil,
                searchable: false
            ),
            searchText: .constant(nil),
            isSearching: .constant(false),
            toggleIsOn: .constant(false)
        )
        .fixedSize()

        assertSnapshot(matching: view, as: .image)
    }

    func testNormalSearch() {
        let view = HeaderView(
            viewModel: .normal(
                title: "Send Crypto Now",
                subtitle: "Choose a Wallet to send cypto from.",
                image: ImageAsset.iconSend.image,
                tableTitle: nil,
                searchable: true
            ),
            searchText: .constant(nil),
            isSearching: .constant(false),
            toggleIsOn: .constant(false)
        )
        .fixedSize()

        assertSnapshot(matching: view, as: .image)
    }

    func testNormalSearchCollapsed() {
        let view = HeaderView(
            viewModel: .normal(
                title: "Send Crypto Now",
                subtitle: "Choose a Wallet to send cypto from.",
                image: ImageAsset.iconSend.image,
                tableTitle: nil,
                searchable: true
            ),
            searchText: .constant("Search"),
            isSearching: .constant(true),
            toggleIsOn: .constant(false)
        )
        .animation(nil)
        .frame(width: 375)

        assertSnapshot(matching: view, as: .image)
    }

    func testSimple() {
        let view = HeaderView(
            viewModel: .simple(
                subtitle: "Subtitle",
                searchable: false,
                switchable: false,
                switchTitle: nil
            ),
            searchText: .constant(nil),
            isSearching: .constant(false),
            toggleIsOn: .constant(false)
        )
        .fixedSize()

        assertSnapshot(matching: view, as: .image)
    }

    func testNone() {
        let view = HeaderView(
            viewModel: .none,
            searchText: .constant(nil),
            isSearching: .constant(false),
            toggleIsOn: .constant(false)
        )
            .frame(width: 375, height: 1)

        assertSnapshot(matching: view, as: .image(perceptualPrecision: 0.98))
    }
}
