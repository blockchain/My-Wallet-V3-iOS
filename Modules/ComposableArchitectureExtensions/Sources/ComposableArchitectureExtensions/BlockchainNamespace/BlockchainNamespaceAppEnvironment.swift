import BlockchainNamespace
import ComposableArchitecture
import CustomDump
import Foundation

public protocol BlockchainNamespaceAppEnvironment {
    var app: AppProtocol { get }
}

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

extension Reducer where Action: BlockchainNamespaceObservationAction, Environment: BlockchainNamespaceAppEnvironment {

    public func on(_ first: Tag.Event, _ rest: Tag.Event...) -> Self {
        on([first] + rest)
    }

    public func on(_ events: some Collection<Tag.Event>) -> Self {
        Reducer { _, action, environment in
            if let observation = (/Action.observation).extract(from: action) {
                let keys = events.map { $0.key() }
                switch observation {
                case .start:
                    let observers = keys.map { event in
                        environment.app.on(event)
                            .eraseToEffect()
                            .map { Action.observation(.event($0.reference, context: $0.context)) }
                            .cancellable(id: event)
                    }
                    return .merge(observers)
                case .stop:
                    return .cancel(ids: keys.map(AnyHashable.init))
                case .event:
                    break
                }
            }
            return .none
        }
        .combined(with: self)
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
