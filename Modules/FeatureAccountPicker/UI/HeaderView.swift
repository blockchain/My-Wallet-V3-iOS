// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Localization
import SwiftUI
import UIComponentsKit

struct HeaderView: View {
    let viewModel: HeaderStyle
    @Binding var searchText: String
    @Binding var isSearching: Bool
    @Binding var segmentedControlSelection: Tag

    var body: some View {
        switch viewModel {
        case .none:
            EmptyView()
        case .simple(
            subtitle: let subtitle,
            searchable: let searchable,
            switchable: let switchable,
            switchTitle: let switchTitle
        ):
            SimpleHeaderView(
                subtitle: subtitle,
                searchable: searchable,
                switchTitle: switchTitle,
                switchable: switchable,
                searchText: $searchText,
                isSearching: $isSearching,
                segmentedControlSelection: $segmentedControlSelection
            )
        case .normal(
            title: let title,
            subtitle: let subtitle,
            image: let imageResource,
            tableTitle: let tableTitle,
            searchable: let searchable
        ):
            NormalHeaderView(
                title: title,
                subtitle: subtitle,
                image: imageResource,
                tableTitle: tableTitle,
                searchable: searchable,
                searchText: $searchText,
                isSearching: $isSearching
            )
        }
    }
}

private struct NormalHeaderView: View {
    let title: String
    let subtitle: String?
    let image: ImageResource?
    let tableTitle: String?
    let searchable: Bool

    @Binding var searchText: String
    @Binding var isSearching: Bool

    private enum Layout {
        static let margins = EdgeInsets(top: 24, leading: 24, bottom: 0, trailing: 24)

        static let titleTopPadding: CGFloat = 18
        static let subtitleTopPadding: CGFloat = 8
        static let tableTitleTopPadding: CGFloat = 27
        static let dividerLineTopPadding: CGFloat = 8

        static let imageSize = CGSize(width: 32, height: 32)
        static let dividerLineHeight: CGFloat = 1
        static let tableTitleFontSize: CGFloat = 12
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !isSearching {
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        image?.image
                            .scaledToFit()
                            .frame(width: Layout.imageSize.width, height: Layout.imageSize.height)
                            .padding(.top, Layout.margins.top)

                        Text(title)
                            .typography(.title3)
                            .foregroundColor(.semantic.title)
                            .padding(.top, Layout.titleTopPadding)
                        if let subtitle {
                            Text(subtitle)
                                .typography(.paragraph1)
                                .foregroundColor(.semantic.text)
                                .padding(.top, Layout.subtitleTopPadding)
                        }
                    }
                    .padding(.leading, Layout.margins.leading)

                    Spacer()
                }
                .padding(.trailing, Layout.margins.trailing)
            }

            if searchable {
                SearchBar(
                    text: $searchText,
                    isFirstResponder: $isSearching,
                    cancelButtonText: LocalizationConstants.cancel,
                    placeholder: LocalizationConstants.searchCoinPlaceholder
                )
                    .padding(.trailing, Layout.margins.trailing - Spacing.padding2)
                    .padding(.leading, Spacing.padding2)
            }
        }
        .padding(.bottom, Spacing.padding1)
        .background(Color.semantic.light.ignoresSafeArea(edges: .top))
        .animation(.easeInOut, value: isSearching)
    }
}

private struct SimpleHeaderView: View {
    let subtitle: String?
    let searchable: Bool
    let switchTitle: String?
    let switchable: Bool
    @Binding var searchText: String
    @Binding var isSearching: Bool
    @Binding var segmentedControlSelection: Tag

    private enum Layout {
        static let dividerLineHeight: CGFloat = 1
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let subtitle, !isSearching {
                Text(subtitle)
                    .typography(.paragraph1)
                    .foregroundColor(.semantic.text)
                    .padding(.horizontal, Spacing.padding3)
                    .padding(.vertical, Spacing.padding1)
            }

            if searchable || switchable {
                VStack {
                    if switchable {
                        LargeSegmentedControl(
                            items: [
                                LargeSegmentedControl.Item(title: NonLocalizedConstants.defiWalletTitle, identifier: blockchain.ux.asset.account.swap.segment.filter.defi[]),
                                LargeSegmentedControl.Item(
                                    title: LocalizationConstants.SuperApp.trading,
                                    icon: Icon.blockchain,
                                    identifier: blockchain.ux.asset.account.swap.segment.filter.trading[]
                                )
                            ], selection: $segmentedControlSelection
                        )
                        .padding(.horizontal, Spacing.padding3)
                    }

                    if searchable {
                        SearchBar(
                            text: $searchText,
                            isFirstResponder: $isSearching,
                            cancelButtonText: LocalizationConstants.cancel,
                            placeholder: LocalizationConstants.searchCoinPlaceholder
                        )
                        .padding(.horizontal, Spacing.padding2)
                    }
                }
            } else {
                Rectangle()
                    .frame(height: Layout.dividerLineHeight)
                    .foregroundColor(Color.semantic.light)
            }
        }
        .background(Color.semantic.light)
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewContainer(searchText: "")
            .previewLayout(.sizeThatFits)
    }

    struct PreviewContainer: View {
        @State var searchText: String
        @State var isSearching: Bool = false
        @State var segmentedControlSelection: Tag = blockchain.ux.asset.account.swap.segment.filter.defi[]

        var body: some View {
            HeaderView(
                viewModel: .normal(
                    title: "Receive Crypto Now",
                    subtitle: "Choose a Wallet to receive crypto to.",
                    image: ImageAsset.iconReceive.imageResource,
                    tableTitle: nil,
                    searchable: true
                ),
                searchText: $searchText,
                isSearching: $isSearching,
                segmentedControlSelection: $segmentedControlSelection
            )
            .animation(.easeInOut, value: isSearching)
        }
    }
}
