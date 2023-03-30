import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import FeatureAnnouncementsDomain
import Localization
import SwiftUI

@MainActor
public struct FeatureAnnouncementsView: View {
    let store: StoreOf<FeatureAnnouncements>

    public init(store: StoreOf<FeatureAnnouncements>) {
        self.store = store
        ViewStore(store).send(.initialize)
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            if !viewStore.announcements.isEmpty || viewStore.showCompletion {
                contentView
            } else {
                EmptyView()
            }
        }
    }

    @ViewBuilder func completionView(_ completion: @escaping () -> Void) -> some View {
        WithViewStore(store.scope(state: \.showCompletion)) { viewStore in
            if viewStore.state {
                Text(LocalizationConstants.Announcements.done)
                    .typography(.title3)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                completion()
                            }
                        }
                    }
            } else {
                EmptyView()
            }
        }
    }

    @ViewBuilder func badge(count: Int) -> some View {
        if #available(iOS 15, *), count > 0 {
            Text(String(count))
                .typography(.body2)
                .foregroundColor(.white)
                .background {
                    Circle()
                        .foregroundColor(.semantic.primary)
                        .frame(width: 32, height: 32)
                }
                .padding(.trailing, 16)
                .padding(.top, -3)
        } else {
            EmptyView()
        }
    }

    @ViewBuilder var contentView: some View {
        WithViewStore(store.scope(state: \.announcements)) { viewStore in
            ZStack(alignment: .topTrailing) {
                ZStack(alignment: .center) {
                    completionView {
                        viewStore.send(.hideCompletion)
                    }
                    ForEach(viewStore.state, id: \.id) { announcement in
                        SwipableView(onSwiped: { _ in
                            viewStore.send(.dismiss(announcement, .swipe))
                        }) {
                            CardView(
                                announcement: announcement,
                                shadowed: announcement == viewStore.state.last
                                || announcement == viewStore.state.first
                            ) {
                                viewStore.send(.open(announcement))
                            }
                        }
                        .scaleEffect(announcement != viewStore.state.last ? CGSize(width: 0.9, height: 0.9) : CGSize(width: 1, height: 1), anchor: .top)
                        .offset(x: 0, y: announcement != viewStore.state.last ? -7 : 0)
                    }
                }
                badge(count: viewStore.state.count)
            }
            .task {
                viewStore.send(.fetchAnnouncements(false))
            }
        }
    }
}

@MainActor
struct SwipableView<Content>: View where Content : View {

    enum SwipeDirection {
        case left
        case right
    }

    @State private var offset = CGSize.zero
    let onSwiped: ((SwipeDirection) -> Void)?
    @ViewBuilder let content: () -> Content

    public init(
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

@MainActor
struct CardView: View {

    let announcement: Announcement
    let shadowed: Bool
    let action: () -> Void

    init(
        announcement: Announcement,
        shadowed: Bool,
        action: @escaping () -> Void
    ) {
        self.announcement = announcement
        self.shadowed = shadowed
        self.action = action
    }

    var body: some View {
        HStack(alignment: .center, spacing: .zero) {
            if let url = announcement.content.imageUrl {
                AsyncMedia(url: url)
                    .frame(width: 40, height: 40)
                    .padding(.leading, Spacing.padding2)
            }
            VStack(alignment: .leading) {
                Text(announcement.content.title)
                    .typography(.caption1)
                    .foregroundColor(.semantic.muted)
                    .bold()
                Text(announcement.content.description)
                    .typography(.body2)
            }
            .padding(16)
            Spacer()
        }
        .frame(minHeight: 98)
        .background(Color.white)
        .cornerRadius(16)
        .padding(.horizontal, Spacing.padding2)
        .shadow(
            color: shadowed ? Color.black.opacity(0.12) : .clear,
            radius: 4,
            x: 0,
            y: 3
        )
        .onTapGesture {
            action()
        }
    }
}
