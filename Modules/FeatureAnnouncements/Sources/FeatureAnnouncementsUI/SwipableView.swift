// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import SwiftUI

@MainActor
struct SwipableView<Content>: View where Content: View {

    enum SwipeDirection {
        case left
        case right
    }

    @State private var offset = CGSize.zero
    @ViewBuilder let content: () -> Content
    let onSwiped: ((SwipeDirection) -> Void)?

    init(
        onSwiped: ((SwipeDirection) -> Void)?,
        content: @escaping () -> Content
    ) {
        self.onSwiped = onSwiped
        self.content = content
    }

    var body: some View {
        content()
            .offset(x: offset.width, y: offset.height * 0.1)
            .rotationEffect(.degrees(Double(offset.width / 100)))
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        offset = gesture.translation
                    }
                    .onEnded { _ in
                        withAnimation {
                            swipeCard(width: offset.width)
                        }
                    }
            )
    }

    func swipeCard(width: CGFloat) {
        switch width {
        case _ where width < -150:
            onSwiped?(.left)
            offset = CGSize(width: -500, height: 0)
        case _ where width > 150:
            onSwiped?(.right)
            offset = CGSize(width: 500, height: 0)
        default:
            offset = .zero
        }
    }
}
