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
                then: AddressModificationView.init(store:)
            )
        }
    }
}

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
            WithViewStore(store) { viewStore in
                VStack(alignment: .leading) {
                    header
                    title
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
        WithViewStore(store) { viewStore in
            VStack(alignment: .center, spacing: Spacing.padding3) {
                ZStack {
                    Circle()
                        .fill(Color.semantic.background)
                        .frame(width: 88)
                    Icon.superAppHomeFilled
                        .color(Color.semantic.title).frame(width: 49)
                }
                Text(viewStore.screenTitle)
                    .typography(.title3)
                    .padding(.bottom, Spacing.padding2)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var title: some View {
        Text(L10n.title)
            .typography(.paragraph2)
            .foregroundColor(.WalletSemantic.title)
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 18)
    }

    private var searchBar: some View {
        WithViewStore(store) { viewStore in
            SearchBar(
                text: viewStore.binding(\.$searchText),
                isFirstResponder: viewStore.binding(\.$isSearchFieldSelected),
                hasAutocorrection: false,
                cancelButtonText: "",
                placeholder: L10n.SearchAddress.SearchBar.Placeholder.text
            )
            .padding(.horizontal, 18)
        }
    }

    private var content: some View {
        WithViewStore(store) { viewStore in
                List{
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
                .simultaneousGesture(
                    DragGesture().onChanged { _ in
                        viewStore.send(.set(\.$isSearchFieldSelected, false))
                    }
                )
        }
    }

    private func createItemRow(result: AddressSearchResult) -> some View {
        WithViewStore(store) { viewStore in
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
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading) {
                Button {
                    viewStore.send(.modifyAddress)
                } label: {
                    Text(L10n.SearchAddress.AddressNotFound.Buttons.inputAddressManually)
                        .typography(.paragraph1)
                        .foregroundColor(.semantic.primary)
                }
                .padding(.vertical, 16)
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
                        .init(
                            addressId: "123",
                            text: "32 rue de la messe",
                            type: "Type",
                            highlight: "Highlight",
                            description: "Bois-le-Roi, France"
                        ),
                        .init(
                            addressId: "456",
                            text: "7 place de la cité",
                            type: "Type",
                            highlight: "Highlight",
                            description: "Bois-le-Roi, France"
                        )
                    ]
                ),
                reducer: addressSearchReducer,
                environment: .init(
                    mainQueue: .main,
                    config: .init(
                        addressSearchScreen: .init(title: "Title"),
                        addressEditScreen: .init(title: "Title", subtitle: "Subtitle")
                    ),
                    addressService: MockServices(),
                    addressSearchService: MockServices(),
                    onComplete: { _ in }
                )
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
