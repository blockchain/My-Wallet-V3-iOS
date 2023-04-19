import BlockchainComponentLibrary
import Combine
import SwiftUI
import UIKit

struct MainContentView<Content: View>: View {
    let content: Content
    @Binding var scrollOffset: CGPoint
    // we might need this for iOS 16 only
//    @Binding var selectedDetent: PresentationDetent

    @State private var _uiScrollView: UIScrollView?
    @StateObject private var scrollViewDelegate = ScrollViewDelegate()

    init(
        scrollOffset: Binding<CGPoint>,
//        selectedDetent: Binding<PresentationDetent>,
        @ViewBuilder content: () -> Content
    ) {
        _scrollOffset = scrollOffset
//        self._selectedDetent = selectedDetent
        self.content = content()
    }

    var body: some View {
        content
            .findScrollView { scrollView in
                // not used... do we need it?
                scrollView.delegate = scrollViewDelegate
                scrollViewDelegate.didScroll = { scrollView in
                    scrollOffset = CGPoint(x: scrollView.contentOffset.x, y: scrollView.contentOffset.y + scrollView.contentInset.top)
                }
                scrollViewDelegate.didEndDragging = { _ in
//                    selectedDetent = .collapsed
                }
                _uiScrollView = scrollView
            }
    }
}

struct MultiappTradingView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 1) {
                    ForEach(0..<20) { value in
                        PrimaryRow(
                            title: "Trading \(value)",
                            subtitle: "Buy & Sell",
                            action: {}
                        )
                    }
                }
                .navigationTitle("Trading")
                .navigationBarTitleDisplayMode(.inline)
                //        .navigationBarHidden(true)
                .frame(maxWidth: .infinity)
            }
        }
    }
}

struct MultiappDefiView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 1) {
                    ForEach(0..<20) { value in
                        PrimaryRow(
                            title: "Defi \(value)",
                            subtitle: "Buy & Sell",
                            action: {}
                        )
                    }
                }
                .navigationTitle("DeFi")
                .navigationBarTitleDisplayMode(.inline)
                //        .navigationBarHidden(true)
                .frame(maxWidth: .infinity)
            }
        }
    }
}

extension View {
    public func findScrollView(customize: @escaping (UIScrollView) -> Void) -> some View {
        inject(UIKitIntrospection(
            selector: { introspectionView in
                guard let viewHost = Introspect.findViewHost(introspectionView) else {
                    return nil
                }
                return Introspect.previousSibling(containing: UIScrollView.self, from: viewHost)
            },
            customize: customize
        ))
    }
}
