import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import Localization
import SwiftUI

public struct FeatureSuperAppIntroView: View {
    let store: StoreOf<FeatureSuperAppIntro>

    public init(store: StoreOf<FeatureSuperAppIntro>) {
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
        }
    }

    private var contentView: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                ZStack {
                    carouselContentSection()
                    buttonsSection()
                        .padding(.bottom, Spacing.padding6)
                }
                .background(
                    ZStack {
                        Color.white.ignoresSafeArea()
                        Image("gradient", bundle: .featureSuperAppIntro)
                            .resizable()
                            .opacity(viewStore.gradientBackgroundOpacity)
                            .ignoresSafeArea(.all)
                    }
                )
            }
        }
    }
}

extension FeatureSuperAppIntro.State.Step {
    @ViewBuilder public func makeView() -> some View {
        switch self {
        case .welcomeNewUserV1:
            carouselView(
                image: {
                    Image("icon_blockchain_white", bundle: .featureSuperAppIntro)
                },
                title: LocalizationConstants.SuperAppIntro.V1.NewUser.title,
                text: LocalizationConstants.SuperAppIntro.V1.NewUser.subtitle,
                description: LocalizationConstants.SuperAppIntro.V1.NewUser.description
            )
            .tag(self)
        case .welcomeExistingUserV1:
            carouselView(
                image: {
                    Image("superAppIntroV1ExistingUser", bundle: .featureSuperAppIntro)
                },
                title: LocalizationConstants.SuperAppIntro.V1.ExistingUser.title,
                text: LocalizationConstants.SuperAppIntro.V1.ExistingUser.subtitle
            )
            .tag(self)
        case .tradingAccountV1:
            carouselView(
                image: {
                    Image("superAppIntroV1Trading", bundle: .featureSuperAppIntro)
                },
                title: LocalizationConstants.SuperAppIntro.V1.TradingAccount.title,
                text: LocalizationConstants.SuperAppIntro.V1.TradingAccount.subtitle,
                description: LocalizationConstants.SuperAppIntro.V1.TradingAccount.description,
                badge: LocalizationConstants.SuperAppIntro.V1.TradingAccount.badge,
                badgeTint: .semantic.primary
            )
            .tag(self)
        case .defiWalletV1:
            carouselView(
                image: {
                    Image("superAppIntroV1Defi", bundle: .featureSuperAppIntro)
                },
                title: LocalizationConstants.SuperAppIntro.V1.DefiWallet.title,
                text: LocalizationConstants.SuperAppIntro.V1.DefiWallet.subtitle,
                description: LocalizationConstants.SuperAppIntro.V1.DefiWallet.description,
                badge: LocalizationConstants.SuperAppIntro.V1.DefiWallet.badge,
                badgeTint: .semantic.defi
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
            // Image
            VStack {
                image()
                    .resizable()
                    .scaledToFit()
            }
            .frame(height: min(300, UIScreen.main.bounds.height * 0.35))

            // Labels
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
                            .fill(.white.opacity(0.25))
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

extension FeatureSuperAppIntroView {

    @ViewBuilder private func carouselContentSection() -> some View {
        WithViewStore(store) { viewStore in
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
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        }
    }

    @ViewBuilder private func buttonsSection() -> some View {
        WithViewStore(store) { viewStore in
            if viewStore.currentStep == viewStore.steps.last {
                VStack(spacing: .zero) {
                    Spacer()
                    PrimaryWhiteButton(
                        title: LocalizationConstants.SuperAppIntro.V1.Button.title,
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
            } else if viewStore.currentStep == viewStore.steps.first {
                VStack(spacing: .zero) {
                    Spacer()
                    Text(LocalizationConstants.SuperAppIntro.V1.swipeToContinue)
                        .typography(.body2)
                        .foregroundColor(.white.opacity(0.4))
                }
            } else {
                EmptyView()
            }
        }
    }
}

struct FeatureSuperAppIntroView_Previews: PreviewProvider {
    static var previews: some View {
        FeatureSuperAppIntroView(
            store: Store(
                initialState: .init(flow: .newUser),
                reducer: FeatureSuperAppIntro(onDismiss: {})
            )
        )
    }
}

extension AppMode {
    public var displayName: String {
        switch self {
        case .pkw:
            return LocalizationConstants.AppMode.privateKeyWallet
        case .trading:
            return LocalizationConstants.AppMode.tradingAccount
        case .universal:
            return ""
        }
    }
}

extension FeatureSuperAppIntro.State.Flow {
    fileprivate var buttonTitle: String {
        LocalizationConstants.SuperAppIntro.V1.Button.title
    }
}
