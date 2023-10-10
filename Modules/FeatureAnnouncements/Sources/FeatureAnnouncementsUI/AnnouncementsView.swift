import Blockchain
import BlockchainUI
import ComposableArchitecture
import FeatureAnnouncementsDomain
import Localization
import SwiftUI

@MainActor
public struct AnnouncementsView: View {
    let store: StoreOf<Announcements>

    public init(store: StoreOf<Announcements>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            if !viewStore.announcements.isEmpty || viewStore.showCompletion {
                contentView
            } else if !viewStore.initialized {
                ProgressView()
                    .onAppear {
                        viewStore.send(.initialize)
                    }
            } else {
                EmptyView()
            }
        }
    }

    @ViewBuilder func completionView(_ completion: @escaping () -> Void) -> some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            if viewStore.state.showCompletion {
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
        if count > 1 {
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
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack(alignment: .topTrailing) {
                ZStack(alignment: .center) {
                    completionView {
                        viewStore.send(.hideCompletion)
                    }
                    ForEach(viewStore.state.announcements, id: \.id) { announcement in
                        SwipableView(onSwiped: { _ in
                            viewStore.send(.dismiss(announcement, .swipe))
                        }) {
                            CardView(
                                announcement: announcement,
                                shadowed: announcement == viewStore.state.announcements.last
                                || announcement == viewStore.state.announcements.first
                            ) {
                                viewStore.send(.open(announcement))
                            }
                        }
                        .scaleEffect(announcement != viewStore.state.announcements.last ? CGSize(width: 0.9, height: 0.9) : CGSize(width: 1, height: 1), anchor: .top)
                        .offset(x: 0, y: announcement != viewStore.state.announcements.last ? -7 : 0)
                    }
                }
                badge(count: viewStore.state.announcements.count)
            }
            .task {
                viewStore.send(.fetchAnnouncements(false))
            }
        }
    }
}
