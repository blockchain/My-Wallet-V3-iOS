import Blockchain
import Combine
import ComposableArchitecture
import Errors
import FeatureAnnouncementsDomain
import Foundation

public struct Announcements: Reducer {

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
        case none
    }

    // MARK: - Properties

    private let app: AppProtocol
    private let services: [AnnouncementsServiceAPI]
    private let mainQueue: AnySchedulerOf<DispatchQueue>
    private let mode: Announcement.AppMode

    // MARK: - Setup

    public init (
        app: AppProtocol,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        mode: Announcement.AppMode,
        services: [AnnouncementsServiceAPI]
    ) {
        self.app = app
        self.mainQueue = mainQueue
        self.services = services
        self.mode = mode
    }

    public func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .initialize:
            guard state.status == .idle, !state.initialized else {
                return .none
            }
            state.initialized = true
            return .merge(
                Effect.send(.fetchAnnouncements(false)),
                Effect.run { send in
                    try await app
                        .on(blockchain.ux.home.event.did.pull.to.refresh)
                        .debounce(for: .seconds(1), scheduler: mainQueue)
                        .await()
                    await send(Action.fetchAnnouncements(true))
                }
            )
        case .fetchAnnouncements(let force):
            guard state.status != .loading else {
                return .none
            }
            state.status = .loading
            return .run { send in
                let announcements = try await withThrowingTaskGroup(of: [Announcement].self) { group in
                    services.forEach { service in
                        group.addTask {
                            await (try? service.fetchMessages(for: [mode, .universal], force: force)) ?? []
                        }
                    }

                    var collected = [Announcement]()
                    for try await value in group {
                        collected.append(contentsOf: value)
                    }
                    return collected
                }
                await send(.onAnnouncementsFetched(announcements))
            }
        case .open(let announcement):
            return .run { [services, announcement] send in
                try await Publishers.MergeMany(services.map { service in service.handle(announcement) })
                    .collect()
                    .await()
                await send(Action.dismiss(announcement, .open))
            }
        case .read(let announcement):
            guard let announcement, !announcement.read else {
                return .none
            }
            return .publisher {
                Publishers.MergeMany(services.map { service in service.setRead(announcement: announcement) })
                    .collect()
                    .catch { _ in Just([()]) }
                    .map { _ in Announcements.Action.none }
                    .receive(on: mainQueue)
            }
        case .dismiss(let announcement, let action):
            return .merge(
                Effect.publisher {
                    Publishers.MergeMany(services.map { service in service.setDismissed(announcement, with: action) })
                        .collect()
                        .catch { _ in Just([()]) }
                        .map { _ in Announcements.Action.none }
                        .receive(on: mainQueue)
                },
                Effect.send(.read(state.announcements.last)),
                Effect.send(.delete(announcement))
            )
        case .delete(let announcement):
            state.announcements = state.announcements.filter { $0 != announcement }
            state.showCompletion = state.announcements.isEmpty
            return .none
        case .onAnnouncementsFetched(let announcements):
            state.status = .loaded
            state.announcements = announcements.sorted().reversed()
            return Effect.send(.read(announcements.last))
        case .hideCompletion:
            state.showCompletion = false
            return .none
        case .none:
            return .none
        }
    }
}
