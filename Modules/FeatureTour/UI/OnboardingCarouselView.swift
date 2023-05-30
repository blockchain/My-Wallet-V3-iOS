// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import Localization
import PlatformUIKit
import SwiftUI

public struct OnboardingCarouselView: View {

    private let store: Store<TourState, TourAction>
    private let list: LivePricesList
    private var manualLoginEnabled: Bool

    private init(store: Store<TourState, TourAction>, manualLoginEnabled: Bool) {
        self.store = store
        self.manualLoginEnabled = manualLoginEnabled
        self.list = LivePricesList(store: store)
    }

    public init(environment: TourEnvironment, manualLoginEnabled: Bool) {
        self.init(
            store: Store(
                initialState: TourState(),
                reducer: tourReducer,
                environment: environment
            ),
            manualLoginEnabled: manualLoginEnabled
        )
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Image("logo-blockchain-black", bundle: Bundle.featureTour)
                    .padding([.top, .horizontal], Spacing.padding3)
                    .padding(.bottom, Spacing.padding2)
                ZStack {
                    makeTabView(viewStore)
                    makeButtonsView(viewStore)
                        // space for page indicators
                        .padding(.bottom, Spacing.padding6)
                }
                .background(
                    ZStack {
                        list
                        Color.semantic.background.ignoresSafeArea()
                        Image("gradient", bundle: Bundle.featureTour)
                            .resizable()
                            .opacity(viewStore.gradientBackgroundOpacity)
                            .ignoresSafeArea(.all)
                    }
                )
            }
            .onAppear {
                viewStore.send(.loadPrices)
            }
        }
    }
}

extension OnboardingCarouselView {

    public enum Carousel {
        case brokerage
        case earn
        case keys

        @ViewBuilder public func makeView() -> some View {
            switch self {
            case .brokerage:
                makeCarouselView(
                    image: Image("carousel-brokerage", bundle: Bundle.featureTour),
                    text: LocalizationConstants.Tour.carouselBrokerageScreenMessage
                )
            case .earn:
                makeCarouselView(
                    image: Image("carousel-rewards", bundle: Bundle.featureTour),
                    text: LocalizationConstants.Tour.carouselEarnScreenMessage
                )
            case .keys:
                makeCarouselView(
                    image: Image("carousel-security", bundle: Bundle.featureTour),
                    text: LocalizationConstants.Tour.carouselKeysScreenMessage
                )
            }
        }

        @ViewBuilder private func makeCarouselView(image: Image?, text: String) -> some View {
            let isSmallDevice = DevicePresenter.type <= .compact
            VStack(spacing: Spacing.padding2) {
                if let image {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(height: isSmallDevice ? 230 : 300)
                }

                Text(text)
                    .multilineTextAlignment(.center)
                    .frame(width: 200.0)
                    .typography(.title3)
                    .foregroundColor(.semantic.title)

                Spacer()
            }
        }
    }

    @ViewBuilder private func makeTabView(
        _ viewStore: ViewStore<TourState, TourAction>
    ) -> some View {
        TabView(
            selection: viewStore.binding(
                get: { $0.visibleStep },
                send: { .didChangeStep($0) }
            )
        ) {
            Carousel.brokerage.makeView()
                .tag(TourState.Step.brokerage)
            Carousel.earn.makeView()
                .tag(TourState.Step.earn)
            Carousel.keys.makeView()
                .tag(TourState.Step.keys)
            LivePricesView(store: store, list: list)
                .tag(TourState.Step.prices)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
    }

    @ViewBuilder private func makeButtonsView(
        _ viewStore: ViewStore<TourState, TourAction>
    ) -> some View {
        VStack(spacing: .zero) {
            Spacer()
            VStack(spacing: Spacing.padding2) {
                PrimaryButton(title: LocalizationConstants.Tour.createAccountButtonTitle) {
                    viewStore.send(.createAccount)
                }
                if manualLoginEnabled {
                    SecondaryButton(title: LocalizationConstants.Tour.manualLoginButtonTitle) {
                        viewStore.send(.manualLogin)
                    }
                }
                MinimalDoubleButton(
                    leadingTitle: LocalizationConstants.Tour.restoreButtonTitle,
                    leadingAction: { viewStore.send(.restore) },
                    trailingTitle: LocalizationConstants.Tour.loginButtonTitle,
                    trailingAction: { viewStore.send(.logIn) }
                )
            }
        }
        .padding(.horizontal, Spacing.padding3)
        .opacity(viewStore.gradientBackgroundOpacity)
    }
}

struct TourView_Previews: PreviewProvider {

    static var previews: some View {
        OnboardingCarouselView(
            environment: TourEnvironment(
                createAccountAction: {},
                restoreAction: {},
                logInAction: {},
                manualLoginAction: {}
            ),
            manualLoginEnabled: false
        )
    }
}
