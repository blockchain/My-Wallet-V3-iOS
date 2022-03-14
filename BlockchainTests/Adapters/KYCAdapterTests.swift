// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import Blockchain
import Combine
import FeatureKYCUI
import FeatureOnboardingUI
import PlatformKit
import PlatformUIKit
import XCTest

final class KYCAdapterTests: XCTestCase {

    private var adapter: KYCAdapter!
    private var mockRouter: MockKYCRouter!

    override func setUpWithError() throws {
        try super.setUpWithError()

        mockRouter = MockKYCRouter()
        adapter = KYCAdapter(router: mockRouter)
    }

    override func tearDownWithError() throws {
        adapter = nil
        mockRouter = nil

        try super.tearDownWithError()
    }

    func test_redirectsToRouter_for_emailVerification() {
        // WHEN: the adapter is asked to present email verification
        let _: AnyPublisher<FeatureKYCUI.FlowResult, FeatureKYCUI.RouterError> = adapter
            .presentEmailVerificationIfNeeded(from: UIViewController())
        // THEN: it should defer to the KYC Module's router to do it
        XCTAssertEqual(mockRouter.recordedInvocations.presentEmailVerificationIfNeeded.count, 1)
    }

    func test_redirectsToRouter_for_kyc() {
        // WHEN: the adapter is asked to present the kyc flow
        let _: AnyPublisher<FeatureKYCUI.FlowResult, FeatureKYCUI.RouterError> = adapter.presentKYCIfNeeded(
            from: UIViewController(),
            requiredTier: .tier2
        )
        // THEN: it should defer to the KYC Module's router to do it
        XCTAssertEqual(mockRouter.recordedInvocations.presentKYCIfNeeded.count, 1)
    }

    func test_redirectsToRouter_for_emailVerificationAndKYC() {
        // WHEN: the adapter is asked to present both email verification and the KYC flow
        let _: AnyPublisher<FeatureKYCUI.FlowResult, FeatureKYCUI.RouterError> = adapter
            .presentEmailVerificationAndKYCIfNeeded(
                from: UIViewController(),
                requireEmailVerification: false,
                requiredTier: .tier2
            )
        // THEN: it should defer to the KYC Module's router to do it
        XCTAssertEqual(mockRouter.recordedInvocations.presentEmailVerificationAndKYCIfNeeded.count, 1)
    }

    // MARK: - PlatformUIKit.KYCRouting

    func test_maps_kyc_error_emailVerificationFailed_to_complete_for_transactions() {
        // GIVEN: Email Verification fails
        mockRouter.stubbedResults.presentEmailVerificationIfNeeded = .failure(.emailVerificationFailed)
        // WHEN: the adapter is asked to present the email verification flow for Onboarding
        let publisher: AnyPublisher<KYCRoutingResult, KYCRouterError> = adapter
            .presentEmailVerificationIfNeeded(from: UIViewController())
        // THEN: The error is ignored and the onboarding flow is assumed to continue smoothly
        var error: KYCRouterError?
        let e = expectation(description: "Wait for publisher to complete")
        let cancellable = publisher.sink { completion in
            if case .failure(let theError) = completion {
                error = theError
            }
            e.fulfill()
        } receiveValue: { _ in
            // no-op: just needs to be here to compile code
        }

        wait(for: [e], timeout: 5)
        cancellable.cancel()
        XCTAssertEqual(error, .emailVerificationFailed)
    }

    func test_maps_kyc_error_kycVerificationFailed_to_complete_for_transactions() {
        // GIVEN: Email Verification or KYC fails
        mockRouter.stubbedResults.presentEmailVerificationAndKYCIfNeeded = .failure(.kycVerificationFailed)
        // WHEN: the adapter is asked to present the email verification flow for Onboarding
        let publisher: AnyPublisher<KYCRoutingResult, KYCRouterError> = adapter.presentEmailVerificationAndKYCIfNeeded(
            from: UIViewController(),
            requiredTier: .tier2
        )
        // THEN: The error is ignored and the onboarding flow is assumed to continue smoothly
        var error: KYCRouterError?
        let e = expectation(description: "Wait for publisher to complete")
        let cancellable = publisher.sink { completion in
            if case .failure(let theError) = completion {
                error = theError
            }
            e.fulfill()
        } receiveValue: { _ in
            // no-op: just needs to be here to compile code
        }

        wait(for: [e], timeout: 5)
        cancellable.cancel()
        XCTAssertEqual(error, .kycVerificationFailed)
    }

    func test_maps_kyc_error_kycStepFailed_to_complete_for_transactions() {
        // GIVEN: KYC fails
        mockRouter.stubbedResults.presentKYCIfNeeded = .failure(.kycStepFailed)
        // WHEN: the adapter is asked to present the email verification flow for Onboarding
        let publisher: AnyPublisher<KYCRoutingResult, KYCRouterError> = adapter.presentKYCIfNeeded(
            from: UIViewController(),
            requiredTier: .tier2
        )
        // THEN: The error is ignored and the onboarding flow is assumed to continue smoothly
        var error: KYCRouterError?
        let e = expectation(description: "Wait for publisher to complete")
        let cancellable = publisher.sink { completion in
            if case .failure(let theError) = completion {
                error = theError
            }
            e.fulfill()
        } receiveValue: { _ in
            // no-op: just needs to be here to compile code
        }

        wait(for: [e], timeout: 5)
        cancellable.cancel()
        XCTAssertEqual(error, .kycStepFailed)
    }

    // MARK: - FeatureOnboardingUI.KYCRouterAPI

    func test_maps_emailVerification_error_to_complete_for_onboarding() {
        // GIVEN: Email Verification fails
        mockRouter.stubbedResults.presentEmailVerificationIfNeeded = .failure(.emailVerificationFailed)
        // WHEN: the adapter is asked to present the email verification flow for Onboarding
        let publisher: AnyPublisher<OnboardingResult, Never> = adapter
            .presentEmailVerification(from: UIViewController())
        // THEN: The error is ignored and the onboarding flow is assumed to continue smoothly
        var result: OnboardingResult?
        let e = expectation(description: "Wait for publisher to complete")
        let cancellable = publisher.sink { onboardingResult in
            result = onboardingResult
            e.fulfill()
        }
        wait(for: [e], timeout: 5)
        cancellable.cancel()
        XCTAssertEqual(result, .completed)
    }

    func test_maps_emailVerification_completion_to_complete_for_onboarding() {
        // GIVEN: Email Verification fails
        mockRouter.stubbedResults.presentEmailVerificationIfNeeded = .just(.completed)
        // WHEN: the adapter is asked to present the email verification flow for Onboarding
        let publisher: AnyPublisher<OnboardingResult, Never> = adapter
            .presentEmailVerification(from: UIViewController())
        // THEN: The error is ignored and the onboarding flow is assumed to continue smoothly
        var result: OnboardingResult?
        let e = expectation(description: "Wait for publisher to complete")
        let cancellable = publisher.sink { onboardingResult in
            result = onboardingResult
            e.fulfill()
        }
        wait(for: [e], timeout: 5)
        cancellable.cancel()
        XCTAssertEqual(result, .completed)
    }

    func test_maps_emailVerification_abandoned_to_abandoned_for_onboarding() {
        // GIVEN: Email Verification fails
        mockRouter.stubbedResults.presentEmailVerificationIfNeeded = .just(.abandoned)
        // WHEN: the adapter is asked to present the email verification flow for Onboarding
        let publisher: AnyPublisher<OnboardingResult, Never> = adapter
            .presentEmailVerification(from: UIViewController())
        // THEN: The error is ignored and the onboarding flow is assumed to continue smoothly
        var result: OnboardingResult?
        let e = expectation(description: "Wait for publisher to complete")
        let cancellable = publisher.sink { onboardingResult in
            result = onboardingResult
            e.fulfill()
        }
        wait(for: [e], timeout: 5)
        cancellable.cancel()
        XCTAssertEqual(result, .abandoned)
    }
}
