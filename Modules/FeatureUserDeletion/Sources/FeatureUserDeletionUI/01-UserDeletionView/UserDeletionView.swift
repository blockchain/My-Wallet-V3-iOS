import BlockchainComponentLibrary
import ComposableArchitecture
import ComposableNavigation
import Localization
import SwiftUI
import UIComponentsKit

// TODO: Analytics (next release)
// TODO: acessibility identifiers (next release)

private typealias LocalizedString = LocalizationConstants.UserDeletion.MainScreen

public struct UserDeletionView: View {
    let store: Store<UserDeletionState, UserDeletionAction>
    @Environment(\.openURL) private var openURL
    @Environment(\.presentationMode) var presentationMode

    @ObservedObject var viewStore: ViewStore<UserDeletionState, UserDeletionAction>

    public init(store: Store<UserDeletionState, UserDeletionAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    public var body: some View {
        PrimaryNavigationView {
            GeometryReader { (proxy: GeometryProxy) in
                ScrollView {
                    contentView
                        .frame(height: proxy.size.height)
                }
                .navigationRoute(in: store)
                .navigationBarBackButtonHidden(true)
                .primaryNavigation(
                    title: LocalizedString.navBarTitle,
                    trailing: dismissButton
                )
                .onAppear(perform: {
                    viewStore.send(.onAppear)
                })
            }
        }
    }

    @ViewBuilder
    func dismissButton() -> some View {
        IconButton(icon: .close) {
            viewStore.send(.dismissFlow)
        }
    }

    private var headerView: some View {
        VStack(spacing: 8) {
            Text(LocalizedString.header.title)
                .typography(.title2)
                .foregroundColor(.semantic.title)
            Text(LocalizedString.header.subtitle)
                .typography(.paragraph1)
                .foregroundColor(.semantic.body)
        }
        .padding(.top, 16)
        .padding(.bottom, 35)
    }

    private var stepsView: some View {
        VStack(spacing: 8) {
            HStack {
                Spacer()
                    .frame(width: 24)

                Icon.close
                    .circle()
                    .color(.semantic.error)
                    .frame(width: 24, height: 24)

                Text(LocalizedString.bulletPoints.first)
                    .typography(.body2)
                    .foregroundColor(.semantic.title)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(16)

                Spacer()
            }
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.semantic.border)
            )

            HStack {
                Spacer()
                    .frame(width: 24)

                Icon.close
                    .circle()
                    .color(.semantic.error)
                    .frame(width: 24, height: 24)

                Text(LocalizedString.bulletPoints.second)
                    .typography(.body2)
                    .foregroundColor(.semantic.title)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(16)

                Spacer()
            }
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.semantic.border)
            )
        }
    }

    private var withdrawFundsView: some View {
        AlertCard(
            title: LocalizedString.withdrawBanner.title,
            message: LocalizedString.withdrawBanner.subtitle,
            variant: .warning
        )
        .fixedSize(horizontal: false, vertical: true)
    }

    private var footerActionsView: some View {
        VStack {
            PrimaryRow(
                title: LocalizedString.externalLinks.dataRetention,
                trailing: {
                    Icon.newWindow
                        .color(.semantic.muted)
                        .frame(width: 24, height: 24)
                },
                action: {
                    openURL(viewStore.state.externalLinks.dataRetention)
                }
            )
            PrimaryRow(
                title: LocalizedString.externalLinks.needHelp,
                trailing: {
                    Icon.newWindow
                        .color(.semantic.muted)
                        .frame(width: 24, height: 24)
                },
                action: {
                    openURL(viewStore.state.externalLinks.needHelp)
                }
            )
        }
    }

    private var deleteAccountView: some View {
        DestructivePrimaryButton(
            title: LocalizedString.mainCTA,
            action: {
                viewStore.send(.showConfirmationScreen)
            }
        )
    }

    private var contentView: some View {
        VStack(spacing: 8) {

            headerView
            stepsView
            withdrawFundsView

            Spacer()
            footerActionsView
            deleteAccountView
        }
        .padding()
    }
}
