// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import DIKit
import ErrorsUI
import FeatureFormDomain
import FeatureFormUI
import Localization
import SwiftUI
import UIComponentsKit

struct EnterInformationView: View {

    private typealias LocalizedString = LocalizationConstants.EnterInformation

    @ObservedObject private var viewStore: ViewStore<EnterInformation.State, EnterInformation.Action>

    init(store: StoreOf<EnterInformation>) {
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        Group {
            if viewStore.isLoading {
                LoadingView(title: LocalizedString.loadingTitle)
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
        .hideBackButtonTitle()
        .navigationBarBackButtonHidden()
        .onAppear {
            viewStore.send(.onAppear)
        }
    }

    private var content: some View {
        Group {
            Spacer(minLength: 24.0)
            PrimaryForm(
                form: viewStore.binding(\.$form),
                submitActionTitle: LocalizedString.Buttons.continueTitle,
                submitActionLoading: viewStore.isLoading,
                submitAction: {
                    viewStore.send(.onContinue)
                },
                submitButtonMode: .onlyEnabledWhenAllAnswersValid,
                submitButtonLocation: .attachedToBottomOfScreen(),
                fieldConfiguration: { _ in
                        .init(textAutocorrectionType: .no)
                },
                headerIcon: {
                    headerIcon
                }
            )
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

    var headerIcon: some View {
        Icon.user
            .color(.semantic.primary)
            .frame(width: 32.pt, height: 32.pt)
    }
}

struct EnterInformation_Previews: PreviewProvider {

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
