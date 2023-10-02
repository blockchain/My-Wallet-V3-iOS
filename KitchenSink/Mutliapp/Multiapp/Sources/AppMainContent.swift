//
//  AppMainContent.swift
//  MultiappExample
//
//  Created by Dimitris Chatzieleftheriou on 27/09/2022.
//

import SwiftUI
import UIKit

struct AppMainContent: View {
    @State private var currentModeSelection: Mode = .trading
    /// The content offset for the modal sheet
    @State private var contentOffset: ModalSheetContext = .init(progress: 1.0, offset: .zero)
    /// The scroll offset for the inner scroll view, not currently used...
    @State private var scrollOffset: CGPoint = .zero

    @State private var isRefreshing: Bool = false

    var body: some View {
        if #available(iOS 16.0, *) {
            InteractiveMultiAppContent(
                currentModeSelection: $currentModeSelection,
                contentOffset: $contentOffset,
                scrollOffset: $scrollOffset,
                isRefreshing: $isRefreshing
            )
        } else {
            StaticMultiAppContent(
                currentModeSelection: $currentModeSelection,
                contentOffset: $contentOffset,
                scrollOffset: $scrollOffset,
                //                selectedDetent: $selectedDetent,
                isRefreshing: $isRefreshing
            )
        }
    }

    // temp for demo purposes.
    private func temp() async {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
    }
}

struct StaticMultiAppContent: View {
    @Binding var currentModeSelection: Mode
    /// The content offset for the modal sheet
    @Binding var contentOffset: ModalSheetContext
    /// The scroll offset for the inner scroll view, not currently used...
    @Binding var scrollOffset: CGPoint
    //    @Binding var selectedDetent: PresentationDetent

    @Binding var isRefreshing: Bool

    var body: some View {
        VStack(spacing: 8) {
            MultiappHeaderView(
                currentSelection: $currentModeSelection,
                contentOffset: $contentOffset,
                scrollOffset: $scrollOffset,
                isRefreshing: $isRefreshing
            )
            .refreshable {
                await tempAsyncDelayMethod()
            }
            MainContentView(
                scrollOffset: $scrollOffset,
                //                selectedDetent: $selectedDetent,
                content: {
                    ZStack {
                        MultiappTradingView()
                            .opacity(currentModeSelection.isTrading ? 1.0 : 0.0)
                        MultiappDefiView()
                            .opacity(currentModeSelection.isDefi ? 1.0 : 0.0)
                    }
                }
            )
            .frame(maxWidth: .infinity)
            .background(
                Color.semantic.light
                    .ignoresSafeArea(edges: .bottom)
            )
            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: -1)
        }
        .background(
            Color.clear
                .animatableLinearGradient(
                    fromColors: Mode.trading.backgroundGradient,
                    toColors: Mode.defi.backgroundGradient,
                    startPoint: .leading,
                    endPoint: .trailing,
                    percent: currentModeSelection.isTrading ? 0 : 1
                )
                .ignoresSafeArea()
        )
    }
}

@available(iOS 16.0, *)
struct InteractiveMultiAppContent: View {
    @Binding var currentModeSelection: Mode
    /// The content offset for the modal sheet
    @Binding var contentOffset: ModalSheetContext
    /// The scroll offset for the inner scroll view, not currently used...
    @Binding var scrollOffset: CGPoint

    @State private var selectedDetent = SwiftUI.PresentationDetent.collapsed

    @Binding var isRefreshing: Bool

    var body: some View {
        MultiappHeaderView(
            currentSelection: $currentModeSelection,
            contentOffset: $contentOffset,
            scrollOffset: $scrollOffset,
            isRefreshing: $isRefreshing
        )
        .refreshable {
            await tempAsyncDelayMethod()
        }
        .sheet(isPresented: .constant(true), content: {
            MainContentView(
                scrollOffset: $scrollOffset,
                //                selectedDetent: $selectedDetent,
                content: {
                    ZStack {
                        MultiappTradingView()
                            .opacity(currentModeSelection.isTrading ? 1.0 : 0.0)
                        MultiappDefiView()
                            .opacity(currentModeSelection.isDefi ? 1.0 : 0.0)
                    }
                }
            )
            .frame(maxWidth: .infinity)
            .background(
                Color(hex: "F0F2F7")
                    .ignoresSafeArea(edges: .bottom)
            )
            .presentationDetents(
                [
                    .collapsed,
                    .expanded
                ],
                selection: $selectedDetent
            )
            .presentationDragIndicator(.hidden)
            // the "Custom:CollpsedDetent" is the name the system gives to a custom detent
            .largestUndimmedDetentIdentifier("Custom:CollapsedDetent", modalOffset: $contentOffset)
            .interactiveDismissDisabled(true)
        })
    }
}

// temp for demo purposes.
func tempAsyncDelayMethod() async {
    try? await Task.sleep(nanoseconds: 2_000_000_000)
}

func interactiveExperienceAvailabe() -> Bool {
    if #available(iOS 16.0, *) {
        return true
    }
    return false
}

// Needed for somewhat backport this for @State properties...

struct PresentationDetent: Hashable, Equatable {
    static let collapsed: PresentationDetent = .init(id: .init(rawValue: "Custom:CollasedDetent"))
    static let expanded: PresentationDetent = .init(id: .init(rawValue: "Custom:ExpandedDetent"))

    public struct Identifier: RawRepresentable, Hashable {
        public var rawValue: String
        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public static var medium: Identifier {
            .init(rawValue: "com.apple.UIKit.medium")
        }

        public static var large: Identifier {
            .init(rawValue: "com.apple.UIKit.large")
        }
    }

    public let id: Identifier
}

// MARK: PresentationDetent for iOS 16 and above

@available(iOS 16.0, *)
extension SwiftUI.PresentationDetent {
    static let collapsed = Self.custom(CollapsedDetent.self)
    static let expanded = Self.custom(ExpandedDetent.self)
}

@available(iOS 16.0, *)
protocol FractionCustomPresentationDetent: CustomPresentationDetent {
    static var fraction: CGFloat { get }
}

@available(iOS 16.0, *)
struct CollapsedDetent: FractionCustomPresentationDetent {
    static let fraction: CGFloat = 0.9

    static func height(in context: Context) -> CGFloat? {
        // this fixed fraction is really not that great
        // quite tricky to pass in an updated fraction based on the header height...
        context.maxDetentValue * fraction
    }
}

@available(iOS 16.0, *)
struct ExpandedDetent: FractionCustomPresentationDetent {
    static let fraction: CGFloat = 0.9999
    static func height(in context: Context) -> CGFloat? {
        context.maxDetentValue * fraction
    }
}

// MARK: - Previews

struct AppMainContent_Previews: PreviewProvider {
    static var previews: some View {
        AppMainContent()
    }
}
