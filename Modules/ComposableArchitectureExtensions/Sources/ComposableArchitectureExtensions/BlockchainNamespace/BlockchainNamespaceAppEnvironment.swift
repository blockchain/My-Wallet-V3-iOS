import BlockchainNamespace
import ComposableArchitecture
import CustomDump
import Foundation

public protocol BlockchainNamespaceObservationAction {
    static func observation(_ action: BlockchainNamespaceObservation) -> Self
}

public enum BlockchainNamespaceObservation: Equatable {
    case start, stop
    case event(Tag.Reference, context: Tag.Context = [:])
}

extension BlockchainNamespaceObservation {

    public static func on(_ event: Tag, context: Tag.Context = [:]) -> Self {
        on(event.key(), context: context)
    }

    public static func on(_ event: Tag.Reference, context: Tag.Context = [:]) -> Self {
        .event(event, context: context)
    }
}

public struct BlockchainNamespaceEvent: Equatable {

    public let ref: Tag.Reference
    public let context: Tag.Context

    public init(event ref: Tag.Reference, context: Tag.Context) {
        self.ref = ref
        self.context = context
    }
}

public struct BlockchainNamespaceReducer<State, Action>: ReducerProtocol where Action: BlockchainNamespaceObservationAction {

    private let app: AppProtocol
    private let events: [Tag.Event]
    private let keys: [Tag.Reference]

    public init(app: AppProtocol, events: [Tag.Event]) {
        self.app = app
        self.events = events
        self.keys = events.map { $0.key() }
    }

    public func reduce(
        into state: inout State,
        action: Action
    ) -> EffectTask<Action> {
        guard let observation = (/Action.observation).extract(from: action) else {
            return .none
        }
        switch observation {
        case .start:
            let observers = keys.map { event in
                app.on(event)
                    .eraseToEffect()
                    .map { Action.observation(.event($0.reference, context: $0.context)) }
                    .cancellable(id: event)
            }
            return .merge(observers)
        case .stop:
            return .merge(keys.map(EffectTask.cancel(id:)))
        case .event:
            return .none
        }
    }
}

extension AnyJSON: CustomDumpReflectable {

    public var customDumpMirror: Mirror {
        Mirror(reflecting: wrapped)
    }
}

extension Tag: CustomDumpReflectable {

    public var customDumpMirror: Mirror {
        Mirror(reflecting: id)
    }
}

extension Tag.Reference: CustomDumpReflectable {

    public var customDumpMirror: Mirror {
        Mirror(reflecting: string)
    }
}

extension Language: CustomDumpReflectable {

    public var customDumpMirror: Mirror {
        .init(self, children: ["id": id], displayStyle: .struct)
    }
}
