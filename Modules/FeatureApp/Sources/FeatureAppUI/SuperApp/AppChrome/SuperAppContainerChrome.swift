// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitecture
import SwiftUI

/// Contains the interactive or static chrome
public struct SuperAppContainerChrome: View {
    /// The current selected app mode
    @State private var currentModeSelection: AppMode
    /// The content offset for the modal sheet
    @State private var contentOffset: ModalSheetContext = .init(progress: 1.0, offset: .zero)
    /// `True` when a pull to refresh is triggered, otherwise `false`
    @State private var isRefreshing: Bool = false

    private var app: AppProtocol
    private let isSmallDevice: Bool
    private let store: StoreOf<SuperAppContent>

    init(app: AppProtocol, isSmallDevice: Bool) {
        self.app = app
        self.isSmallDevice = isSmallDevice
        self.store = Store(
            initialState: .init(),
            reducer: SuperAppContent(
                app: app
            )
        )
        self.currentModeSelection = app.currentMode
    }

    @ViewBuilder
    public var body: some View {
        if isIos15, isSmallDevice {
            SuperAppContentViewSmallDevice(
                store: store,
                currentModeSelection: $currentModeSelection,
                contentOffset: $contentOffset,
                isRefreshing: $isRefreshing
            )
            .isSmallDevice(isSmallDevice)
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

    private var isIos15: Bool {
        if #available(iOS 16, *) {
            return false
        }
        return true
    }
}
