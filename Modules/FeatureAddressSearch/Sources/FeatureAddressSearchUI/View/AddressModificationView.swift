// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import Errors
import ErrorsUI
import FeatureAddressSearchDomain
import Localization
import SwiftUI
import ToolKit
import UIComponentsKit

struct AddressModificationView: View {

    private typealias L10n = LocalizationConstants.AddressSearch

    private let store: Store<
        AddressModificationState,
        AddressModificationAction
    >

    init(
        store: Store<
            AddressModificationState,
            AddressModificationAction
        >
    ) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            if !viewStore.isPresentedFromSearchView {
                PrimaryNavigationView {
                    content
                }
                footer
            } else {
                content
                footer
            }
        }
    }

    private var content: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                form
                .padding(.vertical, Spacing.padding3)
                .primaryNavigation(title: viewStore.screenTitle)
                .trailingNavigationButton(.close, isVisible: !viewStore.isPresentedFromSearchView) {
                    viewStore.send(.cancelEdit)
                }
                .onAppear {
                    viewStore.send(.onAppear)
                }
                .alert(
                    store.scope(state: \.failureAlert),
                    dismiss: .dismissAlert
                )
            }
        }
    }

    private var form: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: Spacing.padding3) {
                subtitle
                VStack(spacing: Spacing.padding1) {
                    Input(
                        text: viewStore.binding(\.$line1),
                        isFirstResponder: viewStore
                            .binding(\.$selectedInputField)
                            .equals(.line1),
                        label: L10n.Form.addressLine1,
                        placeholder: L10n.Form.Placeholder.line1,
                        state: viewStore.state.line1.isEmpty ? .error : .default,
                        configuration: {
                            $0.textContentType = .streetAddressLine1
                            $0.autocorrectionType = .no
                        },
                        onReturnTapped: {
                            viewStore.send(.binding(.set(\.$selectedInputField, .line2)))
                        }
                    )
                    Input(
                        text: viewStore.binding(\.$line2),
                        isFirstResponder: viewStore
                            .binding(\.$selectedInputField)
                            .equals(.line2),
                        label: L10n.Form.addressLine2,
                        placeholder: L10n.Form.Placeholder.line2,
                        configuration: {
                            $0.textContentType = .streetAddressLine2
                            $0.autocorrectionType = .no
                        },
                        onReturnTapped: {
                            viewStore.send(.binding(.set(\.$selectedInputField, .city)))
                        }
                    )
                    Input(
                        text: viewStore.binding(\.$city),
                        isFirstResponder: viewStore
                            .binding(\.$selectedInputField)
                            .equals(.city),
                        label: L10n.Form.city,
                        configuration: {
                            $0.textContentType = .addressCity
                            $0.autocorrectionType = .no
                        },
                        onReturnTapped: {
                            viewStore.send(.binding(.set(\.$selectedInputField, .state)))
                        }
                    )
                    HStack(spacing: Spacing.padding2) {
                        if viewStore.isStateFieldVisible {
                            Input(
                                text: viewStore.binding(\.$stateName),
                                isFirstResponder: viewStore
                                    .binding(\.$selectedInputField)
                                    .equals(.state),
                                label: L10n.Form.state,
                                configuration: {
                                    $0.textContentType = .addressState
                                    $0.autocorrectionType = .no
                                },
                                onReturnTapped: {
                                    viewStore.send(.binding(.set(\.$selectedInputField, .zip)))
                                }
                            )
                            .disabled(true)
                        }
                        Input(
                            text: viewStore.binding(\.$postcode),
                            isFirstResponder: viewStore
                                .binding(\.$selectedInputField)
                                .equals(.zip),
                            label: L10n.Form.zip,
                            configuration: {
                                $0.textContentType = .postalCode
                                $0.autocorrectionType = .no
                            },
                            onReturnTapped: {
                                viewStore.send(.binding(.set(\.$selectedInputField, nil)))
                            }
                        )
                    }
                    Input(
                        text: .constant(countryName(viewStore.state.country)),
                        isFirstResponder: .constant(false),
                        label: L10n.Form.country
                    )
                    .disabled(true)
                }
                .padding(.horizontal, Spacing.padding3)
            }
        }
    }

    private var footer: some View {
        WithViewStore(store) { viewStore in
            PrimaryButton(
                title: viewStore.saveButtonTitle ?? L10n.Buttons.save,
                isLoading: viewStore.state.loading
            ) {
                viewStore.send(.updateAddress)
            }
            .disabled(
                viewStore.state.line1.isEmpty
                || viewStore.state.postcode.isEmpty
                || viewStore.state.city.isEmpty
                || viewStore.state.country.isEmpty
            )
            .frame(alignment: .bottom)
            .padding([.horizontal, .bottom])
            .background(
                Rectangle()
                    .fill(Color.semantic.background)
                    .backgroundWithWhiteShadow
            )
        }
    }

    private var subtitle: some View {
        WithViewStore(store) { viewStore in
            if let subtitle = viewStore.screenSubtitle {
                VStack(alignment: .leading, spacing: Spacing.padding1) {
                    Text(subtitle)
                        .typography(.paragraph1)
                        .foregroundColor(.WalletSemantic.body)
                        .multilineTextAlignment(.leading)
                }
                .padding(.horizontal, Spacing.padding2)
            }
        }
    }
}

extension View {

    fileprivate func trailingNavigationButton(
        _ navigationButton: NavigationButton,
        isVisible: Bool,
        action: @escaping () -> Void
    ) -> some View {
        guard isVisible else { return AnyView(self) }
        return AnyView(navigationBarItems(
            trailing: HStack {
                navigationButton.button(action: action)
            }
        ))
    }
}

func countryName(_ code: String) -> String {
    let locale = NSLocale.current as NSLocale
    return locale.displayName(forKey: NSLocale.Key.countryCode, value: code) ?? ""
}

#if DEBUG
struct AddressModification_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddressModificationView(
                store: Store(
                    initialState: .init(
                        addressDetailsId: MockServices.addressId,
                        isPresentedFromSearchView: false
                    ),
                    reducer: addressModificationReducer,
                    environment: .init(
                        mainQueue: .main,
                        config: .init(title: "Title", subtitle: "Subtitle"),
                        addressService: MockServices(),
                        addressSearchService: MockServices(),
                        onComplete: { _ in }
                    )
                )
            )
        }
    }
}
#endif
