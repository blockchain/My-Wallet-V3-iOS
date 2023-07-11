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
        // swiftlint:disable multiple_closures_with_trailing_closure
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                searchBarSection(viewStore: viewStore)
                allActivitySection(viewStore: viewStore)
                    .redacted(reason: viewStore.isLoading ? .placeholder : [])
            }
            .background(Color.WalletSemantic.light.ignoresSafeArea())
            .onAppear {
                viewStore.send(.onAppear)
            }
            .navigationBarHidden(true)
            .superAppNavigationBar(
                title: {
                    Text(LocalizationConstants.SuperApp.AllActivity.title)
                        .typography(.body2)
                        .foregroundColor(.semantic.title)
                },
                trailing: {
                    IconButton(icon: .closev2.circle().small()) {
                        $app.post(event: blockchain.ux.user.activity.all.article.plain.navigation.bar.button.close.tap)
                    }
                },
                scrollOffset: nil
            )
            .bottomSheet(isPresented: viewStore.binding(\.$pendingInfoPresented)) {
                pendingActivityInfoSheet
            }
        }
    }

    var pendingActivityInfoSheet: some View {
        VStack {
            HStack {
                Text(LocalizationConstants.SuperApp.AllActivity.pendingActivityModalTitle)
                    .typography(.body2)
                    .foregroundColor(.WalletSemantic.title)
                Spacer()
                IconButton(icon: .closev2.circle()) {
                    ViewStore(store).send(.binding(.set(\.$pendingInfoPresented, false)))
                }
                .frame(width: 24.pt, height: 24.pt)
            }
            .padding(.horizontal, Spacing.padding2)
            .padding(.bottom, Spacing.padding3)

            Text(LocalizationConstants.SuperApp.AllActivity.pendingActivityModalText)
                .typography(.body1)
                .foregroundColor(.WalletSemantic.title)
                .padding(.horizontal, Spacing.padding2)
                .padding(.bottom, Spacing.padding3)

            PrimaryButton(
                title: LocalizationConstants.SuperApp.AllActivity.pendingActivityCTAButton,
                action: {
                    ViewStore(store).send(.binding(.set(\.$pendingInfoPresented, false)))
                }
            )
            .padding(.horizontal, Spacing.padding2)
            .padding(.bottom, Spacing.padding3)
        }
    }

    @ViewBuilder
    func searchBarSection(viewStore: ViewStoreOf<AllActivityScene>) -> some View {
        SearchBar(
            text: viewStore.binding(\.$searchText),
            isFirstResponder: viewStore.binding(\.$isSearching),
            cancelButtonText: LocalizationConstants.SuperApp.AllActivity.cancelButton,
            placeholder: LocalizationConstants.SuperApp.AllActivity.searchPlaceholder
        )
        .frame(height: 48)
        .padding(.horizontal, Spacing.padding2)
        .padding(.top, Spacing.padding3)
    }

    @ViewBuilder
    func allActivitySection(viewStore: ViewStoreOf<AllActivityScene>) -> some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                // Pending section
                if viewStore.pendingResults.isEmpty == false {
                    Button {
                        viewStore.send(.onPendingInfoTapped)
                    } label: {
                        SectionHeader(
                            title: LocalizationConstants.Dashboard.AllActivity.pendingSection,
                            variant: .superapp,
                            decoration: {
                                Icon
                                    .questionCircle
                                    .small()
                                    .color(.semantic.dark)
                            }
                        )
                    }
                    ForEach(viewStore.pendingResults) { result in
                        ActivityItem(
                            searchResult: result,
                            isFirstItem: result.id == viewStore.pendingResults.first?.id,
                            isLastItem: result.id == viewStore.pendingResults.last?.id,
                            onAction: {
                                viewStore.send(.set(\.$isSearching, false))
                            }
                        )
                        .context([blockchain.ux.activity.detail.id: result.id])
                    }
                }

                // Months section
                ForEach(viewStore.headers, id: \.self) { header in
                    Section {
                        if let results = viewStore.resultsGroupedByDate[header] {
                            ForEach(results, id: \.self) { searchResult in
                                ActivityItem(
                                    searchResult: searchResult,
                                    isFirstItem: searchResult.id == results.first?.id,
                                    isLastItem: searchResult.id == results.last?.id,
                                    onAction: {
                                        viewStore.send(.set(\.$isSearching, false))
                                    }
                                )
                                .padding(.bottom, searchResult.id == results.last?.id ? Spacing.padding4 : 0)
                                .context([blockchain.ux.activity.detail.id: searchResult.id])
                            }
                        }
                    } header: {
                        SectionHeader(
                            title: header.formatted(.dateTime.year(.defaultDigits).month(.wide)),
                            variant: .superapp
                        )
                    }
                }
            }
        }
        .padding(.horizontal, Spacing.padding2)
    }

    struct ActivityItem: View {
        @BlockchainApp var app
        @Environment(\.context) var context

        let searchResult: ActivityEntry
        var isFirstItem: Bool
        var isLastItem: Bool
        var onAction: () -> Void

        private var corners: UIRectCorner {
            if isFirstItem, isLastItem {
                return .allCorners
            } else if isFirstItem {
                return [.topLeft, .topRight]
            } else if isLastItem {
                return [.bottomLeft, .bottomRight]
            }
            return []
        }

        var body: some View {
            Group {
                ActivityRow(activityEntry: searchResult, action: {
                    onAction()
                    app.post(event: blockchain.ux.activity.detail[searchResult.id].entry.paragraph.row.tap, context: context + [
                        blockchain.ux.activity.detail.model: searchResult
                    ])
                })
                if !isLastItem {
                    PrimaryDivider()
                }
            }
            .cornerRadius(Spacing.padding1, corners: corners)
            .batch {
                set(blockchain.ux.user.activity.all.article.plain.navigation.bar.button.close.tap.then.close, to: true)
                set(blockchain.ux.activity.detail.entry.paragraph.row.tap.then.enter.into, to: blockchain.ux.activity.detail[searchResult.id])
            }
        }
    }
}
