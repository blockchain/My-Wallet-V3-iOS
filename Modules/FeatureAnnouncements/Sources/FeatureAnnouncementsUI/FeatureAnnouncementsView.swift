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
        if #available(iOS 15, *), count > 1 {
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
