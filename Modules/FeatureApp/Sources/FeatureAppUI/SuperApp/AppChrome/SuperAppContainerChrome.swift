// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitecture
import SwiftUI

/// Contains the interactive or static chrome
@available(iOS 15, *)
public struct SuperAppContainerChrome: View {
    /// The current selected app mode
    @State private var currentModeSelection: AppMode
    /// The content offset for the modal sheet
    @State private var contentOffset: ModalSheetContext = .init(progress: 1.0, offset: .zero)
    /// `True` when a pull to refresh is triggered, otherwise `false`
    @State private var isRefreshing: Bool = false

    private var app: AppProtocol
    private let __isSmallDevice: Bool
    private let store: StoreOf<SuperAppContent>

    init(app: AppProtocol, isSmallDevice: Bool) {
        self.app = app
        self.__isSmallDevice = isSmallDevice
        self.store = Store(
            initialState: .init(),
            reducer: SuperAppContent(
                app: app
            )
        )
        self.currentModeSelection = app.currentMode
    }

    public var body: some View {
        if #available(iOS 16, *) {
            SuperAppContentView(
                store: store,
                currentModeSelection: $currentModeSelection,
                contentOffset: $contentOffset,
                isRefreshing: $isRefreshing
            )
            .app(app)
        } else if __isSmallDevice {
            SuperAppContentViewSmallDevice(
                store: store,
                currentModeSelection: $currentModeSelection,
                contentOffset: $contentOffset,
                isRefreshing: $isRefreshing
            )
            .isSmallDevice(__isSmallDevice)
            .app(app)
        } else {
            SuperAppContentView(
                store: store,
                currentModeSelection: $currentModeSelection,
                contentOffset: $contentOffset,
                isRefreshing: $isRefreshing
            )
            .app(app)
        }
    }
}
