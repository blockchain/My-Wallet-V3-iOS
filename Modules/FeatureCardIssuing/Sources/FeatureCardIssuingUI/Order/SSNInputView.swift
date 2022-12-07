// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import FeatureCardIssuingDomain
import Localization
import SwiftUI
import ToolKit

struct SSNInputView: View {

    @State var isFirstResponder: Bool = false
    @State var hideSsn: Bool = true

    private typealias L10n = LocalizationConstants.CardIssuing.Order.KYC

    private let store: Store<CardOrderingState, CardOrderingAction>
    @State private var isNextViewVisible = false

    init(store: Store<CardOrderingState, CardOrderingAction>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: Spacing.padding3) {
                VStack(alignment: .leading, spacing: Spacing.padding1) {
                    Text(L10n.SSN.title)
                        .typography(.title3)
                        .multilineTextAlignment(.center)
                    Text(L10n.SSN.description)
                        .typography(.paragraph1)
                        .foregroundColor(.WalletSemantic.body)
                        .multilineTextAlignment(.leading)
                }
                .padding(.horizontal, Spacing.padding2)
                VStack(alignment: .leading) {
                    Text(L10n.SSN.Input.title)
                        .typography(.paragraph2)
                    // Password
                    Input(
                        text: viewStore.binding(\.$ssn),
                        isFirstResponder: $isFirstResponder,
                        placeholder: L10n.SSN.Input.placeholder,
                        state: 1...8 ~= viewStore.state.ssn.count ? .error : .default,
                        configuration: { textField in
                            textField.isSecureTextEntry = hideSsn
                            textField.textContentType = .password
                            textField.returnKeyType = .next
                        },
                        trailing: {
                            if hideSsn {
                                IconButton(icon: .lockClosed) {
                                    hideSsn = false
                                }
                            } else {
                                IconButton(icon: .lockOpen) {
                                    hideSsn = true
                                }
                            }
                        },
                        onReturnTapped: {
                            isFirstResponder = false
                        }
                    )
                    Text(L10n.SSN.Input.caption)
                        .typography(.caption1)
                        .foregroundColor(.semantic.muted)
                }
                .padding(.horizontal, Spacing.padding2)
                Spacer()
                PrimaryButton(title: L10n.Buttons.next) {
                    isNextViewVisible = true
                }
                .disabled(viewStore.state.ssn.count < 9)
                .padding(Spacing.padding2)
            }
            .padding(.vertical, Spacing.padding3)
            .primaryNavigation(title: L10n.SSN.Navigation.title)

            PrimaryNavigationLink(
                destination: KYCPendingView(store: store),
                isActive: $isNextViewVisible,
                label: EmptyView.init
            )
        }
    }
}

#if DEBUG
struct SSNInput_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SSNInputView(
                store: Store(
                    initialState: CardOrderingState(
                        initialKyc: KYC(status: .success, errorFields: nil),
                        address: MockServices.address,
                        ssn: ""
                    ),
                    reducer: cardOrderingReducer,
                    environment: .preview
                )
            )
        }
    }
}
#endif
