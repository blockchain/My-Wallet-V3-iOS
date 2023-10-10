// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import ComposableNavigation
import ErrorsUI
import FeatureAddressSearchDomain
import Localization
import SwiftUI
import ToolKit

enum AddressSearchRoute: NavigationRoute {
    case modifyAddress(selectedAddressId: String?, address: Address?)

    @MainActor
    @ViewBuilder
    func destination(
        in store: Store<AddressSearchState, AddressSearchAction>
    ) -> some View {
        switch self {
        case .modifyAddress:
            IfLetStore(
                store.scope(
                    state: \.addressModificationState,
                    action: AddressSearchAction.addressModificationAction
                ),
                then: { AddressModificationView(store:$0) }
            )
        }
    }
}

@MainActor
struct AddressSearchView: View {

    private typealias L10n = LocalizationConstants.AddressSearch

    private let store: Store<
        AddressSearchState,
        AddressSearchAction
    >

    init(
        store: Store<
            AddressSearchState,
            AddressSearchAction
        >
    ) {
        self.store = store
    }

    var body: some View {
        PrimaryNavigationView {
            WithViewStore(store, observe: { $0 }) { viewStore in
                VStack(alignment: .leading) {
                    header
                    searchBar
                    content
                }
                .padding(.vertical, Spacing.padding1)
                .background(Color.semantic.light.ignoresSafeArea())
                .trailingNavigationButton(.close) {
                    viewStore.send(.cancelSearch)
                }
                .onAppear {
                    viewStore.send(.onAppear)
                }
                .navigationRoute(in: store)
            }
        }
        .environment(\.navigationBarColor, Color.semantic.light)
    }

    private var header: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading, spacing: Spacing.padding1) {
                HStack {
                    Text(viewStore.screenTitle)
                        .typography(.title3)
                    Spacer()
                }
                Text(viewStore.screenTitle)
                    .typography(.body1)
                    .foregroundColor(.semantic.body)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, Spacing.padding2)
            .padding(.bottom, Spacing.padding2)
        }
    }

    private var searchBar: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            SearchBar(
                text: viewStore.$searchText,
                isFirstResponder: viewStore.$isSearchFieldSelected,
                hasAutocorrection: false,
                cancelButtonText: "",
                placeholder: L10n.SearchAddress.SearchBar.Placeholder.text
            )
            .padding(.horizontal, Spacing.padding2)
        }
    }

    private var content: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
                List {
                    Section(
                        content: {
                            addressManualInputRow
                            ForEach(viewStore.searchResults, id: \.addressId) { result in
                                createItemRow(result: result)
                            }
                        },
                        footer: {
                            if viewStore.isSearchResultsLoading {
                                HStack {
                                    Spacer()
                                    VStack {
                                        Spacer(minLength: Spacing.padding3)
                                        ProgressView()
                                    }
                                    Spacer()
                                }
                            }
                        }
                    )
                    .listRowInsets(.zero)
                }
                .listStyle(.insetGrouped)
                .listRowInsets(.zero)
                .background(Color.semantic.light)
                .hideScrollContentBackground()
                .simultaneousGesture(
                    DragGesture().onChanged { _ in
                        viewStore.send(.set(\.$isSearchFieldSelected, false))
                    }
                )
        }
    }

    private func createItemRow(result: AddressSearchResult) -> some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            let title = result.text ?? ""
            let subtitle: PrimaryRowTextValue? = {
                guard let description = result.description, description.isNotEmpty else { return nil }
                return .init(
                    text: description,
                    highlightRanges: result.descriptionHighlightRanges
                )
            }()
            PrimaryRow(
                title: .init(text: title, highlightRanges: result.textHighlightRanges),
                subtitle: subtitle,
                trailing: {
                    EmptyView()
                },
                action: {
                    viewStore.send(.set(\.$isSearchFieldSelected, false))
                    viewStore.send(.selectAddress(result))
                }
            )
            .backport
            .listDivider()
        }
    }

    private var addressManualInputRow: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading) {
                Button {
                    viewStore.send(.modifyAddress)
                } label: {
                    Text(L10n.SearchAddress.AddressNotFound.Buttons.inputAddressManually)
                        .typography(.paragraph1)
                        .foregroundColor(.semantic.primary)
                }
                .padding(.vertical, Spacing.padding2)
            }
            .padding(.horizontal, Spacing.padding3)
        }
    }

    private var addressSearchResultsNotFound: some View {
        VStack {
            Spacer()
            VStack(alignment: .leading) {
                addressManualInputRow
                PrimaryDivider()
            }
            VStack {
                Spacer(minLength: Spacing.padding3)
                Text(L10n.SearchAddress.AddressNotFound.title)
                    .typography(.paragraph1)
                    .foregroundColor(.WalletSemantic.body)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

#if DEBUG
struct AddressSearch_Previews: PreviewProvider {
    static var previews: some View {
        AddressSearchView(
            store: Store(
                initialState: .init(
                    address: MockServices.address,
                    error: .unknown,
                    searchResults: [
                        AddressSearchResult(
                            addressId: "123",
                            text: "32 rue de la messe",
                            type: "Type",
                            highlight: "Highlight",
                            description: "Bois-le-Roi, France"
                        ),
                        AddressSearchResult(
                            addressId: "456",
                            text: "7 place de la cité",
                            type: "Type",
                            highlight: "Highlight",
                            description: "Bois-le-Roi, France"
                        )
                    ]
                ),
                reducer: {
                    AddressSearchReducer(
                        mainQueue: .main,
                        config: .init(
                            addressSearchScreen: .init(title: "Title", subtitle: "Subtitle"),
                            addressEditScreen: .init(title: "Title", subtitle: "Subtitle")
                        ),
                        addressService: MockServices(),
                        addressSearchService: MockServices(),
                        onComplete: { _ in }
                    )
                }
            )
        )
    }
}
#endif

extension AddressSearchResult {

    fileprivate var textHighlightRanges: [Range<String.Index>] {
        guard let text else { return [] }
        return text
            .separateInHighlightRanges(highlight: highlight, isFirstComponent: true)
    }

    fileprivate var descriptionHighlightRanges: [Range<String.Index>] {
        guard let description else { return [] }
        return description
            .separateInHighlightRanges(highlight: highlight, isFirstComponent: false)
    }
}

extension String {
    fileprivate func separateInHighlightRanges(
        highlight: String?,
        isFirstComponent: Bool
    ) -> [Range<String.Index>] {
        guard isNotEmpty,
              let highlight, !highlight.isEmpty
        else {
            return []
        }

        let textHighlightRangesStringComponents = highlight.components(separatedBy: ";")
        let textHighlightRangesString: String
        if isFirstComponent {
            textHighlightRangesString = textHighlightRangesStringComponents.first ?? ""
        } else {
            guard textHighlightRangesStringComponents.count > 1 else {
                return []
            }
            textHighlightRangesString = textHighlightRangesStringComponents[1]
        }
        guard textHighlightRangesString.isNotEmpty else { return [] }
        let textHighlightRanges = textHighlightRangesString.components(separatedBy: ",")
        guard !textHighlightRanges.isEmpty else { return [] }

        let ranges: [Range<String.Index>] = textHighlightRanges.compactMap {
            let components = $0.components(separatedBy: "-")
            guard let first = components.first, let firstInt = Int(first),
                  let second = components.last, let secondInt = Int(second)
            else {
                return nil
            }
            return self.range(startingAt: firstInt, length: secondInt - firstInt)
        }
        return ranges
    }
}
