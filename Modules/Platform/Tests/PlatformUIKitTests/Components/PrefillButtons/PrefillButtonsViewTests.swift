// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import PlatformUIKit

import ComposableArchitecture
import MoneyKit
import SnapshotTesting
import SwiftUI
import XCTest

final class PrefillButtonsViewTests: XCTestCase {

    private let balanceQuickfillConfigurations: [QuickfillConfiguration] = [
        .init(multiplier: 0.25, rounding: [1, 10, 25, 100, 500, 1000]),
        .init(multiplier: 0.5, rounding: [1, 10, 25, 100, 500, 1000]),
        .init(multiplier: 0.75, rounding: [1, 10, 25, 100, 500, 1000])
    ].map { .balance($0) }
    private let maxLimit = FiatValue.create(minor: 120000, currency: .USD)

    override func setUp() {
        super.setUp()
        isRecording = false
    }

    func test_PrefillButtonsView() {
        let prefillButtonsView = PrefillButtonsView(
            store: Store<PrefillButtonsState, PrefillButtonsAction>(
                initialState: PrefillButtonsState(
                    previousTxAmount: FiatValue.create(minor: 6565, currency: .USD),
                    action: .swap,
                    maxLimit: maxLimit,
                    configurations: balanceQuickfillConfigurations
                ),
                reducer: PrefillButtons.preview
            )
        )
        .frame(width: 375, height: 60)

        assertSnapshot(matching: prefillButtonsView, as: .image)
    }
}
