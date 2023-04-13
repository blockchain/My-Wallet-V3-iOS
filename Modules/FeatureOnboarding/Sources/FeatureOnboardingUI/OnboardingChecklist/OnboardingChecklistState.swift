// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainComponentLibrary
import BlockchainNamespace
import Combine
import ComposableArchitecture
import ComposableNavigation
import Errors
import Foundation
import Localization
import SwiftUI
import ToolKit

public enum OnboardingChecklist {

    public struct Item: Identifiable, Hashable {

        public enum Identifier: Hashable {
            case verifyIdentity
            case linkPaymentMethods
            case buyCrypto
            case requestCrypto
        }

        public let id: Identifier
        public let icon: Icon
        public let title: String
        public let detail: String?
        public let actionColor: Color
        public let accentColor: Color
        public let backgroundColor: Color
    }

    public enum Route: NavigationRoute {
        case fullScreenChecklist

        @ViewBuilder
        public func destination(in store: Store<State, Action>) -> some View {
            switch self {
            case .fullScreenChecklist:
                OnboardingChecklistView(store: store)
            }
        }
    }

    public struct State: Equatable, NavigationState {

        public struct Promotion: Equatable {

            public var visible: Bool
            public var id: L & I_blockchain_ux_onboarding_type_promotion
            public var ux: UX.Dialog

            public static func == (lhs: OnboardingChecklist.State.Promotion, rhs: OnboardingChecklist.State.Promotion) -> Bool {
                lhs.visible == rhs.visible
                    && lhs.id == rhs.id
                    && lhs.ux == rhs.ux
            }
        }

        var promotion: Promotion?
        var isSynchronised: Bool = false
        var items: [Item]
        var pendingItems: Set<Item>
        var completedItems: Set<Item>
        public var route: RouteIntent<Route>?

        public init() {
            self.items = OnboardingChecklist.allItems
            self.pendingItems = []
            self.completedItems = []
        }

        func hasCompleted(_ item: Item) -> Bool {
            completedItems.contains(item)
        }

        var firstIncompleteItem: Item? {
            items.first { !hasCompleted($0) }
        }
    }

    public enum ItemSelectionSource {
        case item
        case callToActionButton
    }

    public enum Action: Equatable, NavigationAction {
        case route(RouteIntent<Route>?)
        case didSelectItem(Item.Identifier, ItemSelectionSource)
        case dismissFullScreenChecklist
        case presentFullScreenChecklist
        case startObservingUserState
        case stopObservingUserState
        case userStateDidChange(UserState)
        case updatePromotion
        case updatedPromotion(State.Promotion?)
    }

    public struct Environment {

        let app: AppProtocol
        /// A publisher that streams `UserState` values on subscription and every time the state changes
        let userState: AnyPublisher<UserState, Never>
        /// A closure that presents the Buy Flow from the top-most view controller on screen and automatically dismissed the presented flow when done.
        /// The closure takes a `completion` closure. Call it with `true` if the user completed the presented flow by taking the desired action. Call it with `false` if the flow was dismissed by the user.
        /// This should really return a `View` and be used to generate a `RouteIntent`, but we don't have such a `View` yet or the flow is complex.
        let presentBuyFlow: (@escaping (Bool) -> Void) -> Void
        /// A closure that presents the KYC Flow from the top-most view controller on screen and automatically dismissed the presented flow when done.
        /// The closure takes a `completion` closure. Call it with `true` if the user completed the presented flow by taking the desired action. Call it with `false` if the flow was dismissed by the user.
        /// This should really return a `View` and be used to generate a `RouteIntent`, but we don't have such a `View` yet or the flow is complex.
        let presentKYCFlow: (@escaping (Bool) -> Void) -> Void
        /// A closure that presents the Payment Method Linking Flow from the top-most view controller on screen and automatically dismissed the presented flow when done.
        /// The closure takes a `completion` closure. Call it with `true` if the user completed the presented flow by taking the desired action. Call it with `false` if the flow was dismissed by the user.
        /// This should really return a `View` and be used to generate a `RouteIntent`, but we don't have such a `View` yet or the flow is complex.
        let presentPaymentMethodLinkingFlow: (@escaping (Bool) -> Void) -> Void
        /// A `DispatchQueue` running on the main thread.
        let mainQueue: AnySchedulerOf<DispatchQueue>

        let analyticsRecorder: AnalyticsEventRecorderAPI

        public init(
            app: AppProtocol,
            userState: AnyPublisher<UserState, Never>,
            presentBuyFlow: @escaping (@escaping (Bool) -> Void) -> Void,
            presentKYCFlow: @escaping (@escaping (Bool) -> Void) -> Void,
            presentPaymentMethodLinkingFlow: @escaping (@escaping (Bool) -> Void) -> Void,
            analyticsRecorder: AnalyticsEventRecorderAPI,
            mainQueue: AnySchedulerOf<DispatchQueue> = .main
        ) {
            self.app = app
            self.userState = userState
            self.presentBuyFlow = presentBuyFlow
            self.presentKYCFlow = presentKYCFlow
            self.presentPaymentMethodLinkingFlow = presentPaymentMethodLinkingFlow
            self.analyticsRecorder = analyticsRecorder
            self.mainQueue = mainQueue
        }
    }

    public static let reducer = Reducer<State, Action, Environment> { state, action, environment in

        struct UserStateObservableIdentifier: Hashable {}
        struct UserDidUpdateIdentifier: Hashable {}
        struct PromotionIdentifier: Hashable {}

        switch action {
        case .route(let route):
            state.route = route
            return .none

        case .didSelectItem(let item, _):
            let completedItems = state.completedItems
            return .fireAndForget {
                environment.presentOnboaringFlow(upTo: item, completedItems: completedItems)
            }

        case .dismissFullScreenChecklist:
            return .dismiss()

        case .presentFullScreenChecklist:
            return .enter(into: .fullScreenChecklist, context: .none)

        case .startObservingUserState:
            return .merge(
                .concatenate(
                    .cancel(id: UserDidUpdateIdentifier()),
                    environment.app.on(blockchain.user.event.did.update)
                        .receive(on: environment.mainQueue)
                        .eraseToEffect { _ in OnboardingChecklist.Action.updatePromotion }
                        .cancellable(id: UserDidUpdateIdentifier())
                ),
                .concatenate(
                    // cancel any active observation of state to avoid duplicates
                    .cancel(id: UserStateObservableIdentifier()),
                    // start observing the user state
                    environment
                        .userState
                        .receive(on: environment.mainQueue)
                        .map(OnboardingChecklist.Action.userStateDidChange)
                        .eraseToEffect()
                        .cancellable(id: UserStateObservableIdentifier())
                )
            )

        case .stopObservingUserState:
            return .cancel(
                ids: [UserStateObservableIdentifier(), UserDidUpdateIdentifier(), PromotionIdentifier()]
            )

        case .userStateDidChange(let userState):
            state.isSynchronised = true
            state.completedItems = userState.completedOnboardingChecklistItems
            state.pendingItems = userState.kycStatus == .verificationPending ? [.verifyIdentity] : []
            return EffectTask(value: .updatePromotion)

        case .updatePromotion:
            return .concatenate(
                .cancel(id: PromotionIdentifier()),
                .task(priority: .userInitiated) { @MainActor in
                    do {
                        let app = environment.app
                        let promotion: L & I_blockchain_ux_onboarding_type_promotion = try {
                            switch try app.state.get(blockchain.user.account.tier) as Tag {
                            case blockchain.user.account.tier.none:
                                return try app.state.get(blockchain.user.email.is.verified)
                                    ? blockchain.ux.onboarding.promotion.cowboys.raffle
                                    : blockchain.ux.onboarding.promotion.cowboys.welcome
                            case _:
                                return blockchain.ux.onboarding.promotion.cowboys.refer.friends
                            }
                        }()
                        let isEnabled: Bool = try await app.get(blockchain.ux.onboarding.promotion.cowboys.is.enabled)
                        return try await .updatedPromotion(
                            State.Promotion(
                                visible: app.get(blockchain.user.is.cowboy.fan) && isEnabled,
                                id: promotion,
                                ux: app.get(promotion.announcement)
                            )
                        )
                    } catch {
                        return .updatedPromotion(nil)
                    }
                }
                .cancellable(id: PromotionIdentifier())
            )
        case .updatedPromotion(let promotion):
            state.promotion = promotion
            return .none
        }
    }
    .analytics()
}

extension OnboardingChecklist.Environment {

    // swiftlint:disable:next cyclomatic_complexity
    fileprivate func presentOnboaringFlow(
        upTo item: OnboardingChecklist.Item.Identifier,
        completedItems: Set<OnboardingChecklist.Item>
    ) {
        switch item {
        case .verifyIdentity:
            presentKYCFlow { _ in
                // no-op: flow ends here
            }

        case .linkPaymentMethods:
            if completedItems.contains(.verifyIdentity) {
                presentPaymentMethodLinkingFlow { [presentBuyFlow] didCompleteLinking in
                    guard didCompleteLinking else { return }
                    presentBuyFlow { _ in
                        // no-op: flow ends here
                    }
                }
            } else {
                presentKYCFlow { [presentPaymentMethodLinkingFlow] didCompleteKYC in
                    guard didCompleteKYC else { return }
                    presentPaymentMethodLinkingFlow { _ in
                        // no-op: flow ends here
                    }
                }
            }

        case .buyCrypto:
            if completedItems.contains(.linkPaymentMethod) {
                presentBuyFlow { _ in
                    // no-op: flow ends here
                }
            } else if completedItems.contains(.verifyIdentity) {
                presentPaymentMethodLinkingFlow { [presentBuyFlow] didAddPaymentMethod in
                    guard didAddPaymentMethod else { return }
                    presentBuyFlow { _ in
                        // no-op: flow ends here
                    }
                }
            } else {
                presentKYCFlow { [presentPaymentMethodLinkingFlow, presentBuyFlow] didCompleteKYC in
                    guard didCompleteKYC else { return }
                    presentPaymentMethodLinkingFlow { didAddPaymentMethod in
                        guard didAddPaymentMethod else { return }
                        presentBuyFlow { _ in
                            // no-op: flow ends here
                        }
                    }
                }
            }

        default:
            unimplemented()
        }
    }
}

extension OnboardingChecklist.Item {

    var pendingDetail: String {
        LocalizationConstants.Onboarding.Checklist.pendingPlaceholder
    }
}

extension OnboardingChecklist.Item {

    static let verifyIdentity = OnboardingChecklist.Item(
        id: .verifyIdentity,
        icon: Icon.identification,
        title: LocalizationConstants.Onboarding.Checklist.verifyIdentityTitle,
        detail: LocalizationConstants.Onboarding.Checklist.verifyIdentitySubtitle,
        actionColor: .purple500,
        accentColor: .purple600,
        backgroundColor: .purple000
    )

    static let linkPaymentMethod = OnboardingChecklist.Item(
        id: .linkPaymentMethods,
        icon: Icon.bank,
        title: LocalizationConstants.Onboarding.Checklist.linkPaymentMethodsTitle,
        detail: LocalizationConstants.Onboarding.Checklist.linkPaymentMethodsSubtitle,
        actionColor: .semantic.primary,
        accentColor: .semantic.primary,
        backgroundColor: .semantic.blueBG
    )

    static let buyCrypto = OnboardingChecklist.Item(
        id: .buyCrypto,
        icon: Icon.cart,
        title: LocalizationConstants.Onboarding.Checklist.buyCryptoTitle,
        detail: LocalizationConstants.Onboarding.Checklist.buyCryptoSubtitle,
        actionColor: .semantic.success,
        accentColor: .semantic.success,
        backgroundColor: .semantic.greenBG
    )

    static let buyCryptoAlternative = OnboardingChecklist.Item(
        id: .buyCrypto,
        icon: Icon.cart,
        title: LocalizationConstants.Onboarding.Checklist.buyCryptoTitle,
        detail: nil,
        actionColor: .semantic.primary,
        accentColor: .semantic.primary,
        backgroundColor: .semantic.blueBG
    )

    static let requestCrypto = OnboardingChecklist.Item(
        id: .requestCrypto,
        icon: Icon.qrCode,
        title: LocalizationConstants.Onboarding.Checklist.requestCryptoTitle,
        detail: LocalizationConstants.Onboarding.Checklist.requestCryptoSubtitle,
        actionColor: .teal500,
        accentColor: .teal500,
        backgroundColor: .teal000
    )
}

extension OnboardingChecklist {

    fileprivate static let allItems: [OnboardingChecklist.Item] = [
        .verifyIdentity,
        .linkPaymentMethod,
        .buyCrypto
    ]
}

extension Color {

    fileprivate static let purple000 = Color(
        red: 239 / 255,
        green: 236 / 255,
        blue: 254 / 255
    )

    fileprivate static let purple500 = Color(
        red: 115 / 255,
        green: 73 / 255,
        blue: 242 / 255
    )

    fileprivate static let purple600 = Color(
        red: 83 / 255,
        green: 34 / 255,
        blue: 229 / 255
    )

    fileprivate static let teal000 = Color(
        red: 230 / 255,
        green: 248 / 255,
        blue: 250 / 255
    )

    fileprivate static let teal500 = Color(
        red: 18 / 255,
        green: 165 / 255,
        blue: 178 / 255
    )
}

extension UserState {

    fileprivate var completedOnboardingChecklistItems: Set<OnboardingChecklist.Item> {
        var result = Set<OnboardingChecklist.Item>()
        if kycStatus == .verified {
            result.insert(.verifyIdentity)
        }
        if hasLinkedPaymentMethods {
            result.insert(.linkPaymentMethod)
        }
        if hasEverPurchasedCrypto {
            result.insert(.buyCrypto)
        }
        return result
    }

    private var hasCompletedAllOnboardingChecklistItems: Bool {
        completedOnboardingChecklistItems == Set(OnboardingChecklist.allItems)
    }
}
