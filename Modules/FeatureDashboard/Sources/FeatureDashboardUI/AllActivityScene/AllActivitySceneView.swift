// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainUI
import ComposableArchitecture
import Foundation
import Localization
import SwiftUI
import UnifiedActivityDomain
import UnifiedActivityUI

public struct AllActivitySceneView: View {
    @BlockchainApp var app
    @Environment(\.context) var context
    let store: StoreOf<AllActivityScene>

    public init(store: StoreOf<AllActivityScene>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                searchBarSection
                allAssetsSection
            }
            .background(Color.WalletSemantic.light)
            .task {
                await viewStore.send(.onAppear).finish()
            }
            .primaryNavigation(
                title: LocalizationConstants.SuperApp.AllActivity.title,
                trailing: {
                    IconButton(icon: .closev2.circle()) {
                        viewStore.send(.onCloseTapped)
                    }
                    .frame(width: 24.pt, height: 24.pt)
                }
            )
        }
    }

    private var searchBarSection: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            SearchBar(
                text: viewStore.binding(\.$searchText),
                isFirstResponder: viewStore.binding(\.$isSearching),
                cancelButtonText: LocalizationConstants.SuperApp.AllActivity.cancelButton,
                placeholder: LocalizationConstants.SuperApp.AllActivity.searchPlaceholder
            )
            .frame(height: 48)
            .padding(.horizontal, Spacing.padding2)
            .padding(.vertical, Spacing.padding3)
        }
    }

    private var allAssetsSection: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ScrollView {
                LazyVStack(spacing: 0) {
                    if let searchResults = viewStore.searchResults {
                        ForEach(searchResults) { searchResult in
                            ActivityItem(searchResult: searchResult, isLastItem: searchResult.id == viewStore.searchResults?.last?.id)
                                .context([blockchain.ux.activity.detail.id: searchResult.id])
                        }
                    }
                }
            }
            .cornerRadius(16, corners: .allCorners)
            .padding(.horizontal, Spacing.padding2)
        }
    }

    struct ActivityItem: View {
        @BlockchainApp var app
        @Environment(\.context) var context

        let searchResult: ActivityEntry
        var isLastItem: Bool
        var body: some View {
            Group {
                ActivityRow(activityEntry: searchResult, action: {
                    app.post(event: blockchain.ux.activity.detail[searchResult.id].entry.paragraph.row.tap, context: context + [
                        blockchain.ux.activity.detail.model: searchResult
                    ])
                })
                if !isLastItem {
                    Divider()
                        .foregroundColor(.WalletSemantic.light)
                }
            }
            .batch(
                .set(blockchain.ux.activity.detail.entry.paragraph.row.tap.then.enter.into, to: blockchain.ux.activity.detail[searchResult.id])
            )
        }
    }
}
