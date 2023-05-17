// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import FeatureWalletConnectDomain
import SwiftUI
import UIComponentsKit
import WalletConnectSwift

struct DAppListView: View {
    private let store: Store<DAppListState, DAppListAction>

    init(store: Store<DAppListState, DAppListAction>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store.stateless) { viewStore in
            VStack {
                Spacer()
                HStack(alignment: .top) {
                    Spacer()
                    RoundedRectangle(cornerRadius: 100)
                        .frame(width: 32, height: 4)
                        .foregroundColor(.borderPrimary)
                        .offset(x: 16, y: -6)
                    Spacer()
                    IconButton(icon: .closev2.circle()) {
                        viewStore.send(.close)
                    }
                    .frame(width: 32, height: 32)
                }
                .padding([.horizontal], 24)
                HStack {
                    WithViewStore(store.scope(state: \.title)) { viewStore in
                        Text(viewStore.state)
                            .typography(.body2)
                            .multilineTextAlignment(.leading)
                    }
                    Spacer()
                }
                .padding([.horizontal], 24)
                .offset(y: -12)
                PrimaryDivider()
                DAppList()
            }
            .padding([.vertical], 24)
            .frame(minHeight: 50.vh, alignment: .top)
            .gesture(
                DragGesture(minimumDistance: 20, coordinateSpace: .global)
                    .onEnded { drag in
                        if drag.translation.height >= 20 {
                            viewStore.send(.close)
                        }
                    }
            )
            .onAppear { viewStore.send(.onAppear) }
        }
    }

    @ViewBuilder func DAppList() -> some View {
        WithViewStore(store.scope(state: \.sessions)) { viewStore in
            ScrollView {
                LazyVStack {
                    ForEach(viewStore.state.indexed(), id: \.element) { index, session in
                        if index != viewStore.state.startIndex {
                            PrimaryDivider()
                        }
                        DAppItem(session: .init(session: session)).onTapGesture {
                            viewStore.send(.showSessionDetails(session))
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder func DAppItem(session: DAppListState.DAppViewState) -> some View {
        HStack(spacing: 16) {
            if let imageResource = session.imageResource {
                ImageResourceView(imageResource, placeholder: { Color.viewPrimaryBackground })
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 24, height: 24)
                    .cornerRadius(4)
            }
            VStack(alignment: .leading, spacing: 8) {
                Text(session.name)
                    .typography(.body2)
                    .lineLimit(1)
                Text(session.domain)
                    .typography(.paragraph1)
                    .foregroundColor(.textSubheading)
            }
            Spacer()
            ImageResourceView(systemName: "ellipsis")
                .foregroundColor(.textSubheading)
                .frame(width: 16, height: 4)
        }
        .backgroundTexture(.white)
        .frame(height: 79)
        .padding([.horizontal], 24)
    }
}
