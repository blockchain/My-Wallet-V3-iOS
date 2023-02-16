// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import DIKit
import ErrorsUI
import Localization
import SwiftUI
import UIComponentsKit

struct BeginVerificationView: View {
    private typealias LocalizedString = LocalizationConstants.BeginVerification

    @Environment(\.openURL) var openURL
    @ObservedObject private var viewStore: ViewStore<BeginVerification.State, BeginVerification.Action>

    init(store: StoreOf<BeginVerification>) {
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        Group {
            if viewStore.isLoading {
                LoadingView()
            } else if let uxError = viewStore.uxError {
                makeError(uxError: uxError)
            } else {
                content
            }
        }
        .primaryNavigation(
            title: viewStore.title,
            trailing: {
                if viewStore.uxError == nil {
                    IconButton(icon: .closeCirclev2) {
                        viewStore.send(.onClose)
                    }
                    .frame(width: 24.pt, height: 24.pt)
                } else {
                    EmptyView()
                }
            }
        )
        .onAppear {
            viewStore.send(.onAppear)
        }
    }

    private var content: some View {
        Group {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: Spacing.padding3) {
                        Image.Logo.blockchain
                            .frame(width: 85.pt, height: 85.pt)
                        VStack(spacing: Spacing.padding1) {
                            Text(LocalizedString.Body.title)
                                .typography(.title3)
                                .foregroundColor(.semantic.title)
                            Text(LocalizedString.Body.subtitle)
                                .typography(.body1)
                                .foregroundColor(.semantic.body)
                        }
                    }
                    .padding(.horizontal, Spacing.padding3)
                    .frame(width: geometry.size.width)
                    .frame(height: geometry.size.height)
                }
            }
            Divider()
            Spacer(minLength: 16)
            VStack(spacing: 18.pt) {
                VStack(spacing: 4.pt) {
                    Text(LocalizedString.Footer.title)
                        .multilineTextAlignment(.center)
                        .typography(.paragraph1)
                        .foregroundColor(.textBody)
                    Button {
                        openTermsUrl()
                    } label: {
                        Text(LocalizedString.Footer.titleTerms)
                            .typography(.paragraph1)
                    }
                }
                PrimaryButton(title: LocalizedString.Buttons.continueTitle) {
                    viewStore.send(.onContinue)
                }
            }
            .frame(alignment: .bottom)
            .padding([.horizontal, .bottom])
        }
    }

    private func makeError(uxError: UX.Error) -> some View {
        ErrorView(
            ux: uxError,
            dismiss: {
                viewStore.send(.onDismissError)
            }
        )
    }

    private func openTermsUrl() {
        guard let termsUrl = viewStore.termsUrl else { return }
        openURL(termsUrl)
    }
}

struct BeginVerificationView_Previews: PreviewProvider {

    static var previews: some View {
        let app: AppProtocol = resolve()
        Group {
            BeginVerificationView(store: .init(
                initialState: .init(),
                reducer: BeginVerification.preview(app: app)
            )).app(app)
        }
    }
}
