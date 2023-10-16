import BlockchainComponentLibrary
import ComposableArchitecture
import ComposableNavigation
import Localization
import SwiftUI

private typealias LocalizedString = LocalizationConstants.UserDeletion.ConfirmationScreen

public struct DeletionConfirmView: View {
    let store: Store<DeletionConfirmState, DeletionConfirmAction>
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewStore: ViewStore<DeletionConfirmState, DeletionConfirmAction>

    public init(store: Store<DeletionConfirmState, DeletionConfirmAction>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    public var body: some View {
        VStack {
            if viewStore.isLoading {
                Group {
                    ProgressView()
                        .progressViewStyle(
                            BlockchainCircularProgressViewStyle()
                        )
                        .frame(width: 104, height: 104)

                    Text(LocalizedString.processing)
                        .typography(.title3)
                        .foregroundColor(.semantic.title)
                        .padding(.top, 16)
                }
            } else {
                contentView
                    .padding()
            }
        }
        .navigationRoute(in: store)
        .primaryNavigation(
            title: LocalizedString.navBarTitle,
            trailing: dismissButton
        )
        .navigationBarBackButtonHidden(true)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear(perform: {
            viewStore.send(.onAppear)
        })
    }

    @ViewBuilder
    func dismissButton() -> some View {
        IconButton(icon: .navigationCloseButton()) {
            viewStore.send(.dismissFlow)
        }
    }

    @ViewBuilder
    private var contentView: some View {
        VStack(spacing: 16) {
            Text(LocalizedString.explanaition)
                .typography(.paragraph1)
                .foregroundColor(.semantic.text)

            let shouldShowError = viewStore.shouldShowInvalidInputUI
            Input(
                text: viewStore.$textFieldText,
                isFirstResponder: viewStore.$firstResponder.equals(.confirmation),
                label: LocalizedString.textField.label,
                subText: shouldShowError ? LocalizedString.textField.errorSubText : nil,
                subTextStyle: shouldShowError ? .error : .default,
                placeholder: LocalizedString.textField.placeholder,
                state: shouldShowError ? .error : .default,
                onReturnTapped: {
                    viewStore.send(.set(\.$firstResponder, nil))
                }
            )
            .autocorrectionDisabled()
            .keyboardType(.default)
            .textInputAutocapitalization(.characters)

            Spacer()

            DestructivePrimaryButton(
                title: LocalizedString.mainCTA,
                action: {
                    viewStore.send(.deleteUserAccount)
                }
            )
        }
    }
}

#if DEBUG

struct DeletionConfirm_Previews: PreviewProvider {

    static var loadingState: DeletionConfirmState {
        var value = DeletionConfirmState()
        value.isLoading = true
        return value
    }

    static var previews: some View {
        Group {
            DeletionConfirmView(
                store: Store(
                    initialState: DeletionConfirmState(),
                    reducer: { DeletionConfirmReducer.preview }
                )
            )
            DeletionConfirmView(
                store: Store(
                    initialState: loadingState,
                    reducer: { DeletionConfirmReducer.preview }
                )
            )
        }
    }
}

#endif
