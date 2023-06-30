// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BlockchainNamespace
import FeatureCardPaymentDomain
@testable import FeatureTransactionUI
import MoneyKit
import PlatformKit
import PlatformUIKit
import PlatformUIKitMock
import TestKit
import ToolKitMock
import UIKit
import XCTest

final class PaymentMethodLinkingRouterTests: XCTestCase {

    private var router: PaymentMethodLinkingRouter!
    private var mockPaymentMethodsLinker: MockPaymentMethodsLinker!
    private var mockApp: AppProtocol!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockApp = App.test
        mockPaymentMethodsLinker = MockPaymentMethodsLinker()
        router = PaymentMethodLinkingRouter(
            app: mockApp,
            paymentMethodsLinker: mockPaymentMethodsLinker,
            bankAccountLinker: mockPaymentMethodsLinker,
            bankWireLinker: mockPaymentMethodsLinker,
            cardLinker: mockPaymentMethodsLinker
        )
    }

    override func tearDownWithError() throws {
        router = nil
        mockPaymentMethodsLinker = nil
        try super.tearDownWithError()
    }

    func test_route_to_link_card_abandoned() throws {
        // WHEN: The router is asked to present the link a card flow
        let mockPresenter = MockViewController()
        let e = expectation(description: "Completion Block Called")
        var result: PaymentMethodsLinkingFlowResult?
        router.routeToCardLinkingFlow(from: mockPresenter) { r in
            result = r
            e.fulfill()
        }
        // THEN: The card flow linker is used to direct the user to the correct flow
        let invocation = mockPaymentMethodsLinker.recordedInvocations.presentCardLinkingFlow.first
        XCTAssertNotNil(invocation)
        // WHEN: The flow completes
        invocation?.completion(.abandoned)
        // THEN: The presenter is NOT asked to dismiss the flow
        XCTAssertNil(mockPresenter.recordedInvocations.dismiss.first)
        // AND: The completion called is called with the expected result
        wait(for: [e], timeout: 10)
        XCTAssertEqual(result, .abandoned)
    }

    func test_route_to_link_card_completed() throws {
        // WHEN: The router is asked to present the link a card flow
        let mockPresenter = MockViewController()
        let e = expectation(description: "Completion Block Called")
        var result: PaymentMethodsLinkingFlowResult?
        router.routeToCardLinkingFlow(from: mockPresenter) { r in
            result = r
            e.fulfill()
        }
        // THEN: The card flow linker is used to direct the user to the correct flow
        let invocation = mockPaymentMethodsLinker.recordedInvocations.presentCardLinkingFlow.first
        XCTAssertNotNil(invocation)
        // WHEN: The flow completes
        invocation?.completion(.completed(.test))
        // THEN: The presenter is NOT asked to dismiss the flow
        XCTAssertNil(mockPresenter.recordedInvocations.dismiss.first)
        // AND: The completion called is called with the expected result
        wait(for: [e], timeout: 10)
        XCTAssertEqual(result, .completed(nil))
    }

    func test_route_to_link_bank_usd() throws {
        // GIVEN: The currency is USD, which supports ACH
        let currency: FiatCurrency = .USD
        // WHEN: The router is asked to present the link a bank flow
        let mockPresenter = MockViewController()
        let e = expectation(description: "Completion Block Called")
        var result: PaymentMethodsLinkingFlowResult?
        router.routeToBankLinkingFlow(for: currency, from: mockPresenter) { r in
            result = r
            e.fulfill()
        }
        // THEN: The card flow linker is used to direct the user to the correct flow
        let invocation = mockPaymentMethodsLinker.recordedInvocations.presentBankLinkingFlow.first
        XCTAssertNotNil(invocation)
        // WHEN: The flow completes
        invocation?.completion(.completed)
        // THEN: The presenter is NOT asked to dismiss the flow
        XCTAssertNil(mockPresenter.recordedInvocations.dismiss.first)
        // AND: The completion called is called with the expected result
        wait(for: [e], timeout: 10)
        XCTAssertEqual(result, .completed(nil))
    }

    func test_route_to_link_bank_gbp_open_banking_enabled() throws {
        // GIVEN: The currency is GBP, which supports Open Banking
        let currency: FiatCurrency = .GBP
        // AND: Open Banking is enabled
        // WHEN: The router is asked to present the link a bank flow
        let mockPresenter = MockViewController()
        let e = expectation(description: "Completion Block Called")
        var result: PaymentMethodsLinkingFlowResult?
        router.routeToBankLinkingFlow(for: currency, from: mockPresenter) { r in
            result = r
            e.fulfill()
        }
        // THEN: The card flow linker is used to direct the user to the correct flow
        let invocation = mockPaymentMethodsLinker.recordedInvocations.presentBankLinkingFlow.first
        XCTAssertNotNil(invocation)
        // WHEN: The flow completes
        invocation?.completion(.abandoned)
        // THEN: The presenter is NOT asked to dismiss the flow
        XCTAssertNil(mockPresenter.recordedInvocations.dismiss.first)
        // AND: The completion called is called with the expected result
        wait(for: [e], timeout: 10)
        XCTAssertEqual(result, .abandoned)
    }

    func test_route_to_link_bank_unsupported_currency() throws {
        // GIVEN: An unsupported currency
        let currency: FiatCurrency = .JPY
        // WHEN: The router is asked to present the link a bank flow
        let mockPresenter = MockViewController()
        let e = expectation(description: "Completion Block Called")
        var result: PaymentMethodsLinkingFlowResult?
        router.routeToBankLinkingFlow(for: currency, from: mockPresenter) { r in
            result = r
            e.fulfill()
        }
        // THEN: The card flow linker is used to direct the user to the correct flow
        let invocation = mockPaymentMethodsLinker.recordedInvocations.presentBankWireInstructions.first
        XCTAssertNotNil(invocation)
        // WHEN: The flow completes
        invocation?.completion()
        // THEN: The presenter is NOT asked to dismiss the flow
        XCTAssertNil(mockPresenter.recordedInvocations.dismiss.first)
        // AND: The completion called is called
        wait(for: [e], timeout: 10)
        XCTAssertEqual(result, .abandoned)
    }

    func test_route_to_payment_linking_flow_cancel() {
        // WHEN: The router is asked to present the generic payment linking flow
        let mockPresenter = MockViewController()
        let e = expectation(description: "Completion Block Called")
        var result: PaymentMethodsLinkingFlowResult?
        router.routeToPaymentMethodLinkingFlow(from: mockPresenter) { r in
            result = r
            e.fulfill()
        }
        // THEN: The user is directed to the payment method selection flow
        let invocation = mockPaymentMethodsLinker.recordedInvocations.presentAccountLinkingFlow.first
        XCTAssertNotNil(invocation)
        // WHEN: The flow completes with a cancellation
        invocation?.completion(.abandoned)
        // THEN: The presenter is NOT asked to dismiss the flow
        XCTAssertNil(mockPresenter.recordedInvocations.dismiss.first)
        // AND: The completion called is called
        wait(for: [e], timeout: 10)
        XCTAssertEqual(result, .abandoned)
    }

    func test_route_to_payment_linking_flow_card_selected() {
        // WHEN: The router is asked to present the generic payment linking flow
        let mockPresenter = MockViewController()
        let completionCalledExpectation = expectation(description: "Completion Block Called")
        let completionNotCalledExpectation = expectation(description: "Completion Block NOT Called")
        completionNotCalledExpectation.isInverted = true
        var result: PaymentMethodsLinkingFlowResult?
        router.routeToPaymentMethodLinkingFlow(from: mockPresenter) { r in
            result = r
            completionCalledExpectation.fulfill()
            completionNotCalledExpectation.fulfill()
        }
        // THEN: The user is directed to the payment method selection flow
        let selectionInvocation = mockPaymentMethodsLinker.recordedInvocations.presentAccountLinkingFlow.first
        XCTAssertNotNil(selectionInvocation)
        // WHEN: The flow completes with a selection
        let stubCard = PaymentMethod(
            type: .card([.visa]),
            max: .create(minor: 100000, currency: .USD),
            min: .create(minor: 500, currency: .USD),
            maxDaily: nil,
            maxAnnual: nil,
            isEligible: true,
            isVisible: true
        )
        selectionInvocation?.completion(.completed(stubCard))
        // THEN: The presenter is asked to dismiss the flow (because of a memory leak)
        XCTAssertEqual(mockPresenter.recordedInvocations.dismiss.count, 1)
        mockPresenter.recordedInvocations.dismiss.first?.completion?()
        // AND: The completion called is NOT called
        wait(for: [completionNotCalledExpectation], timeout: 1)
        // AND: The payment method linking flow is presented
        let linkingInvocation = mockPaymentMethodsLinker.recordedInvocations.presentCardLinkingFlow.first
        XCTAssertNotNil(linkingInvocation)
        // WHEN: The payment linking flow is complete
        linkingInvocation?.completion(.completed(.test))
        // THEN: Finally, the completion block is called with the expected result
        wait(for: [completionCalledExpectation], timeout: 10)
        XCTAssertEqual(result, .completed(nil))
    }

    func test_route_to_payment_linking_flow_ach_bank_selected() {
        // WHEN: The router is asked to present the generic payment linking flow
        let mockPresenter = MockViewController()
        let completionCalledExpectation = expectation(description: "Completion Block Called")
        let completionNotCalledExpectation = expectation(description: "Completion Block NOT Called")
        completionNotCalledExpectation.isInverted = true
        var result: PaymentMethodsLinkingFlowResult?
        router.routeToPaymentMethodLinkingFlow(from: mockPresenter) { r in
            result = r
            completionCalledExpectation.fulfill()
            completionNotCalledExpectation.fulfill()
        }
        // THEN: The user is directed to the payment method selection flow
        let selectionInvocation = mockPaymentMethodsLinker.recordedInvocations.presentAccountLinkingFlow.first
        XCTAssertNotNil(selectionInvocation)
        // WHEN: The flow completes with a selection
        let stubCard = PaymentMethod(
            type: .bankAccount(.fiat(.USD)),
            max: .create(minor: 100000, currency: .USD),
            min: .create(minor: 500, currency: .USD),
            maxDaily: nil,
            maxAnnual: nil,
            isEligible: true,
            isVisible: true
        )
        selectionInvocation?.completion(.completed(stubCard))
        // THEN: The presenter is asked to dismiss the flow (because of a memory leak)
        XCTAssertEqual(mockPresenter.recordedInvocations.dismiss.count, 1)
        mockPresenter.recordedInvocations.dismiss.first?.completion?()
        // AND: The completion called is NOT called
        wait(for: [completionNotCalledExpectation], timeout: 1)
        // AND: The payment method linking flow is presented
        let linkingInvocation = mockPaymentMethodsLinker.recordedInvocations.presentBankLinkingFlow.first
        XCTAssertNotNil(linkingInvocation)
        // WHEN: The payment linking flow is complete
        linkingInvocation?.completion(.completed)
        // THEN: Finally, the completion block is called with the expected result
        wait(for: [completionCalledExpectation], timeout: 10)
        XCTAssertEqual(result, .completed(nil))
    }

    func test_route_to_payment_linking_flow_ob_bank_selected_feature_enabled() {
        // WHEN: The router is asked to present the generic payment linking flow
        let mockPresenter = MockViewController()
        let completionCalledExpectation = expectation(description: "Completion Block Called")
        let completionNotCalledExpectation = expectation(description: "Completion Block NOT Called")
        completionNotCalledExpectation.isInverted = true
        var result: PaymentMethodsLinkingFlowResult?
        router.routeToPaymentMethodLinkingFlow(from: mockPresenter) { r in
            result = r
            completionCalledExpectation.fulfill()
            completionNotCalledExpectation.fulfill()
        }
        // THEN: The user is directed to the payment method selection flow
        let selectionInvocation = mockPaymentMethodsLinker.recordedInvocations.presentAccountLinkingFlow.first
        XCTAssertNotNil(selectionInvocation)
        // WHEN: The flow completes with a selection
        let stubCard = PaymentMethod(
            type: .bankAccount(.fiat(.GBP)),
            max: .create(minor: 100000, currency: .GBP),
            min: .create(minor: 500, currency: .GBP),
            maxDaily: nil,
            maxAnnual: nil,
            isEligible: true,
            isVisible: true
        )
        selectionInvocation?.completion(.completed(stubCard))
        // THEN: The presenter is asked to dismiss the flow (because of a memory leak)
        XCTAssertEqual(mockPresenter.recordedInvocations.dismiss.count, 1)
        mockPresenter.recordedInvocations.dismiss.first?.completion?()
        // AND: The completion called is NOT called
        wait(for: [completionNotCalledExpectation], timeout: 1)
        // AND: The payment method linking flow is presented
        let linkingInvocation = mockPaymentMethodsLinker.recordedInvocations.presentBankLinkingFlow.first
        XCTAssertNotNil(linkingInvocation)
        // WHEN: The payment linking flow is complete
        linkingInvocation?.completion(.completed)
        // THEN: Finally, the completion block is called with the expected result
        wait(for: [completionCalledExpectation], timeout: 10)
        XCTAssertEqual(result, .completed(nil))
    }

    func test_route_to_payment_linking_flow_unsupported_currency_bank_selected() {
        // WHEN: The router is asked to present the generic payment linking flow
        let mockPresenter = MockViewController()
        let completionCalledExpectation = expectation(description: "Completion Block Called")
        let completionNotCalledExpectation = expectation(description: "Completion Block NOT Called")
        completionNotCalledExpectation.isInverted = true
        var result: PaymentMethodsLinkingFlowResult?
        router.routeToPaymentMethodLinkingFlow(from: mockPresenter) { r in
            result = r
            completionCalledExpectation.fulfill()
            completionNotCalledExpectation.fulfill()
        }
        // THEN: The user is directed to the payment method selection flow
        let selectionInvocation = mockPaymentMethodsLinker.recordedInvocations.presentAccountLinkingFlow.first
        XCTAssertNotNil(selectionInvocation)
        // WHEN: The flow completes with a selection
        let stubCard = PaymentMethod(
            type: .bankAccount(.fiat(.CNY)),
            max: .create(minor: 100000, currency: .CNY),
            min: .create(minor: 500, currency: .CNY),
            maxDaily: nil,
            maxAnnual: nil,
            isEligible: true,
            isVisible: true
        )
        selectionInvocation?.completion(.completed(stubCard))
        // THEN: The presenter is asked to dismiss the flow (because of a memory leak)
        XCTAssertEqual(mockPresenter.recordedInvocations.dismiss.count, 1)
        mockPresenter.recordedInvocations.dismiss.first?.completion?()
        // AND: The completion called is NOT called
        wait(for: [completionNotCalledExpectation], timeout: 1)
        // AND: The payment method linking flow is presented
        let linkingInvocation = mockPaymentMethodsLinker.recordedInvocations.presentBankWireInstructions.first
        XCTAssertNotNil(linkingInvocation)
        // WHEN: The payment linking flow is complete
        linkingInvocation?.completion()
        // THEN: Finally, the completion block is called with the expected result
        wait(for: [completionCalledExpectation], timeout: 10)
        XCTAssertEqual(result, .abandoned)
    }

    func test_route_to_payment_linking_flow_bank_transfer_selected() {
        // WHEN: The router is asked to present the generic payment linking flow
        let mockPresenter = MockViewController()
        let completionCalledExpectation = expectation(description: "Completion Block Called")
        let completionNotCalledExpectation = expectation(description: "Completion Block NOT Called")
        completionNotCalledExpectation.isInverted = true
        var result: PaymentMethodsLinkingFlowResult?
        router.routeToPaymentMethodLinkingFlow(from: mockPresenter) { r in
            result = r
            completionCalledExpectation.fulfill()
            completionNotCalledExpectation.fulfill()
        }
        // THEN: The user is directed to the payment method selection flow
        let selectionInvocation = mockPaymentMethodsLinker.recordedInvocations.presentAccountLinkingFlow.first
        XCTAssertNotNil(selectionInvocation)
        // WHEN: The flow completes with a selection
        let stubCard = PaymentMethod(
            type: .bankTransfer(.fiat(.USD)),
            max: .create(minor: 100000, currency: .USD),
            min: .create(minor: 500, currency: .USD),
            maxDaily: nil,
            maxAnnual: nil,
            isEligible: true,
            isVisible: true
        )
        selectionInvocation?.completion(.completed(stubCard))
        // THEN: The presenter is asked to dismiss the flow (because of a memory leak)
        XCTAssertEqual(mockPresenter.recordedInvocations.dismiss.count, 1)
        mockPresenter.recordedInvocations.dismiss.first?.completion?()
        // AND: The completion called is NOT called
        wait(for: [completionNotCalledExpectation], timeout: 1)
        // AND: The payment method linking flow is presented
        let linkingInvocation = mockPaymentMethodsLinker.recordedInvocations.presentBankLinkingFlow.first
        XCTAssertNotNil(linkingInvocation)
        // WHEN: The payment linking flow is complete
        linkingInvocation?.completion(.abandoned)
        // THEN: Finally, the completion block is called with the expected result
        wait(for: [completionCalledExpectation], timeout: 10)
        XCTAssertEqual(result, .abandoned)
    }

    func test_route_to_payment_linking_flow_bank_transfer_funds_selected() {
        // WHEN: The router is asked to present the generic payment linking flow
        let mockPresenter = MockViewController()
        let completionCalledExpectation = expectation(description: "Completion Block Called")
        let completionNotCalledExpectation = expectation(description: "Completion Block NOT Called")
        completionNotCalledExpectation.isInverted = true
        var result: PaymentMethodsLinkingFlowResult?
        router.routeToPaymentMethodLinkingFlow(from: mockPresenter) { r in
            result = r
            completionCalledExpectation.fulfill()
            completionNotCalledExpectation.fulfill()
        }
        // THEN: The user is directed to the payment method selection flow
        let selectionInvocation = mockPaymentMethodsLinker.recordedInvocations.presentAccountLinkingFlow.first
        XCTAssertNotNil(selectionInvocation)
        // WHEN: The flow completes with a selection
        let stubCard = PaymentMethod(
            type: .funds(.fiat(.USD)),
            max: .create(minor: 100000, currency: .USD),
            min: .create(minor: 500, currency: .USD),
            maxDaily: nil,
            maxAnnual: nil,
            isEligible: true,
            isVisible: true
        )
        selectionInvocation?.completion(.completed(stubCard))
        // THEN: The presenter is asked to dismiss the flow (because of a memory leak)
        XCTAssertEqual(mockPresenter.recordedInvocations.dismiss.count, 1)
        mockPresenter.recordedInvocations.dismiss.first?.completion?()
        // AND: The completion called is NOT called
        wait(for: [completionNotCalledExpectation], timeout: 1)
        // AND: The payment method linking flow is presented
        let linkingInvocation = mockPaymentMethodsLinker.recordedInvocations.presentBankWireInstructions.first
        XCTAssertNotNil(linkingInvocation)
        // WHEN: The payment linking flow is complete
        linkingInvocation?.completion()
        // THEN: Finally, the completion block is called with the expected result
        wait(for: [completionCalledExpectation], timeout: 10)
        XCTAssertEqual(result, .abandoned)
    }
}

final class MockPaymentMethodsLinker: PaymentMethodLinkingSelectorAPI, BankAccountLinkerAPI, BankWireLinkerAPI, CardLinkerAPI {

    struct RecordedInvocations {

        var presentAccountLinkingFlow: [
            (
                presenter: UIViewController,
                filter: (PaymentMethodType) -> Bool,
                completion: (PaymentMethodLinkingSelectionResult) -> Void
            )
        ] = []

        var presentBankLinkingFlow: [
            (
                presenter: UIViewController,
                completion: (BankAccountLinkingFlowResult) -> Void
            )
        ] = []

        var presentBankWireInstructions: [
            (
                presenter: UIViewController,
                completion: () -> Void
            )
        ] = []

        var presentCardLinkingFlow: [
            (
                presenter: UIViewController,
                completion: (CardLinkingFlowResult) -> Void
            )
        ] = []
    }

    private(set) var recordedInvocations = RecordedInvocations()

    init() {
        // required since protocol defines an initializer
    }

    init(selectPaymentMethodService: SelectPaymentMethodService) {
        // no-op
    }

    func presentAccountLinkingFlow(
        from presenter: UIViewController,
        filter: @escaping (PaymentMethodType) -> Bool,
        completion: @escaping (PaymentMethodLinkingSelectionResult) -> Void
    ) {
        recordedInvocations.presentAccountLinkingFlow.append((presenter, filter, completion))
    }

    func presentBankLinkingFlow(
        from presenter: UIViewController,
        completion: @escaping (BankAccountLinkingFlowResult) -> Void
    ) {
        recordedInvocations.presentBankLinkingFlow.append((presenter, completion))
    }

    func presentBankWireInstructions(
        from presenter: UIViewController,
        completion: @escaping () -> Void
    ) {
        recordedInvocations.presentBankWireInstructions.append((presenter, completion))
    }

    func presentCardLinkingFlow(
        from presenter: UIViewController,
        completion: @escaping (CardLinkingFlowResult) -> Void
    ) {
        recordedInvocations.presentCardLinkingFlow.append((presenter, completion))
    }
}

extension CardData {

    static let test: CardData = CardData(
        ownerName: "Oliver",
        number: "4263982640269299",
        expirationDate: "22/27",
        cvv: ""
    )!
}
