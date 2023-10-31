// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import ComposableArchitecture
import Localization
import SwiftUI

public struct OnboardingCarouselView: View {

    @BlockchainApp var app

    private let store: Store<TourState, TourAction>
//    private let list: LivePricesList
    private var manualLoginEnabled: Bool

    public init(store: Store<TourState, TourAction>, manualLoginEnabled: Bool) {
        self.store = store
        self.manualLoginEnabled = manualLoginEnabled
//        self.list = LivePricesList(store: store)
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
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
            }
            .background(
                ZStack {
//                    list
                    Color.semantic.background.ignoresSafeArea()
                    Image("gradient", bundle: Bundle.featureTour)
                        .resizable()
                        .opacity(viewStore.gradientBackgroundOpacity)
                        .ignoresSafeArea(.all)
                }
            )
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
            VStack(spacing: Spacing.padding2) {

                FinancialPromotionDisclaimerView()
                    .padding(.bottom)

                if let image {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(height: compactDesign() ? 230 : 300)
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
//            LivePricesView(store: store, list: list)
//                .tag(TourState.Step.prices)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
    }

    @ViewBuilder private func makeButtonsView(
        _ viewStore: ViewStore<TourState, TourAction>
    ) -> some View {
        VStack(spacing: .zero) {
            Spacer()
            VStack(spacing: Spacing.padding2) {
                if manualLoginEnabled {
                    PrimaryDoubleButton(
                        leadingTitle: LocalizationConstants.Tour.createAccountButtonTitle,
                        leadingAction: {
                            $app.post(event: blockchain.ux.user.authentication.sign.up.entry.paragraph.button.primary.tap)
                            viewStore.send(.createAccount)
                        },
                        trailingTitle: LocalizationConstants.Tour.manualLoginButtonTitle,
                        trailingAction: { viewStore.send(.manualLogin) }
                    )
                } else {
                    PrimaryButton(title: LocalizationConstants.Tour.createAccountButtonTitle) {
                        $app.post(event: blockchain.ux.user.authentication.sign.up.entry.paragraph.button.primary.tap)
                        viewStore.send(.createAccount)
                    }
                }
                MinimalDoubleButton(
                    leadingTitle: LocalizationConstants.Tour.restoreButtonTitle,
                    leadingAction: {
                        $app.post(event: blockchain.ux.user.authentication.restore.entry.paragraph.button.minimal.tap)
                        viewStore.send(.restore)
                    },
                    trailingTitle: LocalizationConstants.Tour.loginButtonTitle,
                    trailingAction: {
                        $app.post(event: blockchain.ux.user.authentication.sign.in.entry.paragraph.button.minimal.tap)
                        viewStore.send(.logIn)
                    }
                )

                FinancialPromotionApprovalView()
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16).fill(Color.semantic.background)
                    )
                    .frame(maxWidth: .infinity)
                    .padding([.horizontal], Spacing.padding2)
            }
        }
        .padding(.horizontal, Spacing.padding3)
        .opacity(viewStore.gradientBackgroundOpacity)
    }
}

func compactDesign() -> Bool {
    CGRect.screen.size.max <= 667
}

struct TourView_Previews: PreviewProvider {

    static var previews: some View {
        OnboardingCarouselView(
            store: Store(
                initialState: TourState(),
                reducer: { NoOpReducer() }
            ),
            manualLoginEnabled: false
        )
    }
}
