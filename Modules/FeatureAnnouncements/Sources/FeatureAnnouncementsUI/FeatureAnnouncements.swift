import BlockchainNamespace
import Combine
import ComposableArchitecture
import Errors
import FeatureAnnouncementsDomain
import Foundation

public struct FeatureAnnouncements: ReducerProtocol {

    public enum LoadingStatus: Equatable {
        case idle
        case loading
        case loaded
    }

    // MARK: - Types
    public struct State: Equatable {
        public var status: LoadingStatus = .idle
        public var announcements: [Announcement] = []
        public var showCompletion: Bool = false
        public var initialized: Bool = false

        public init() {}
    }

    public enum Action: Equatable {
        case initialize
        case fetchAnnouncements(Bool)
        case open(Announcement)
        case read(Announcement?)
        case dismiss(Announcement, Announcement.Action)
        case delete(Announcement)
        case onAnnouncementsFetched([Announcement])
        case hideCompletion
    }

    // MARK: - Properties
    private let app: AppProtocol
    private let service: AnnouncementsServiceAPI
    private let mainQueue: AnySchedulerOf<DispatchQueue>
    private let mode: Announcement.AppMode

    // MARK: - Setup
    public init (
        app: AppProtocol,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        mode: Announcement.AppMode,
        service: AnnouncementsServiceAPI
    ) {
        self.app = app
        self.mainQueue = mainQueue
        self.service = service
        self.mode = mode
    }

    public func reduce(into state: inout State, action: Action) -> ComposableArchitecture.Effect<Action, Never> {
        switch action {
        case .initialize:
            guard state.status == .idle, !state.initialized else {
                return .none
            }
            state.initialized = true
            return app
                .on(blockchain.ux.home.event.did.pull.to.refresh)
                .map { _ in Action.fetchAnnouncements(true) }
                .debounce(for: .seconds(1), scheduler: mainQueue)
                .receive(on: mainQueue)
                .eraseToEffect()
        case .fetchAnnouncements(let force):
            guard state.status != .loading else {
                return .none
            }
            state.status = .loading
            return .run { send in
                let announcements = await (try? service.fetchMessages(for: [mode, .universal], force: force)) ?? []
                await send(.onAnnouncementsFetched(announcements))
            }
        case .open(let announcement):
            return .merge(
                service
                    .setTapped(announcement: announcement)
                    .receive(on: mainQueue)
                    .eraseToEffect()
                    .fireAndForget(),
                .fireAndForget {
                    app.post(
                        event: blockchain.ux.dashboard.announcements.open.paragraph.button.primary.tap.then.launch.url,
                        context: [
                            blockchain.ui.type.action.then.launch.url: announcement.content.actionUrl
                        ]
                    )
                },
                Effect(value: .dismiss(announcement, .open))
            )
        case .read(let announcement):
            guard let announcement, !announcement.read else {
                return .none
            }
            return service
                .setRead(announcement: announcement)
                .receive(on: mainQueue)
                .eraseToEffect()
                .fireAndForget()
        case .dismiss(let announcement, let action):
            return .merge(
                service
                    .setDismissed(announcement, with: action)
                    .receive(on: mainQueue)
                    .eraseToEffect()
                    .fireAndForget(),
                Effect(value: .read(state.announcements.last)),
                Effect(value: .delete(announcement))
            )
        case .delete(let announcement):
            state.announcements = state.announcements.filter { $0 != announcement }
            state.showCompletion = state.announcements.isEmpty
            return .none
        case .onAnnouncementsFetched(let announcements):
            state.status = .loaded
            state.announcements = announcements.sorted().reversed()
            return Effect(value: .read(announcements.last))
        case .hideCompletion:
            state.showCompletion = false
            return .none
        }
    }
}
