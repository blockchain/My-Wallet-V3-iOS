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

struct ConfirmInformationView: View {

    private typealias LocalizedString = LocalizationConstants.ConfirmInformation

    @ObservedObject private var viewStore: ViewStore<ConfirmInformation.State, ConfirmInformation.Action>

    init(store: StoreOf<ConfirmInformation>) {
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
                fieldConfiguration: { fieldId in
                    switch fieldId {
                    case ConfirmInformation.InputField.emptyAddressAnswerId:
                        return .emptyAddress(
                            onFieldTapped: { viewStore.send(.onEmptyAddressFieldTapped) },
                            onBottomButton: { viewStore.send(.onEnterAddressManuallyTapped) }
                        )
                    case ConfirmInformation.InputField.address.rawValue:
                        return .singleAddress(
                            onFieldTapped: { viewStore.send(.onStartEditingSelectedAddress) },
                            onBottomButton: { viewStore.send(.onEnterAddressManuallyTapped) }
                        )
                    case ConfirmInformation.InputField.addressAnswerId(index: 0):
                        return .multiAddress(
                            onBottomButton: { viewStore.send(.onEnterAddressManuallyTapped) }
                        )
                    default:
                        return .init(textAutocorrectionType: .no)
                    }
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

struct ConfirmInformation_Previews: PreviewProvider {

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

extension UIApplication {
    fileprivate func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension FieldConfiguation {
    private typealias LocalizedString = LocalizationConstants.ConfirmInformation
    fileprivate static func emptyAddress(
        onFieldTapped: @escaping (() -> Void),
        onBottomButton: @escaping (() -> Void)
    ) -> FieldConfiguation {
        .init(
            textAutocorrectionType: .no,
            onFieldTapped: {
                UIApplication.shared.endEditing()
                onFieldTapped()
            },
            bottomButton: enterAddressManuallyButton(onBottomButton: onBottomButton)
        )
    }

    fileprivate static func singleAddress(
        onFieldTapped: @escaping (() -> Void),
        onBottomButton: @escaping (() -> Void)
    ) -> FieldConfiguation {
        .init(
            textAutocorrectionType: .no,
            onFieldTapped: {
                UIApplication.shared.endEditing()
                onFieldTapped()
            },
            bottomButton: enterAddressManuallyButton(onBottomButton: onBottomButton)
        )
    }

    fileprivate static func multiAddress(
        onBottomButton: @escaping (() -> Void)
    ) -> FieldConfiguation {
        .init(
            textAutocorrectionType: .no,
            bottomButton: enterAddressManuallyButton(onBottomButton: onBottomButton)
        )
    }

    private static func enterAddressManuallyButton(
        onBottomButton: @escaping (() -> Void)
    ) -> FieldConfiguation.BottomButton? {
        .init(
            leadingPrefixText: LocalizedString.Buttons.enterAddressManuallyPrefix,
            title: LocalizedString.Buttons.enterAddressManuallyTitle,
            action: {
                UIApplication.shared.endEditing()
                onBottomButton()
            }
        )
    }
}
