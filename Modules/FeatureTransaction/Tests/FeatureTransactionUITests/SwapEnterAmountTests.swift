// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import Combine
import ComposableArchitecture
import DIKit
import FeatureTransactionDomain
@testable import FeatureTransactionUI
import Foundation
import MoneyKit
import PlatformKit
import SwiftUI
import XCTest

@MainActor
class SwapEnterAmountTests: XCTestCase {
    var mockDefaultPairsService: MockDefaultSwapCurrencyPairsService!
    fileprivate var completionHandlerSpy: SwapCompletionHandlerSpy!
    var testStore: TestStore<
        SwapEnterAmount.State,
        SwapEnterAmount.Action,
        SwapEnterAmount.State,
        SwapEnterAmount.Action,
        Void
    >!

    let defaultSourcePair = FeatureTransactionDomain.SelectionInformation(accountId: "BTC.Account", currency: .bitcoin)
    let defaultTargetPair = FeatureTransactionDomain.SelectionInformation(accountId: "ETH.Account", currency: .ethereum)
    let maxSpendableFiatValue = MoneyValue.one(currency: .USD)
    let maxSpendableCryptoValue = MoneyValue.one(currency: .bitcoin)
    let minSpendableFiatValue = MoneyValue.zero(currency: .USD)
    let minSpendableCryptoValue = MoneyValue.zero(currency: .bitcoin)

    lazy var minMaxAmountsPublisher: AnyPublisher<TransactionMinMaxValues, Never> = .just(TransactionMinMaxValues(
        maxSpendableFiatValue: self.maxSpendableFiatValue,
        maxSpendableCryptoValue: self.maxSpendableFiatValue,
        minSpendableFiatValue: self.minSpendableFiatValue,
        minSpendableCryptoValue: self.minSpendableCryptoValue
    ))

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockDefaultPairsService = MockDefaultSwapCurrencyPairsService()
        mockDefaultPairsService.pairsToReturn = (defaultSourcePair, defaultTargetPair)
        completionHandlerSpy = SwapCompletionHandlerSpy()

        testStore = TestStore(
            initialState: SwapEnterAmount.State(),
            reducer: SwapEnterAmount(
                app: App.test,
                defaultSwaptPairsService: mockDefaultPairsService,
                supportedPairsInteractorService: MockSupportedPairsInteractorService(),
                minMaxAmountsPublisher: minMaxAmountsPublisher,
                dismiss: completionHandlerSpy.onDismiss,
                onPairsSelected: completionHandlerSpy.onPairsSelected,
                onAmountChanged: completionHandlerSpy.onAmountChanged,
                onPreviewTapped: completionHandlerSpy.onPreviewTapped
            )
        )
    }

    func test_initial_state() async {
        await testStore.send(.onAppear)
        XCTAssertTrue(mockDefaultPairsService.getDefaultPairsCalled)
    }

    func test_on_input_changed() async {
        var state = SwapEnterAmount.State(
            sourceInformation: defaultSourcePair,
            targetInformation: defaultTargetPair
        )

        state.defaultFiatCurrency = FiatCurrency.USD
        state.sourceValuePrice = MoneyValue.one(currency: .USD)
        testStore = TestStore(
            initialState: state,
            reducer: SwapEnterAmount(
                app: App.test,
                defaultSwaptPairsService: mockDefaultPairsService,
                supportedPairsInteractorService: MockSupportedPairsInteractorService(),
                minMaxAmountsPublisher: minMaxAmountsPublisher,
                dismiss: completionHandlerSpy.onDismiss,
                onPairsSelected: completionHandlerSpy.onPairsSelected,
                onAmountChanged: completionHandlerSpy.onAmountChanged,
                onPreviewTapped: completionHandlerSpy.onPreviewTapped
            )
        )
        await testStore.send(.onInputChanged("1"), assert: {
            var inputFormatter = CurrencyInputFormatter()
            inputFormatter.append("1")
            $0.input = inputFormatter
            $0.amountCryptoEntered = .create(majorDisplay: "1", currency: self.defaultSourcePair.currency.currencyType)
        })
        XCTAssertTrue(completionHandlerSpy.onAmountChangedCalled)
        XCTAssertEqual(completionHandlerSpy.onAmountChangedMoneyValue, testStore.state.amountCryptoEntered)
    }

    func test_on_max_button_tapped() async {
        var state = SwapEnterAmount.State(
            sourceInformation: defaultSourcePair,
            targetInformation: defaultTargetPair
        )

        state.defaultFiatCurrency = FiatCurrency.USD
        state.sourceValuePrice = MoneyValue.one(currency: .USD)
        state.transactionMinMaxValues = TransactionMinMaxValues(maxSpendableFiatValue: maxSpendableFiatValue, maxSpendableCryptoValue: maxSpendableCryptoValue, minSpendableFiatValue: minSpendableFiatValue, minSpendableCryptoValue: minSpendableCryptoValue)
        testStore = TestStore(
            initialState: state,
            reducer: SwapEnterAmount(
                app: App.test,
                defaultSwaptPairsService: mockDefaultPairsService,
                supportedPairsInteractorService: MockSupportedPairsInteractorService(),
                minMaxAmountsPublisher: minMaxAmountsPublisher,
                dismiss: completionHandlerSpy.onDismiss,
                onPairsSelected: completionHandlerSpy.onPairsSelected,
                onAmountChanged: completionHandlerSpy.onAmountChanged,
                onPreviewTapped: completionHandlerSpy.onPreviewTapped
            )
        )

        await testStore.send(.onMaxButtonTapped, assert: {
            // we set the amount to the max value
            $0.amountCryptoEntered = self.maxSpendableCryptoValue
            // we change the input to crypto input
            $0.isEnteringFiat = false
        })
    }

    func test_on_preview_tapped() async {
        var state = SwapEnterAmount.State(
            sourceInformation: defaultSourcePair,
            targetInformation: defaultTargetPair
        )

        state.defaultFiatCurrency = FiatCurrency.USD
        state.sourceValuePrice = MoneyValue.one(currency: .USD)
        state.amountCryptoEntered = maxSpendableCryptoValue
         testStore = TestStore(
             initialState: state,
             reducer: SwapEnterAmount(
                 app: App.test,
                 defaultSwaptPairsService: mockDefaultPairsService,
                 supportedPairsInteractorService: MockSupportedPairsInteractorService(),
                 minMaxAmountsPublisher: minMaxAmountsPublisher,
                 dismiss: completionHandlerSpy.onDismiss,
                 onPairsSelected: completionHandlerSpy.onPairsSelected,
                 onAmountChanged: completionHandlerSpy.onAmountChanged,
                 onPreviewTapped: completionHandlerSpy.onPreviewTapped
             )
         )

        await testStore.send(.onPreviewTapped)
        XCTAssertTrue(completionHandlerSpy.onPreviewTappedCalled)
        XCTAssertEqual(completionHandlerSpy.onPreviewTappedMoneyValue, testStore.state.amountCryptoEntered)
    }

    func test_change_input_no_previous_input() async {
        var state = SwapEnterAmount.State(
            sourceInformation: defaultSourcePair,
            targetInformation: defaultTargetPair
        )

        state.defaultFiatCurrency = FiatCurrency.USD
        state.sourceValuePrice = MoneyValue.one(currency: .USD)
        state.amountCryptoEntered = nil
        state.isEnteringFiat = true
         testStore = TestStore(
             initialState: state,
             reducer: SwapEnterAmount(
                 app: App.test,
                 defaultSwaptPairsService: mockDefaultPairsService,
                 supportedPairsInteractorService: MockSupportedPairsInteractorService(),
                 minMaxAmountsPublisher: minMaxAmountsPublisher,
                 dismiss: completionHandlerSpy.onDismiss,
                 onPairsSelected: completionHandlerSpy.onPairsSelected,
                 onAmountChanged: completionHandlerSpy.onAmountChanged,
                 onPreviewTapped: completionHandlerSpy.onPreviewTapped
             )
         )

        await testStore.send(.onChangeInputTapped, assert: {
            $0.isEnteringFiat = false
        })

        await testStore.receive(.resetInput(newInput: nil)) {
            $0.amountCryptoEntered = .zero(currency: self.defaultSourcePair.currency.currencyType)
            XCTAssertEqual($0.input.suggestion, "0")
        }
    }

    func test_change_input_with_existing_input() async {
        var state = SwapEnterAmount.State(
            sourceInformation: defaultSourcePair,
            targetInformation: defaultTargetPair
        )

        state.defaultFiatCurrency = FiatCurrency.USD
        state.sourceValuePrice = MoneyValue.one(currency: .USD)
        state.amountCryptoEntered = maxSpendableCryptoValue
        state.isEnteringFiat = true
         testStore = TestStore(
             initialState: state,
             reducer: SwapEnterAmount(
                 app: App.test,
                 defaultSwaptPairsService: mockDefaultPairsService,
                 supportedPairsInteractorService: MockSupportedPairsInteractorService(),
                 minMaxAmountsPublisher: minMaxAmountsPublisher,
                 dismiss: completionHandlerSpy.onDismiss,
                 onPairsSelected: completionHandlerSpy.onPairsSelected,
                 onAmountChanged: completionHandlerSpy.onAmountChanged,
                 onPreviewTapped: completionHandlerSpy.onPreviewTapped
             )
         )

        let projectedValue = testStore.state.secondaryFieldText
        await testStore.send(.onChangeInputTapped, assert: {
            $0.isEnteringFiat = false
        })

        await testStore.receive(.resetInput(newInput: projectedValue)) {
            var inputFormatter = CurrencyInputFormatter()
            inputFormatter.append("1")
            inputFormatter.append(".")
            inputFormatter.append("0")
            $0.input = inputFormatter
        }
    }
}

class MockSupportedPairsInteractorService: SupportedPairsInteractorServiceAPI {
    var pairs: AnyPublisher<PlatformKit.SupportedPairs, Error> = .empty()

    func fetchSupportedTradingCryptoCurrencies() -> AnyPublisher<[MoneyKit.CryptoCurrency], Error> {
        .empty()
    }
}

class MockDefaultSwapCurrencyPairsService: DefaultSwapCurrencyPairsServiceAPI {
    var pairsToReturn: (source: FeatureTransactionDomain.SelectionInformation, target: FeatureTransactionDomain.SelectionInformation)?

    var getDefaultPairsCalled: Bool = false
    func getDefaultPairs(sourceInformation: FeatureTransactionDomain.SelectionInformation?) async -> (source: FeatureTransactionDomain.SelectionInformation, target: FeatureTransactionDomain.SelectionInformation)? {
        getDefaultPairsCalled = true
        return pairsToReturn
    }
}

private class SwapCompletionHandlerSpy {
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

    var onPairsSelectedCalled = false
    var onPairsSelectedSource: String?
    var onPairsSelectedTarget: String?
    var onPairsSelectedMoneyValue: MoneyValue?

    lazy var onPairsSelected: (String, String, MoneyValue?) -> Void = { source, target, amount in
        self.onPairsSelectedCalled = true
        self.onPairsSelectedSource = source
        self.onPairsSelectedTarget = target
        self.onPairsSelectedMoneyValue = amount
    }

    var onDismissCalled = false
    lazy var onDismiss: () -> Void = {
        self.onDismissCalled = true
    }
}
