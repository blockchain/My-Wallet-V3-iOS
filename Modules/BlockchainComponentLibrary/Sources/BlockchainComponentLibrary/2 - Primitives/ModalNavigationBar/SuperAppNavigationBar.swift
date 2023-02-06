// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import SwiftUI

#if os(iOS)
@available(iOS 15, *)
extension View {

    /// Applies a fake navigation bar with a leading, title and trailing content
    /// This is not a real navigation bar that handles a stack of views,
    /// but rather a UI empelishment in use with certain modals
    /// - Parameters:
    ///   - leading: A ViewBuilder for the Leading item
    ///   - title: A ViewBuilder for the Title item
    ///   - trailing: A ViewBuilder for the Trailing item
    ///   - titleShouldFollowScroll: Bool Set to `true` if title should appear when `scrollOffset` changes,
    ///   ignored if scrollOffset is not set
    ///   - titleExtraOffset: An extra offset for the title content to fade in, ignored if scrollOffset is not set
    ///   - scrollOffset: A `Binding<CGFloat>` that reflects a scrollview offset
    /// - Returns: A View
    public func superAppNavigationBar(
        @ViewBuilder leading: @escaping () -> some View,
        @ViewBuilder title: @escaping () -> some View,
        @ViewBuilder trailing: @escaping () -> some View,
        titleShouldFollowScroll: Bool,
        titleExtraOffset: CGFloat,
        scrollOffset: Binding<CGFloat>?
    ) -> some View {
        modifier(
            SuperAppNavigationBarModifier(
                leading: leading,
                title: title,
                trailing: trailing,
                titleShouldFollowScroll: titleShouldFollowScroll,
                titleExtraOffset: titleExtraOffset,
                scrollOffset: scrollOffset
            )
        )
    }

    /// Applies a fake navigation bar with a leading, title and trailing content
    /// This is not a real navigation bar that handles a stack of views,
    /// but rather a UI empelishment in use with certain modals
    /// - Parameters:
    ///   - leading: A ViewBuilder for the Leading item
    ///   - title: A ViewBuilder for the Title item
    ///   - trailing: A ViewBuilder for the Trailing item
    /// - Returns: A View
    public func superAppNavigationBar(
        @ViewBuilder leading: @escaping () -> some View,
        @ViewBuilder title: @escaping () -> some View,
        @ViewBuilder trailing: @escaping () -> some View,
        scrollOffset: Binding<CGFloat>?
    ) -> some View {
        modifier(
            SuperAppNavigationBarModifier(
                leading: leading,
                title: title,
                trailing: trailing,
                titleShouldFollowScroll: false,
                titleExtraOffset: 0,
                scrollOffset: scrollOffset
            )
        )
    }

    /// Applies a fake navigation bar with a leading, title and trailing content
    /// This is not a real navigation bar that handles a stack of views,
    /// but rather a UI empelishment in use with certain modals
    /// - Parameters:
    ///   - leading: A ViewBuilder for the Leading item
    ///   - title: A ViewBuilder for the Title item
    ///   - trailing: A ViewBuilder for the Trailing item
    /// - Returns: A View
    public func superAppNavigationBar(
        @ViewBuilder title: @escaping () -> some View,
        @ViewBuilder trailing: @escaping () -> some View,
        scrollOffset: Binding<CGFloat>?
    ) -> some View {
        modifier(
            SuperAppNavigationBarModifier(
                leading: { Spacer().frame(width: 0) },
                title: title,
                trailing: trailing,
                titleShouldFollowScroll: false,
                titleExtraOffset: 0,
                scrollOffset: scrollOffset
            )
        )
    }

    /// Applies a fake navigation bar with a leading, title and trailing content
    /// This is not a real navigation bar that handles a stack of views,
    /// but rather a UI empelishment in use with certain modals
    /// - Parameters:
    ///   - leading: A ViewBuilder for the Leading item
    ///   - title: A ViewBuilder for the Title item
    ///   - trailing: A ViewBuilder for the Trailing item
    /// - Returns: A View
    public func superAppNavigationBar(
        @ViewBuilder leading: @escaping () -> some View,
        @ViewBuilder trailing: @escaping () -> some View,
        scrollOffset: Binding<CGFloat>?
    ) -> some View {
        modifier(
            SuperAppNavigationBarModifier(
                leading: leading,
                title: { Spacer().frame(width: 0) },
                trailing: trailing,
                titleShouldFollowScroll: false,
                titleExtraOffset: 0,
                scrollOffset: scrollOffset
            )
        )
    }

    /// Applies a fake navigation bar with a leading, title and trailing content
    /// This is not a real navigation bar that handles a stack of views,
    /// but rather a UI empelishment in use with certain modals
    /// - Parameters:
    ///   - title: A ViewBuilder for the Title item
    ///   - titleShouldFollowScroll: Bool Set to `true` if title should appear when `scrollOffset` changes,
    ///   ignored if scrollOffset is not set
    ///   - titleExtraOffset: An extra offset for the title content to fade in, ignored if scrollOffset is not set
    ///   - scrollOffset: A `Binding<CGFloat>` that reflects a scrollview offset
    /// - Returns: A View
    public func superAppNavigationBar(
        @ViewBuilder title: @escaping () -> some View,
        titleShouldFollowScroll: Bool,
        titleExtraOffset: CGFloat,
        scrollOffset: Binding<CGFloat>?
    ) -> some View {
        modifier(
            SuperAppNavigationBarModifier(
                leading: { Spacer().frame(width: 0) },
                title: title,
                trailing: { Spacer().frame(width: 0) },
                titleShouldFollowScroll: titleShouldFollowScroll,
                titleExtraOffset: titleExtraOffset,
                scrollOffset: scrollOffset
            )
        )
    }
}

@available(iOS 15, *)
struct SuperAppNavigationBar<Leading: View, Title: View, Trailing: View>: View {
    let leading: Leading
    let title: Title
    let trailing: Trailing
    /// Set to `true` if the title content should appear when content is scrolling up, ignored when `scrollOffset` is not set
    var titleShouldFollowScroll: Bool
    /// A `CGFloat` to be taken into account on when to show the title while scrolling, ignored when `scrollOffset` is not set
    var titleExtraOffset: CGFloat
    var scrollOffset: Binding<CGFloat>?

    private var _scrollOffset: Binding<CGFloat> {
        scrollOffset ?? .constant(0)
    }

    var hasActiveScrollOffset: Bool {
        scrollOffset != nil
    }

    private var topThreshold = Spacing.padding6 - Spacing.padding1

    init(
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder title: () -> Title,
        @ViewBuilder trailing: () -> Trailing,
        titleShouldFollowScroll: Bool,
        titleExtraOffset: CGFloat,
        scrollOffset: Binding<CGFloat>?
    ) {
        self.leading = leading()
        self.title = title()
        self.trailing = trailing()
        self.titleShouldFollowScroll = titleShouldFollowScroll
        self.titleExtraOffset = titleExtraOffset
        self.scrollOffset = scrollOffset
    }

    var body: some View {
        HStack {
            leading
                .frame(idealHeight: 32.pt, maxHeight: 32.pt)
                .padding(.leading, Spacing.padding1)
            Spacer()
            title
                .opacity(opacityForTitle())
            Spacer()
            trailing
                .frame(idealHeight: 32.pt, maxHeight: 32.pt)
                .padding(.trailing, Spacing.padding1)
        }
        .frame(height: Spacing.padding6)
        .background(
            .bar.opacity(getOpacity(topThreshold, opacityMin: 0.0, opacityMax: 1.0)),
            in: RoundedRectangle(cornerRadius: Spacing.padding2)
        )
        .background {
            RoundedRectangle(cornerRadius: Spacing.padding2)
                .fill(Color.semantic.light)
                .opacity(hasActiveScrollOffset ? getOpacity(topThreshold, opacityMin: 1.0, opacityMax: 0.0) : 1.0)
        }
        .shadow(color: .black.opacity(getOpacity(topThreshold, opacityMin: 0.0, opacityMax: 0.1)), radius: 8, x: 0, y: 3)
        .animation(.easeOut(duration: 0.1), value: _scrollOffset.wrappedValue)
    }

    private func opacityForTitle() -> CGFloat {
        guard let scrollOffset else {
            return 1.0
        }
        guard titleShouldFollowScroll else {
            return 1.0
        }

        let threshold = topThreshold - titleExtraOffset
        return scrollOffset.wrappedValue > -threshold ? 1.0 : 0.0
    }

    private func getOpacity(_ threshold: CGFloat, opacityMin: CGFloat, opacityMax: CGFloat) -> CGFloat {
        guard let scrollOffset else {
            return 0.0
        }
        return scrollOffset.wrappedValue > -threshold ? opacityMax : opacityMin
    }
}

@available(iOS 15.0, *)
public struct SuperAppNavigationBarModifier<Leading: View, Title: View, Trailing: View>: ViewModifier {

    @ViewBuilder let leading: () -> Leading
    @ViewBuilder let title: () -> Title
    @ViewBuilder let trailing: () -> Trailing
    var titleShouldFollowScroll: Bool
    var titleExtraOffset: CGFloat
    var scrollOffset: Binding<CGFloat>?

    public init(
        leading: @escaping () -> Leading,
        title: @escaping () -> Title,
        trailing: @escaping () -> Trailing,
        titleShouldFollowScroll: Bool,
        titleExtraOffset: CGFloat,
        scrollOffset: Binding<CGFloat>? = nil
    ) {
        self.leading = leading
        self.title = title
        self.trailing = trailing
        self.titleShouldFollowScroll = titleShouldFollowScroll
        self.titleExtraOffset = titleExtraOffset
        self.scrollOffset = scrollOffset
    }

    public func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .top, content: {
                Spacer()
                    .frame(height: Spacing.padding6)
            })
            .overlay(alignment: .top) {
                ZStack(alignment: .top) {
                    // top part for hiding content
                    Color.semantic.light
                        .frame(height: Spacing.padding2)
                    // the actual nav bar
                    SuperAppNavigationBar(
                        leading: leading,
                        title: title,
                        trailing: trailing,
                        titleShouldFollowScroll: titleShouldFollowScroll,
                        titleExtraOffset: titleExtraOffset,
                        scrollOffset: scrollOffset
                    )
                    .padding(Spacing.padding1)
                }
                .onAppear {
                    scrollOffset?.wrappedValue = -Spacing.padding6
                }
            }
    }
}

public class ScrollViewOffsetObserver: NSObject, UIScrollViewDelegate, ObservableObject {
    public var didScroll: ((CGPoint) -> Void)?

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        didScroll?(scrollView.contentOffset)
    }
}
#endif
