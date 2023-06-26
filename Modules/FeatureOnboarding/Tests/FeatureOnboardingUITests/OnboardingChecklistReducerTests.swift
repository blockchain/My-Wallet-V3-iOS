// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKitMock
import BlockchainNamespace
import Combine
import ComposableArchitecture
@testable import FeatureOnboardingUI
import XCTest

@MainActor
final class OnboardingChecklistReducerTests: XCTestCase {

    private var testStore: TestStore<
        OnboardingChecklist.State,
        OnboardingChecklist.Action,
        OnboardingChecklist.State,
        OnboardingChecklist.Action,
        OnboardingChecklist.Environment
    >!
    private var testMainScheduler: ImmediateSchedulerOf<DispatchQueue>!
    private var userStateSubject: PassthroughSubject<UserState, Never>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        userStateSubject = PassthroughSubject()
        testMainScheduler = DispatchQueue.immediate
        testStore = .init(
            initialState: OnboardingChecklist.State(),
            reducer: OnboardingChecklist.reducer,
            environment: OnboardingChecklist.Environment(
                app: App.test,
                userState: userStateSubject.eraseToAnyPublisher(),
                presentBuyFlow: { [userStateSubject, testMainScheduler] completion in
                    userStateSubject?.send(.complete)
                    testMainScheduler?.schedule {
                        completion(true)
                    }
                },
                presentKYCFlow: { [userStateSubject, testMainScheduler] completion in
                    userStateSubject?.send(.kycComplete)
                    testMainScheduler?.schedule {
                        completion(true)
                    }
                },
                presentPaymentMethodLinkingFlow: { [userStateSubject, testMainScheduler] completion in
                    userStateSubject?.send(.paymentMethodsLinked)
                    testMainScheduler?.schedule {
                        completion(true)
                    }
                },
                analyticsRecorder: MockAnalyticsRecorder(),
                mainQueue: testMainScheduler.eraseToAnyScheduler()
            )
        )
    }

    override func tearDownWithError() throws {
        testStore = nil
        testMainScheduler = nil
        userStateSubject = nil
        try super.tearDownWithError()
    }

    func test_action_didSelectItem_kycCompleted_no_items_completed() async throws {
        await resetUserStateToClean()
        await testStore.send(.startObservingUserState)
        // user taps on verify identity item
        await testStore.send(.didSelectItem(.verifyIdentity, .item))
        // then they go through kyc
        await testStore.receive(.userStateDidChange(.kycComplete)) {
            $0.completedItems = [.verifyIdentity]
        }
        await testStore.send(.stopObservingUserState)
    }

    func test_action_didSelectItem_linkPaymentMethod_no_items_completed() async throws {
        await resetUserStateToClean()
        await testStore.send(.startObservingUserState)
        // user taps on verify identity item
        await testStore.send(.didSelectItem(.linkPaymentMethods, .item))
        // then they go through kyc
        // kyc is done
        await testStore.receive(.userStateDidChange(.kycComplete)) {
            $0.completedItems = [.verifyIdentity]
        }
        // then they go through linking a payment method
        await testStore.receive(.userStateDidChange(.paymentMethodsLinked)) {
            $0.completedItems = [.verifyIdentity, .linkPaymentMethod]
        }
        await testStore.send(.stopObservingUserState)
    }

    func test_action_didSelectItem_linkPaymentMethod_kyc_completed() async throws {
        await resetUserStateToKYCCompleted()
        await testStore.send(.startObservingUserState)
        // user taps on verify identity item
        await testStore.send(.didSelectItem(.linkPaymentMethods, .item))
        // then they go through linking a payment method
        await testStore.receive(.userStateDidChange(.paymentMethodsLinked)) {
            $0.completedItems = [.verifyIdentity, .linkPaymentMethod]
        }
        // then go through buy
        await testStore.receive(.userStateDidChange(.complete)) {
            $0.completedItems = [.verifyIdentity, .linkPaymentMethod, .buyCrypto]
        }
        await testStore.send(.stopObservingUserState)
    }

    func test_action_didSelectItem_buyCrypto_no_items_completed() async throws {
        await resetUserStateToClean()
        await testStore.send(.startObservingUserState)
        // user taps on verify identity item
        await testStore.send(.didSelectItem(.buyCrypto, .item))
        // then they go through kyc
        await testStore.receive(.userStateDidChange(.kycComplete)) {
            $0.completedItems = [.verifyIdentity]
        }

        // then they go through linking a payment method
        await testStore.receive(.userStateDidChange(.paymentMethodsLinked)) {
            $0.completedItems = [.verifyIdentity, .linkPaymentMethod]
        }

        // then they go through buy
        await testStore.receive(.userStateDidChange(.complete)) {
            $0.completedItems = [.verifyIdentity, .linkPaymentMethod, .buyCrypto]
        }

        await testStore.send(.stopObservingUserState)
    }

    func test_action_didSelectItem_buyCrypto_kyc_completed() async throws {
        await resetUserStateToKYCCompleted()
        await testStore.send(.startObservingUserState)
        // user taps on verify identity item
        await testStore.send(.didSelectItem(.buyCrypto, .item))
        // then they go through linking a payment method
        await testStore.receive(.userStateDidChange(.paymentMethodsLinked)) {
            $0.completedItems = [.verifyIdentity, .linkPaymentMethod]
        }
        // then they go through buy
        await testStore.receive(.userStateDidChange(.complete)) {
            $0.completedItems = [.verifyIdentity, .linkPaymentMethod, .buyCrypto]
        }

        await testStore.send(.stopObservingUserState)
    }

    func test_action_didSelectItem_buyCrypto_kyc_and_payment_completed() async throws {
        await resetUserStateToKYCAndPaymentsCompleted()
        await testStore.send(.startObservingUserState)
        // user taps on verify identity item
        await testStore.send(.didSelectItem(.buyCrypto, .item))
        // then they go through buy
        await testStore.receive(.userStateDidChange(.complete)) {
            $0.completedItems = [.verifyIdentity, .linkPaymentMethod, .buyCrypto]
        }
        await testStore.send(.stopObservingUserState)
    }

    func test_action_dismissFullScreenChecklist() async throws {
        // user taps on close
        await testStore.send(.dismissFullScreenChecklist)
        // then the full screen checklist gets dismissed
        await testStore.receive(.dismiss())
    }

    func test_action_presentFullScreenChecklist() async throws {
        // user taps on overview
        await testStore.send(.presentFullScreenChecklist)
        // then the full screen checklist gets presented
        await testStore.receive(.enter(into: .fullScreenChecklist, context: .none)) {
            $0.route = .enter(into: .fullScreenChecklist, context: .none)
        }
    }

    func test_action_startAndStopObservingUserState() async throws {
        // view is displayed and starts listening to changes
        await testStore.send(.startObservingUserState)
        // a new value is sent
        resetUserState(to: .kycComplete)
        // that new value is received
        await testStore.receive(.userStateDidChange(.kycComplete)) {
            $0.isSynchronised = true
            $0.completedItems = [.verifyIdentity]
        }
        // the view is dimissed and the values stream subscription is cancelled
        await testStore.send(.stopObservingUserState)
        // the next do block serves to ensure no further changes are listened to
    }
}

// MARK: - Helpers

extension OnboardingChecklistReducerTests {

    private func resetUserStateToClean() async {
        await testStore.send(.startObservingUserState)
        resetUserState(to: .initialState)
        await testStore.receive(.userStateDidChange(.initialState)) { state in
            state.isSynchronised = true
        }
        await testStore.send(.stopObservingUserState)
    }

    private func resetUserStateToKYCCompleted() async {
        await testStore.send(.startObservingUserState)
        resetUserState(to: .kycComplete)
        await testStore.receive(.userStateDidChange(.kycComplete)) { state in
            state.isSynchronised = true
            state.completedItems = [.verifyIdentity]
        }
        await testStore.send(.stopObservingUserState)
    }

    private func resetUserStateToKYCAndPaymentsCompleted() async {
        await testStore.send(.startObservingUserState)
        resetUserState(to: .paymentMethodsLinked)
        await testStore.receive(.userStateDidChange(.paymentMethodsLinked)) { state in
            state.isSynchronised = true
            state.completedItems = [.verifyIdentity, .linkPaymentMethod]
        }
        await testStore.send(.stopObservingUserState)
    }

    private func resetUserState(to userState: UserState) {
        userStateSubject.send(userState)
    }
}

extension UserState {

    static var initialState: UserState {
        UserState(
            kycStatus: .notVerified,
            hasLinkedPaymentMethods: false,
            hasEverPurchasedCrypto: false
        )
    }

    static var kycComplete: UserState {
        UserState(
            kycStatus: .verified,
            hasLinkedPaymentMethods: false,
            hasEverPurchasedCrypto: false
        )
    }

    static var paymentMethodsLinked: UserState {
        UserState(
            kycStatus: .verified,
            hasLinkedPaymentMethods: true,
            hasEverPurchasedCrypto: false
        )
    }

    static var complete: UserState {
        UserState(
            kycStatus: .verified,
            hasLinkedPaymentMethods: true,
            hasEverPurchasedCrypto: true
        )
    }
}
