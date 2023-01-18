import BlockchainComponentLibrary
import ComposableArchitecture
import FeatureSettingsUI
import Localization
import SwiftUI


public struct DefiWalletIntro: ReducerProtocol {
    var onDismiss: () -> Void
    var onGetStartedTapped: () -> Void

    public struct State: Equatable {}
    public enum Action: Equatable {
        case onBackupSeedPhraseSkip
        case onEnableDefiTap
        case onBackupSeedPhraseComplete
        case onCloseTapped
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onCloseTapped:
                onDismiss()
                return .none
            case .onEnableDefiTap:
                onGetStartedTapped()
                return .none
            default:
                return .none
            }
        }
    }
}

public struct DefiWalletIntroView: View {
    let store: StoreOf<DefiWalletIntro>
    @ObservedObject var viewStore: ViewStoreOf<DefiWalletIntro>

    public init(store: StoreOf<DefiWalletIntro>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    public var body: some View {
        VStack {
            ScrollView {
                Image("icon-defiWallet-intro")
                    .frame(height: 164)
                    .padding(.horizontal, Spacing.padding3)
                    .padding(.top, 70)

                VStack(spacing: 8) {
                    Text(LocalizationConstants.DefiWalletIntro.title)
                        .typography(.title3)
                        .multilineTextAlignment(.center)
                    Text(LocalizationConstants.DefiWalletIntro.subtitle)
                        .typography(.paragraph1)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                .padding(.horizontal, Spacing.padding3)

                VStack(spacing: 8) {
                    introRow(
                        number: 1,
                        title: LocalizationConstants.DefiWalletIntro.step1Title,
                        subtitle: LocalizationConstants.DefiWalletIntro.step1Subtitle
                    )
                    introRow(
                        number: 2,
                        title: LocalizationConstants.DefiWalletIntro.step2Title,
                        subtitle: LocalizationConstants.DefiWalletIntro.step2Subtitle
                    )
                    introRow(
                        number: 3,
                        title: LocalizationConstants.DefiWalletIntro.step3Title,
                        subtitle: LocalizationConstants.DefiWalletIntro.step3Subtitle
                    )
                }
                .padding(.top, Spacing.padding4)
                .padding(.horizontal, Spacing.padding3)
            }

            Spacer()

            PrimaryButton(title: LocalizationConstants.DefiWalletIntro.enableButton) {
                viewStore.send(.onEnableDefiTap)
            }
            .padding(.horizontal, Spacing.padding3)
            .padding(.bottom, Spacing.padding2)
        }
        .trailingNavigationButton(.close) {
            viewStore.send(.onCloseTapped)
        }
        .ignoresSafeArea(.all, edges: .top)
    }

    @ViewBuilder private func introRow(
        number: Int,
        title: String,
        subtitle: String
    ) -> some View {
        PrimaryRow(
            title: title,
            subtitle: subtitle,
            leading: {
                numberView(with: number)
            },
            trailing: {
                EmptyView()
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.WalletSemantic.light, lineWidth: 1)
        )
    }

    @ViewBuilder private func numberView(with number: Int) -> some View {
        Text("\(number)")
            .typography(.body2)
            .foregroundColor(Color.WalletSemantic.primary)
            .padding(12)
            .background(Color.WalletSemantic.blueBG)
            .clipShape(Circle())
    }
}
