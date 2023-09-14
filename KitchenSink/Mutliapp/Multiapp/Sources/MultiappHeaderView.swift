//
//  MultiappHeaderView.swift
//  MultiappExample
//
//  Created by Dimitris Chatzieleftheriou on 27/09/2022.
//

import BlockchainComponentLibrary
import SwiftUI

struct MultiappHeaderView: View {
    @Environment(\.refresh) var refreshAction: RefreshAction?

    @Binding var currentSelection: Mode
    @Binding var contentOffset: ModalSheetContext
    @Binding var scrollOffset: CGPoint

    @Binding var isRefreshing: Bool

    @StateObject private var contentFrame = ViewFrame()
    private var thresholdOffsetForRefreshTrigger: CGFloat = Spacing.padding4 * 2.0

    init(
        currentSelection: Binding<Mode>,
        contentOffset: Binding<ModalSheetContext>,
        scrollOffset: Binding<CGPoint>,
        isRefreshing: Binding<Bool>
    ) {
        _currentSelection = currentSelection
        _contentOffset = contentOffset
        _scrollOffset = scrollOffset
        _isRefreshing = isRefreshing
    }

    var body: some View {
        ZStack(alignment: .top) {
            ProgressView()
                .offset(y: calculateOffset())
                .zIndex(1)
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .opacity(isRefreshing ? 1.0 : opacityForRefreshIndicator(percentageOffset: 1.0))
            VStack {
                VStack(spacing: Spacing.padding2) {
                    TotalBalanceView(balance: "$278,031.12")
                        .opacity(isRefreshing ? 0.0 : opacityForBalance(percentageOffset: 1.5))
                    MutliappSwitcherView(currentSelection: $currentSelection)
                }
                .frameGetter($contentFrame.frame)
                .offset(y: calculateOffset())
                .animation(.interactiveSpring(), value: contentOffset)
                if interactiveExperienceAvailabe() {
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(
            Color.clear
                .animatableLinearGradient(
                    fromColors: Mode.trading.backgroundGradient,
                    toColors: Mode.defi.backgroundGradient,
                    startPoint: .leading,
                    endPoint: .trailing,
                    percent: currentSelection.isTrading ? 0 : 1
                )
                .ignoresSafeArea()
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
        guard interactiveExperienceAvailabe() else {
            return fallbackToScrollOffset()
        }
        if contentOffset.progress < 1.0 {
            return 0.0
        }
        return reverseOpacity(percentageOffset: percentageOffset)
    }

    private func fallbackToScrollOffset() -> CGFloat {
        if scrollOffset.y < 0.0 {
            let heightAdjusted = contentFrame.frame.height + thresholdOffsetForRefreshTrigger
            let adjustedOffset = abs(scrollOffset.y) / heightAdjusted
            if let refreshAction {
                if adjustedOffset > 1.1 {
                    Task {
                        isRefreshing = true
                        await refreshAction()
                        withAnimation {
                            isRefreshing = false
                        }
                    }
                }
            }
            return adjustedOffset
        }
        return 0.0
    }

    private func opacityForBalance(percentageOffset: CGFloat) -> CGFloat {
        guard interactiveExperienceAvailabe() else {
            return 1.0 - fallbackToScrollOffset()
        }
        if contentOffset.progress > 1.1 {
            return 1.0 - reverseOpacity(percentageOffset: percentageOffset)
        }
        return opacity(percentageOffset: percentageOffset)
    }

    private func reverseProgress() -> CGFloat {
        abs(1.0 - contentOffset.progress)
    }

    private func calculateOffset() -> CGFloat {
        let adjustedHeight = contentFrame.frame.height + Spacing.padding2
        if contentOffset.offset.y > adjustedHeight {
            if let refreshAction {
                let thresholdForRefresh = adjustedHeight + thresholdOffsetForRefreshTrigger
                if contentOffset.offset.y > thresholdForRefresh, !isRefreshing {
                    Task {
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
        return 0.0
    }
}

struct MultiappHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        MultiappHeaderView(
            currentSelection: .constant(.trading),
            contentOffset: .constant(.zero),
            scrollOffset: .constant(.zero),
            isRefreshing: .constant(false)
        )
    }
}
