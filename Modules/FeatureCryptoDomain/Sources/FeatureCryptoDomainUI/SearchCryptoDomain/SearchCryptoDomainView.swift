// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainComponentLibrary
import ComposableArchitecture
import ComposableNavigation
import DIKit
import FeatureCryptoDomainDomain
import Localization
import SwiftUI
import ToolKit

struct SearchCryptoDomainView: View {

    private typealias LocalizedString = LocalizationConstants.FeatureCryptoDomain.SearchDomain
    private typealias Accessibility = AccessibilityIdentifiers.SearchDomain

    private let store: Store<SearchCryptoDomainState, SearchCryptoDomainAction>

    init(store: Store<SearchCryptoDomainState, SearchCryptoDomainAction>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: Spacing.padding2) {
                searchBar
                    .padding([.top, .leading, .trailing], Spacing.padding3)
                alertCardDescription
                    .padding([.leading, .trailing], Spacing.padding3)
                domainList
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
            .primaryNavigation(title: LocalizedString.title)
            .bottomSheet(isPresented: viewStore.binding(\.$isPremiumDomainBottomSheetShown)) {
                createPremiumDomainBottomSheet()
            }
            .navigationRoute(in: store)
        }
    }

    private var searchBar: some View {
        WithViewStore(store) { viewStore in
            SearchBar(
                text: viewStore.binding(\.$searchText),
                isFirstResponder: viewStore.binding(\.$isSearchFieldSelected),
                cancelButtonText: LocalizationConstants.cancel,
                subText: viewStore.isSearchTextValid ? nil : LocalizedString.SearchBar.error,
                subTextStyle: viewStore.isSearchTextValid ? .default : .error,
                placeholder: LocalizedString.title,
                onReturnTapped: {
                    viewStore.send(.set(\.$isSearchFieldSelected, false))
                }
            )
            .accessibilityIdentifier(Accessibility.searchBar)
        }
    }

    private var alertCardDescription: some View {
        WithViewStore(store) { viewStore in
            if viewStore.isAlertCardShown {
                AlertCard(
                    title: LocalizedString.Description.title,
                    message: LocalizedString.Description.body,
                    onCloseTapped: {
                        viewStore.send(.set(\.$isAlertCardShown, false), animation: .linear)
                    }
                )
                .accessibilityIdentifier(Accessibility.alertCard)
            }
        }
    }

    private var domainList: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                if viewStore.isSearchResultsLoading {
                    ProgressView()
                } else {
                    LazyVStack(spacing: 0) {
                        ForEach(viewStore.searchResults, id: \.domainName) { result in
                            PrimaryDivider()
                            createDomainRow(result: result)
                        }
                        PrimaryDivider()
                    }
                }
            }
            .simultaneousGesture(
                DragGesture().onChanged { _ in
                    viewStore.send(.set(\.$isSearchFieldSelected, false))
                }
            )
            .accessibilityIdentifier(Accessibility.domainList)
        }
    }

    private func createDomainRow(result: SearchDomainResult) -> some View {
        WithViewStore(store) { viewStore in
            PrimaryRow(
                title: result.domainName,
                subtitle: result.domainType.statusLabel,
                trailing: {
                    TagView(
                        text: result.domainAvailability.availabilityLabel,
                        variant: result.domainAvailability == .availableForFree ?
                            .success : result.domainAvailability == .unavailable ? .default : .infoAlt
                    )
                },
                action: {
                    viewStore.send(.set(\.$isSearchFieldSelected, false))
                    switch result.domainType {
                    case .free:
                        viewStore.send(.selectFreeDomain(result))
                    case .premium:
                        viewStore.send(.selectPremiumDomain(result))
                    }
                }
            )
            .disabled(result.domainAvailability == .unavailable)
            .accessibilityIdentifier(Accessibility.domainListRow)
        }
    }

    private func createPremiumDomainBottomSheet() -> some View {
        WithViewStore(store) { viewStore in
            BuyDomainActionView(
                domainName: viewStore.selectedPremiumDomain?.domainName ?? "",
                redirectUrl: viewStore.selectedPremiumDomainRedirectUrl ?? "",
                isShown: viewStore.binding(\.$isPremiumDomainBottomSheetShown)
            )
        }
    }
}

#if DEBUG
@testable import FeatureCryptoDomainData
@testable import FeatureCryptoDomainMock

struct SearchCryptoDomainView_Previews: PreviewProvider {
    static var previews: some View {
        SearchCryptoDomainView(
            store: .init(
                initialState: .init(),
                reducer: SearchCryptoDomain(
                    analyticsRecorder: NoOpAnalyticsRecorder(),
                    externalAppOpener: ToLogAppOpener(),
                    searchDomainRepository: SearchDomainRepository(
                        apiClient: SearchDomainClient.mock
                    ),
                    orderDomainRepository: OrderDomainRepository(
                        apiClient: OrderDomainClient.mock
                    ),
                    userInfoProvider: { .empty() }
                )
            )
        )
    }
}
#endif
