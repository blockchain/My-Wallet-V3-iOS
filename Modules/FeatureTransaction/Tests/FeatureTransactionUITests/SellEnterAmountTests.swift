//Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import XCTest
import ComposableArchitecture
import MoneyKit
import Combine
@testable import FeatureTransactionUI
import BlockchainUI
import FeatureTransactionDomain
import SwiftUI
import DIKit
import PlatformKit

@MainActor
class SellEnterAmountTests: XCTestCase {
    fileprivate var completionHandlerSpy: SellEnterAmountCompletionHandlerSpy!
    var testStore: TestStore<
        SellEnterAmount.State,
        SellEnterAmount.Action,
        SellEnterAmount.State,
        SellEnterAmount.Action,
        ()
    >!

    let defaultSourcePair = FeatureTransactionDomain.SelectionInformation(accountId: "BTC.Account", currency: .bitcoin)
    let defaultTargetPair = FeatureTransactionDomain.SelectionInformation(accountId: "ETH.Account", currency: .ethereum)
    let maxSpendableFiatValue = MoneyValue.one(currency: .USD)
    let maxSpendableCryptoValue = MoneyValue.one(currency: .bitcoin)
    let minSpendableFiatValue = MoneyValue.zero(currency: .USD)
    let minSpendableCryptoValue = MoneyValue.zero(currency: .bitcoin)

    lazy var minMaxAmountsPublisher: AnyPublisher<TransactionMinMaxValues,Never> = .just(TransactionMinMaxValues(maxSpendableFiatValue: self.maxSpendableFiatValue,
                                                                                                                 maxSpendableCryptoValue: self.maxSpendableFiatValue,
                                                                                                                 minSpendableFiatValue: self.minSpendableFiatValue,
                                                                                                                 minSpendableCryptoValue: self.minSpendableCryptoValue))

    override func setUpWithError() throws {
        try super.setUpWithError()
        completionHandlerSpy = SellEnterAmountCompletionHandlerSpy()

        testStore = TestStore(initialState: SellEnterAmount.State(),
                              reducer: SellEnterAmount(app: App.test,
                                                       onAmountChanged: completionHandlerSpy.onAmountChanged,
                                                       onPreviewTapped: completionHandlerSpy.onPreviewTapped,
                                                       minMaxAmountsPublisher: minMaxAmountsPublisher)
        )
    }


//    func test_initial_state() async {
//        await testStore.send(.onAppear)
//
//    }
}

fileprivate class SellEnterAmountCompletionHandlerSpy {
    var onPreviewTappedCalled = false
    var onPreviewTappedMoneyValue: MoneyValue?

    lazy var onPreviewTapped: (MoneyValue) -> Void = { moneyValue in
        self.onPreviewTappedCalled = true
        self.onPreviewTappedMoneyValue = moneyValue
    }

    var onAmountChangedCalled = false
    var onAmountChangedMoneyValue: MoneyValue?
    lazy var onAmountChanged: (MoneyValue) -> Void = { moneyValue in
        self.onAmountChangedMoneyValue = moneyValue
        self.onAmountChangedCalled = true
    }
}
