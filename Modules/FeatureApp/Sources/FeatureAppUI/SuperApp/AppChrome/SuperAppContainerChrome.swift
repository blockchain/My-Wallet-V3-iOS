// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitecture
import SwiftUI

/// Contains the interactive or static chrome
public struct SuperAppContainerChrome: View {
    @BlockchainApp var app
    /// The content offset for the modal sheet
    @State private var contentOffset: ModalSheetContext = .init(progress: 1.0, offset: .zero)
    /// `True` when a pull to refresh is triggered, otherwise `false`
    @State private var isRefreshing: Bool = false

    private let isSmallDevice: Bool
    private let store: StoreOf<SuperAppContent>
    @ObservedObject var viewStore: ViewStoreOf<SuperAppContent>

    init(
        store: StoreOf<SuperAppContent>,
        isSmallDevice: Bool
    ) {
        self.isSmallDevice = isSmallDevice
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    @ViewBuilder
    public var body: some View {
        if isIos15, isSmallDevice {
            SuperAppContentViewSmallDevice(
                store: store,
                currentModeSelection: viewStore.appMode,
                contentOffset: $contentOffset,
                isRefreshing: $isRefreshing
            )
            .isSmallDevice(isSmallDevice)
            .app(app)
            .onAppear {
                viewStore.send(.onAppear)
            }
        } else {
            AppLoaderView {
                SuperAppContentView(
                    store: store,
                    currentModeSelection: viewStore.appMode,
                    contentOffset: $contentOffset,
                    isRefreshing: $isRefreshing
                )
                .app(app)
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }

    private var isIos15: Bool {
        if #available(iOS 16, *) {
            return false
        }
        return true
    }
}
