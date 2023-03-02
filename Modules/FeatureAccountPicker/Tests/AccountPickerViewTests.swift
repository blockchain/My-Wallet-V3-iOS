// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import ComposableArchitecture
@testable import FeatureAccountPickerUI
import SnapshotTesting
import SwiftUI
import UIComponentsKit
import XCTest

class AccountPickerViewTests: XCTestCase {

    let allIdentifier = UUID()
    let btcWalletIdentifier = UUID()
    let btcTradingWalletIdentifier = UUID()
    let ethWalletIdentifier = UUID()
    let bchWalletIdentifier = UUID()
    let bchTradingWalletIdentifier = UUID()

    lazy var fiatBalances: [AnyHashable: String] = [
        allIdentifier: "$2,302.39",
        btcWalletIdentifier: "$2,302.39",
        btcTradingWalletIdentifier: "$10,093.13",
        ethWalletIdentifier: "$807.21",
        bchWalletIdentifier: "$807.21",
        bchTradingWalletIdentifier: "$40.30"
    ]

    lazy var currencyCodes: [AnyHashable: String] = [
        allIdentifier: "USD"
    ]

    lazy var cryptoBalances: [AnyHashable: String] = [
        btcWalletIdentifier: "0.21204887 BTC",
        btcTradingWalletIdentifier: "1.38294910 BTC",
        ethWalletIdentifier: "0.17039384 ETH",
        bchWalletIdentifier: "0.00388845 BCH",
        bchTradingWalletIdentifier: "0.00004829 BCH"
    ]

    lazy var accountPickerRowList: [AccountPickerSection] = [
        .accounts([
            .accountGroup(
                AccountPickerRow.AccountGroup(
                    id: allIdentifier,
                    title: "All Wallets",
                    description: "Total Balance"
                )
            ),
            .button(
                AccountPickerRow.Button(
                    id: UUID(),
                    text: "See Balance"
                )
            ),
            .singleAccount(
                AccountPickerRow.SingleAccount(
                    id: btcWalletIdentifier,
                    title: "BTC Wallet",
                    description: "Bitcoin"
                )
            ),
            .singleAccount(
                AccountPickerRow.SingleAccount(
                    id: btcTradingWalletIdentifier,
                    title: "BTC Trading Wallet",
                    description: "Bitcoin"
                )
            ),
            .singleAccount(
                AccountPickerRow.SingleAccount(
                    id: ethWalletIdentifier,
                    title: "ETH Wallet",
                    description: "Ethereum"
                )
            ),
            .singleAccount(
                AccountPickerRow.SingleAccount(
                    id: bchWalletIdentifier,
                    title: "BCH Wallet",
                    description: "Bitcoin Cash"
                )
            ),
            .singleAccount(
                AccountPickerRow.SingleAccount(
                    id: bchTradingWalletIdentifier,
                    title: "BCH Trading Wallet",
                    description: "Bitcoin Cash"
                )
            )
        ])
    ]

    let header = HeaderStyle.normal(
        title: "Send Crypto Now",
        subtitle: "Choose a Wallet to send cypto from.",
        image: ImageAsset.iconSend.image,
        tableTitle: "Select a Wallet",
        searchable: false
    )

    override func setUp() {
        super.setUp()
        isRecording = false
    }

    func testView() {
        let view = AccountPickerView(store: .init(initialState: .init(
                                                    sections: .loaded(next: .success(Sections(content: accountPickerRowList))),
                header: .init(headerStyle: header, searchText: nil),
                fiatBalances: fiatBalances,
                cryptoBalances: cryptoBalances,
                currencyCodes: currencyCodes
            ),
                reducer: AccountPicker(
                    rowSelected: { _ in },
                    uxSelected: { _ in },
                    backButtonTapped: {},
                    closeButtonTapped: {},
                    search: { _ in },
                    sections: { .just([]).eraseToAnyPublisher() },
                    updateSingleAccounts: { _ in .just([:]) },
                    updateAccountGroups: { _ in .just([:]) },
                    header: { [unowned self] in .just(header).eraseToAnyPublisher() },
                    onSegmentSelectionChanged: { _ in }
            )),
            badgeView: { _ in EmptyView() },
            descriptionView: { _ in EmptyView() },
            iconView: { _ in EmptyView() },
            multiBadgeView: { _ in EmptyView() },
            withdrawalLocksView: { EmptyView() },
            topMoversView: { EmptyView() }
        )
        .app(App.preview)

        assertSnapshot(
            matching: view,
            as: .image(perceptualPrecision: 0.98, layout: .device(config: .iPhone8))
        )
    }
}
