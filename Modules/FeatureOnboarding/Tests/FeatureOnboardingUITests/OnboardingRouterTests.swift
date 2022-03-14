// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import CombineSchedulers
@testable import FeatureOnboardingUI
@testable import PlatformUIKitMock
import SwiftUI
import TestKit
import ToolKit
@testable import ToolKitMock
import XCTest

final class OnboardingRouterTests: XCTestCase {

    private var router: OnboardingRouter!
    private var mockBuyCryptoRouter: MockBuyCryptoRouter!
    private var mockFeatureFlagService: MockFeatureFlagsService!
    private var mockEmailVerificationRouter: MockOnboardingEmailVerificationRouter!
    private var testMainQueue: TestSchedulerOf<DispatchQueue>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        testMainQueue = DispatchQueue.test
        mockBuyCryptoRouter = MockBuyCryptoRouter()
        mockFeatureFlagService = MockFeatureFlagsService()
        mockEmailVerificationRouter = MockOnboardingEmailVerificationRouter()
        router = OnboardingRouter(
            kycRouter: mockEmailVerificationRouter,
            transactionsRouter: mockBuyCryptoRouter,
            featureFlagsService: mockFeatureFlagService,
            mainQueue: testMainQueue.eraseToAnyScheduler()
        )
    }

    override func tearDownWithError() throws {
        router = nil
        testMainQueue = nil
        mockBuyCryptoRouter = nil
        mockFeatureFlagService = nil
        mockEmailVerificationRouter = nil
        try super.tearDownWithError()
    }

    func test_skipsEmailVerification_if_feature_is_disabled_then_presents_ui_tour() throws {
        // GIVEN: Email Verification at Onboarding is DISABLED
        let featureFlagPublisher = mockFeatureFlagService.disable(.remote(.showEmailVerificationInOnboarding))
        XCTAssertPublisherCompletion(featureFlagPublisher)

        // WHEN: The OnboardingRouter is asked to present onboarding
        let mockViewController = MockViewController()
        let routingResultPublisher = router.presentPostSignUpOnboarding(from: mockViewController)
        var result: OnboardingResult?
        let completionExpectation = expectation(description: "Onboarding Completes")
        let cancellable = routingResultPublisher.sink { publisherResult in
            result = publisherResult
            completionExpectation.fulfill()
        }

        // advance scheduler to allow for feature flag to be checked
        testMainQueue.advance()

        // THEN: Email Verification IS NOT presented
        XCTAssertEqual(mockEmailVerificationRouter.recordedInvocations.presentEmailVerification.count, 0)

        // AND: The UI Tour is presented instead
        let presentedViewController = mockViewController.recordedInvocations.presentViewController.first
        let onboardingTour = presentedViewController as? UIHostingController<UITourView>
        XCTAssertNotNil(onboardingTour)

        // WHEN: The tour is closed
        onboardingTour?.rootView.close()

        // THEN: The onboarding presentation publisher completes
        wait(for: [completionExpectation], timeout: 10)
        XCTAssertEqual(result, .abandoned)
        cancellable.cancel()
    }

    func test_skipsEmailVerification_if_feature_is_enabled_then_presents_ui_tour_ev_completed() throws {
        // GIVEN: Email Verification at Onboarding is ENABLED
        let featureFlagPublisher = mockFeatureFlagService.enable(.remote(.showEmailVerificationInOnboarding))
        XCTAssertPublisherCompletion(featureFlagPublisher)

        // AND: A mock email verification publisher
        let mockEVSubject = PassthroughSubject<OnboardingResult, Never>()
        mockEmailVerificationRouter.stubbedResults.presentEmailVerification = mockEVSubject.eraseToAnyPublisher()

        // WHEN: The OnboardingRouter is asked to present onboarding
        let mockViewController = MockViewController()
        let routingResultPublisher = router.presentPostSignUpOnboarding(from: mockViewController)
        var result: OnboardingResult?
        let completionExpectation = expectation(description: "Onboarding Completes")
        let cancellable = routingResultPublisher.sink { publisherResult in
            result = publisherResult
            completionExpectation.fulfill()
        }

        // advance scheduler to allow for feature flag to be checked
        testMainQueue.advance()

        // THEN: Email Verification IS presented
        let emailVerification = mockEmailVerificationRouter.recordedInvocations.presentEmailVerification.first
        XCTAssertNotNil(emailVerification)

        // WHEN: Email Verification completes successfully
        mockEVSubject.send(.completed)
        mockEVSubject.send(completion: .finished)

        // THEN: The UI Tour is presented instead
        let presentedViewController = mockViewController.recordedInvocations.presentViewController.first
        let onboardingTour = presentedViewController as? UIHostingController<UITourView>
        XCTAssertNotNil(onboardingTour)

        // WHEN: The tour is closed
        onboardingTour?.rootView.close()

        // THEN: The onboarding presentation publisher completes
        wait(for: [completionExpectation], timeout: 10)
        XCTAssertEqual(result, .abandoned)
        cancellable.cancel()
    }

    func test_showsEmailVerification_if_feature_is_enabled_then_presents_ui_tour_ev_abandoned() throws {
        // GIVEN: Email Verification at Onboarding is ENABLED
        let featureFlagPublisher = mockFeatureFlagService.enable(.remote(.showEmailVerificationInOnboarding))
        XCTAssertPublisherCompletion(featureFlagPublisher)

        // AND: A mock email verification publisher
        let mockEVSubject = PassthroughSubject<OnboardingResult, Never>()
        mockEmailVerificationRouter.stubbedResults.presentEmailVerification = mockEVSubject.eraseToAnyPublisher()

        // WHEN: The OnboardingRouter is asked to present onboarding
        let mockViewController = MockViewController()
        let routingResultPublisher = router.presentPostSignUpOnboarding(from: mockViewController)
        var result: OnboardingResult?
        let completionExpectation = expectation(description: "Onboarding Completes")
        let cancellable = routingResultPublisher.sink { publisherResult in
            result = publisherResult
            completionExpectation.fulfill()
        }

        // advance scheduler to allow for feature flag to be checked
        testMainQueue.advance()

        // THEN: Email Verification IS presented
        let emailVerification = mockEmailVerificationRouter.recordedInvocations.presentEmailVerification.first
        XCTAssertNotNil(emailVerification)

        // WHEN: Email Verification is abandoned
        mockEVSubject.send(.abandoned)
        mockEVSubject.send(completion: .finished)

        // THEN: The UI Tour is presented instead
        let presentedViewController = mockViewController.recordedInvocations.presentViewController.first
        let onboardingTour = presentedViewController as? UIHostingController<UITourView>
        XCTAssertNotNil(onboardingTour)

        // WHEN: The tour is closed
        onboardingTour?.rootView.close()

        // THEN: The onboarding presentation publisher completes
        wait(for: [completionExpectation], timeout: 10)
        XCTAssertEqual(result, .abandoned)
        cancellable.cancel()
    }

    func test_showsEmailVerification_if_feature_is_enabled_then_presents_ui_tour_then_buy() throws {
        // GIVEN: Email Verification at Onboarding is ENABLED
        let featureFlagPublisher = mockFeatureFlagService.enable(.remote(.showEmailVerificationInOnboarding))
        XCTAssertPublisherCompletion(featureFlagPublisher)

        // AND: A mock email verification publisher
        let mockEVSubject = PassthroughSubject<OnboardingResult, Never>()
        mockEmailVerificationRouter.stubbedResults.presentEmailVerification = mockEVSubject.eraseToAnyPublisher()

        // AND: a mock buy transaction publisher
        let mockBuySubject = PassthroughSubject<OnboardingResult, Never>()
        mockBuyCryptoRouter.stubbedResults.presentBuyFlow = mockBuySubject.eraseToAnyPublisher()

        // WHEN: The OnboardingRouter is asked to present onboarding
        let mockViewController = MockViewController()
        let routingResultPublisher = router.presentPostSignUpOnboarding(from: mockViewController)
        var result: OnboardingResult?
        let completionExpectation = expectation(description: "Onboarding Completes")
        let cancellable = routingResultPublisher.sink { publisherResult in
            result = publisherResult
            completionExpectation.fulfill()
        }

        // advance scheduler to allow for feature flag to be checked
        testMainQueue.advance()

        // THEN: Email Verification IS presented
        let emailVerification = mockEmailVerificationRouter.recordedInvocations.presentEmailVerification.first
        XCTAssertNotNil(emailVerification)

        // WHEN: Email Verification completes successfully
        mockEVSubject.send(.completed)
        mockEVSubject.send(completion: .finished)

        // THEN: The UI Tour is presented instead
        let presentedViewController = mockViewController.recordedInvocations.presentViewController.first
        let onboardingTour = presentedViewController as? UIHostingController<UITourView>
        XCTAssertNotNil(onboardingTour)

        // WHEN: The tour is completed
        onboardingTour?.rootView.completion()

        // THEN: The UI Tour is dismissed
        let waitExpectation = expectation(description: "Wait for Deferred Future to execute")
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: waitExpectation.fulfill)
        wait(for: [waitExpectation], timeout: 10)
        mockViewController.recordedInvocations.dismiss.last?.completion?()

        // AND: The buy flow is presented
        let buy = mockBuyCryptoRouter.recordedInvocations.presentBuyFlow.first
        XCTAssertNotNil(buy)

        // WHEN: Buy is done
        mockBuySubject.send(.completed)
        mockBuySubject.send(completion: .finished)

        // THEN: The onboarding presentation publisher completes
        wait(for: [completionExpectation], timeout: 10)
        XCTAssertEqual(result, .completed)
        cancellable.cancel()
    }
}
