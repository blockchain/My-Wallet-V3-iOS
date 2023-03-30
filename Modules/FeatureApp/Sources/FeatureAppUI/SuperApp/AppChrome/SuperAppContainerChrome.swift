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
    /// The scroll offset for the inner scroll view, not currently used...
    @State private var scrollOffset: CGPoint = .zero
    /// `True` when a pull to refresh is triggered, otherwise `false`
    @State private var isRefreshing: Bool = false

    private var app: AppProtocol
    private let store: StoreOf<SuperAppContent>

    init(app: AppProtocol) {
        self.app = app
        self.store = Store(
            initialState: .init(),
            reducer: SuperAppContent(
                app: app
            )
        )
        self.currentModeSelection = app.currentMode
    }

    public var body: some View {
        SuperAppContentView(
            store: store,
            currentModeSelection: $currentModeSelection,
            contentOffset: $contentOffset,
            scrollOffset: $scrollOffset,
            isRefreshing: $isRefreshing
        )
        .app(app)
    }
}
