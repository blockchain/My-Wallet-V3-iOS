import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import FeatureStakingDomain
import Foundation
import Localization
import SwiftUI

public struct EarnIntroView: View {
    let store: StoreOf<EarnIntro>

    public init(store: StoreOf<EarnIntro>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            PrimaryNavigationView {
                contentView
                    .primaryNavigation(trailing: {
                        Button {
                            viewStore.send(.onDismiss)
                        } label: {
                            Icon.close
                        }
                    })
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }

    private var contentView: some View {
        VStack {
            ZStack {
                carouselContentSection()
                buttonsSection()
                    .padding(.bottom, Spacing.padding6)
            }
            .background(
                ZStack {
                    Color.semantic.background.ignoresSafeArea()
                }
            )
        }
    }
}

extension EarnIntro.State.Step {
    @ViewBuilder public func makeView() -> some View {
        switch self {
        case .intro:
            carouselView(
                image: {
                    Image("earn-intro", bundle: .featureStaking)
                },
                title: LocalizationConstants.Earn.Intro.Intro.title,
                text: LocalizationConstants.Earn.Intro.Intro.description
            )
            .tag(self)
        case .passive:
            carouselView(
                image: {
                    Image("earn-intro-passive", bundle: .featureStaking)
                },
                title: LocalizationConstants.Earn.Intro.Passive.title,
                text: LocalizationConstants.Earn.Intro.Passive.description
            )
            .tag(self)
        case .staking:
            carouselView(
                image: {
                    Image("earn-intro-staking", bundle: .featureStaking)
                },
                title: LocalizationConstants.Earn.Intro.Staking.title,
                text: LocalizationConstants.Earn.Intro.Staking.description
            )
            .tag(self)
        case .active:
            carouselView(
                image: {
                    Image("earn-intro-active", bundle: .featureStaking)
                },
                title: LocalizationConstants.Earn.Intro.Active.title,
                text: LocalizationConstants.Earn.Intro.Active.description
            )
            .tag(self)
        }
    }

    @ViewBuilder private func carouselView(
        @ViewBuilder image: () -> Image,
        title: String,
        text: String,
        description: String? = nil,
        badge: String? = nil,
        badgeTint: Color? = nil
    ) -> some View {
        VStack {
            image()
            VStack(
                alignment: .center,
                spacing: Spacing.padding3
            ) {
                Text(title)
                    .lineLimit(2)
                    .typography(.title3)
                    .multilineTextAlignment(.center)
                Text(text)
                    .multilineTextAlignment(.center)
                    .frame(width: 80.vw)
                    .typography(.paragraph1)

                if let description {
                    ZStack {
                        VStack(alignment: .leading) {
                            if let badge {
                                TagView(
                                    text: badge,
                                    variant: .default,
                                    size: .small,
                                    foregroundColor: badgeTint
                                )
                            }
                            Text(description)
                                .typography(.caption1)
                                .foregroundColor(.semantic.body)
                        }
                    }
                    .padding(Spacing.padding2)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.semantic.background.opacity(0.25))
                    )
                    .shadow(
                        color: Color.black.opacity(0.12),
                        radius: 8,
                        y: 3
                    )
                }
                Spacer()
            }
            .frame(height: 300)
        }
        .padding([.leading, .bottom, .trailing], Spacing.padding3)
    }
}

extension EarnIntroView {

    @ViewBuilder private func carouselContentSection() -> some View {
        WithViewStore(store) { viewStore in
            #if os(iOS)
            TabView(
                selection: viewStore.binding(
                    get: { $0.currentStep },
                    send: { .didChangeStep($0) }
                )
            ) {
                ForEach(viewStore.steps) { step in
                    step.makeView()
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            #else
            TabView(
                selection: viewStore.binding(
                    get: { $0.currentStep },
                    send: { .didChangeStep($0) }
                )
            ) {
                ForEach(viewStore.steps) { step in
                    step.makeView()
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            #endif
        }
    }

    @ViewBuilder private func buttonsSection() -> some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: .zero) {
                Spacer()
                PageControl(
                    controls: viewStore.steps,
                    selection: viewStore.binding(
                        get: \.currentStep,
                        send: { .didChangeStep($0) }
                    )
                )
                PrimaryButton(
                    title: LocalizationConstants.Earn.Intro.button,
                    action: {
                        viewStore.send(.onDismiss)
                    }
                )
                .cornerRadius(Spacing.padding4)
                .shadow(
                    color: Color.black.opacity(0.15),
                    radius: 8,
                    y: 3
                )
            }
            .padding(.horizontal, Spacing.padding3)
            .opacity(viewStore.gradientBackgroundOpacity)
        }
    }
}

public struct EarnIntro: ReducerProtocol {

    var app: AppProtocol
    var onDismiss: () -> Void

    public init (
        app: AppProtocol,
        onDismiss: @escaping () -> Void
    ) {
        self.app = app
        self.onDismiss = onDismiss
    }

    public func reduce(into state: inout State, action: Action) -> ComposableArchitecture.EffectTask<Action> {
        switch action {
        case .onAppear:
            return .fireAndForget {
                app.state.set(blockchain.ux.earn.intro.did.show, to: true)
            }
        case .didChangeStep(let step):
            state.currentStep = step
            return .none
        case .onDismiss:
            return .fireAndForget {
                onDismiss()
            }
        }
    }

    public struct State: Equatable {
        public init(
            products: [EarnProduct]
        ) {
            self.steps = [.intro] + products.compactMap { product in
                switch product {
                case .active:
                    return .active
                case .staking:
                    return .staking
                case .savings:
                    return .passive
                default:
                    return nil
                }
            }
            self.currentStep = steps.first ?? .intro
        }

        public enum Step: Hashable, Identifiable {
            public var id: Self { self }

            case intro
            case passive
            case staking
            case active
        }

        private let scrollEffectTransitionDistance: CGFloat = 300

        var scrollOffset: CGFloat = 0
        var currentStep: Step
        var steps: [Step]

        var gradientBackgroundOpacity: Double {
            switch scrollOffset {
            case _ where scrollOffset >= 0:
                return 1
            case _ where scrollOffset <= -scrollEffectTransitionDistance:
                return 0
            default:
                return 1 - Double(scrollOffset / -scrollEffectTransitionDistance)
            }
        }
    }

    public enum Action: Equatable {
        case onAppear
        case didChangeStep(State.Step)
        case onDismiss
    }
}
