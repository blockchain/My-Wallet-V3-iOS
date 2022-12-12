import BlockchainComponentLibrary
import ComposableArchitecture
import FeatureDashboardDomain
import Localization
import SwiftUI

public struct AllAssetsSceneView: View {
    @ObservedObject var viewStore: ViewStoreOf<AllAssetsScene>
    let store: StoreOf<AllAssetsScene>

    public init(store: StoreOf<AllAssetsScene>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    public var body: some View {
        VStack {
            searchBarSection
            allAssetsSection
        }
        .background(Color.WalletSemantic.light)
        .primaryNavigation(trailing: {
            Button {
                viewStore.send(.onFilterTapped)
            } label: {
                Icon.superAppFilter
            }
            .if(viewStore.showSmallBalancesFilterIsOn) { $0.highlighted() }
        })
        .primaryNavigation(
            title: LocalizationConstants.SuperApp.AllAssets.title,
            trailing: {
            IconButton(icon: .closev2.circle()) {
                viewStore.send(.onCloseTapped)
            }
            .frame(width: 24.pt, height: 24.pt)
            }
        )
        .bottomSheet(
            isPresented: viewStore.binding(\.$filterPresented).animation(.spring()),
            content: {
                filterSheet
            }
        )
        .task {
            await viewStore.send(.onAppear).finish()
        }
    }

    private var searchBarSection: some View {
        SearchBar(
            text: viewStore.binding(\.$searchText),
            isFirstResponder: viewStore.binding(\.$isSearching),
            cancelButtonText: LocalizationConstants.SuperApp.AllAssets.cancelButton,
            placeholder: LocalizationConstants.SuperApp.AllAssets.searchPlaceholder
        )
        .frame(height: 48)
        .padding(.horizontal, Spacing.padding2)
        .padding(.vertical, Spacing.padding3)
    }

    private var allAssetsSection: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if let searchResults = viewStore.searchResults {
                    if searchResults.isEmpty {
                        noResultsView
                    } else {
                        ForEach(searchResults) { info in
                            SimpleBalanceRow(
                                leadingTitle: info.currency.name,
                                trailingTitle: info.fiatBalance?.quote.toDisplayString(includeSymbol: true),
                                trailingDescription: info.priceChangeString,
                                trailingDescriptionColor: info.priceChangeColor,
                                action: {
                                    viewStore.send(.onAssetTapped(info))
                                },
                                leading: {
                                    AsyncMedia(
                                        url: info.currency.cryptoCurrency?.assetModel.logoPngUrl
                                    )
                                    .resizingMode(.aspectFit)
                                    .frame(width: 24.pt, height: 24.pt)
                                }
                            )
                            if info.id != viewStore.searchResults?.last?.id {
                                Divider()
                                    .foregroundColor(.WalletSemantic.light)
                            }
                        }
                    }
                } else {
                    loadingSection
                }
            }
            .cornerRadius(16, corners: .allCorners)
            .padding(.horizontal, Spacing.padding2)
        }
    }

    private var filterSheet: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .center, content: {
                Text(LocalizationConstants.SuperApp.AllAssets.Filter.title)
                    .typography(.paragraph2)
                    .padding(.top, Spacing.padding1)

                HStack {
                    Text(LocalizationConstants.SuperApp.AllAssets.Filter.showSmallBalancesLabel)
                        .typography(.paragraph2)
                        .padding(.leading, Spacing.padding2)
                    Spacer()
                    PrimarySwitch(
                        accessibilityLabel: "",
                        isOn: viewStore.binding(\.$showSmallBalancesFilterIsOn)
                    )
                    .padding(.trailing, Spacing.padding2)
                    .padding(.vertical, Spacing.padding2)
                }
                .background(Color.WalletSemantic.light)
                .cornerRadius(16, corners: .allCorners)
                .padding(.horizontal, Spacing.padding2)

                PrimaryButton(title: LocalizationConstants.SuperApp.AllAssets.Filter.showButton) {
                    viewStore.send(.onConfirmFilterTapped)
                }
                .padding(.horizontal, Spacing.padding2)
                .padding(.vertical, Spacing.padding3)
            })
            .frame(maxWidth: .infinity)

            Button {
                viewStore.send(.onResetTapped)
            } label: {
                Text(LocalizationConstants.SuperApp.AllAssets.Filter.resetButton)
            }
            .typography(.body2)
            .padding(.top, Spacing.padding1)
            .padding(.trailing, Spacing.padding2)
        }
    }

    private var loadingSection: some View {
        Group {
            SimpleBalanceRow(leadingTitle: "", trailingDescription: nil, leading: {})
            Divider()
                .foregroundColor(.WalletSemantic.light)
            SimpleBalanceRow(leadingTitle: "", trailingDescription: nil, leading: {})
            Divider()
                .foregroundColor(.WalletSemantic.light)
            SimpleBalanceRow(leadingTitle: "", trailingDescription: nil, leading: {})
        }
    }

    private var noResultsView: some View {
        HStack(alignment: .center, content: {
            Text(LocalizationConstants.SuperApp.AllAssets.noResults)
                .padding(.vertical, Spacing.padding2)
        })
        .frame(maxWidth: .infinity)
        .background(Color.white)
    }
}

extension AssetBalanceInfo {
    var priceChangeString: String? {
        guard let delta else {
            return nil
        }
        var arrowString: String {
            if delta.isZero {
                return ""
            }
            if delta.isSignMinus {
                return "↓"
            }

            return "↑"
        }
        return "\(arrowString) \(delta) %"
    }

    var priceChangeColor: Color? {
        guard let delta else {
            return nil
        }
        return delta.isSignMinus || delta.isZero ? Color.WalletSemantic.body : Color.WalletSemantic.success
    }
}
