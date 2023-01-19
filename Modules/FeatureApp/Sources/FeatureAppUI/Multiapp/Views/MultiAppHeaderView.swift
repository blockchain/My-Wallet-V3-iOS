// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import SwiftUI

struct MultiAppHeader: ReducerProtocol {
    struct State: Equatable {
        var isRefreshing: Bool = false
        @BindableState var totalBalance: String = ""
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
    }

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
    }
}

@available(iOS 15.0, *)
struct MultiAppHeaderView: View {
    @Environment(\.refresh) var refreshAction: RefreshAction?
    let store: StoreOf<MultiAppHeader>

    @Binding var currentSelection: AppMode
    @Binding var contentOffset: ModalSheetContext
    @Binding var scrollOffset: CGPoint
    @Binding var isRefreshing: Bool

    @StateObject private var contentFrame = ViewFrame()
    @StateObject private var menuContentFrame = ViewFrame()

    @State private var appeared: Bool = false
    @State private var task: Task<Void, Error>? {
        didSet { oldValue?.cancel() }
    }

    private var thresholdOffsetForRefreshTrigger: CGFloat = Spacing.padding4 * 2.0

    init(
        store: StoreOf<MultiAppHeader>,
        currentSelection: Binding<AppMode>,
        contentOffset: Binding<ModalSheetContext>,
        scrollOffset: Binding<CGPoint>,
        isRefreshing: Binding<Bool>
    ) {
        self.store = store
        _currentSelection = currentSelection
        _contentOffset = contentOffset
        _scrollOffset = scrollOffset
        _isRefreshing = isRefreshing
    }

    var body: some View {
        WithViewStore(
            store,
            observe: { $0 },
            content: { viewStore in
                ZStack(alignment: .top) {
                    ProgressView()
                        .offset(y: calculateOffset())
                        .zIndex(1)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .opacity(isRefreshing ? 1.0 : opacityForRefreshIndicator(percentageOffset: 1.0))
                    VStack {
                        VStack(spacing: Spacing.padding2) {
                            TotalBalanceView(balance: viewStore.totalBalance)
                                .opacity(isRefreshing ? 0.0 : opacityForBalance(percentageOffset: 2.0))
                            MultiAppSwitcherView(currentSelection: $currentSelection)
                                .frameGetter($menuContentFrame.frame)
                                .opacity(opacityForMenu())
                        }
                        .frameGetter($contentFrame.frame)
                        .offset(y: calculateOffset())
                        .animation(.interactiveSpring(), value: contentOffset)
                        Spacer()
                    }
                }
                .onAppear {
                    guard !appeared else {
                        return
                    }
                    appeared = true
                    task = Task {
                        try await Task.sleep(nanoseconds: 1 * 1000000000)
                        isRefreshing = true
                        await refreshAction?()
                        withAnimation {
                            isRefreshing = false
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .background(
                    Color.clear
                        .animatableLinearGradient(
                            fromColors: AppMode.trading.backgroundGradient,
                            toColors: AppMode.pkw.backgroundGradient,
                            startPoint: .leading,
                            endPoint: .trailing,
                            percent: currentSelection.isTrading ? 0 : 1
                        )
                        .ignoresSafeArea()
                )
            }
        )
    }

    // MARK: Private Helpers

    private func opacity(percentageOffset: CGFloat) -> CGFloat {
        contentOffset.progress * percentageOffset
    }

    private func reverseOpacity(percentageOffset: CGFloat) -> CGFloat {
        abs(reverseProgress() * percentageOffset)
    }

    private func opacityForRefreshIndicator(percentageOffset: CGFloat) -> CGFloat {
        if contentOffset.progress < 1.0 {
            return 0.0
        }
        return reverseOpacity(percentageOffset: percentageOffset)
    }

    private func opacityForBalance(percentageOffset: CGFloat) -> CGFloat {
        if contentOffset.progress > 1.1 || contentOffset.progress < 0.8 {
            return 1.0 - reverseOpacity(percentageOffset: percentageOffset)
        }
        return opacity(percentageOffset: percentageOffset)
    }

    private func opacityForMenu() -> CGFloat {
        if contentOffset.progress < 0.5 {
            return opacity(percentageOffset: 2.0)
        }
        return 1.0
    }

    private func reverseProgress() -> CGFloat {
        abs(1.0 - contentOffset.progress)
    }

    private func calculateOffset() -> CGFloat {
        let adjustedHeight = contentFrame.frame.height + Spacing.padding1
        if contentOffset.offset.y > adjustedHeight {
            if let refreshAction {
                let thresholdForRefresh = adjustedHeight + thresholdOffsetForRefreshTrigger
                if contentOffset.offset.y > thresholdForRefresh {
                    task = Task {
                        guard !isRefreshing, !Task.isCancelled else { return }
                        isRefreshing = true
                        await refreshAction()
                        withAnimation {
                            isRefreshing = false
                        }
                    }
                }
            }
            return contentOffset.offset.y - adjustedHeight
        }
        let offset = contentOffset.offset.y - adjustedHeight
        let max = -menuContentFrame.frame.height - Spacing.padding1
        return offset < max ? max : contentOffset.offset.y - adjustedHeight
    }
}

@available(iOS 15.0, *)
struct MultiappHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MultiAppHeaderView(
                store: Store(initialState: .init(totalBalance: "$278,031.12"), reducer: MultiAppHeader()),
                currentSelection: .constant(.trading),
                contentOffset: .constant(ModalSheetContext(progress: 1.0, offset: .zero)),
                scrollOffset: .constant(.zero),
                isRefreshing: .constant(false)
            )
            .previewDisplayName("Trading Selected")

            MultiAppHeaderView(
                store: Store(initialState: .init(totalBalance: "$278,031.12"), reducer: MultiAppHeader()),
                currentSelection: .constant(.pkw),
                contentOffset: .constant(ModalSheetContext(progress: 1.0, offset: .zero)),
                scrollOffset: .constant(.zero),
                isRefreshing: .constant(false)
            )
            .previewDisplayName("DeFi Selected")

            MultiAppHeaderView(
                store: Store(initialState: .init(totalBalance: "$278,031.12"), reducer: MultiAppHeader()),
                currentSelection: .constant(.pkw),
                contentOffset: .constant(ModalSheetContext(progress: 1.0, offset: .zero)),
                scrollOffset: .constant(.zero),
                isRefreshing: .constant(true)
            )
            .previewDisplayName("Pull to refresh")
        }
    }
}
