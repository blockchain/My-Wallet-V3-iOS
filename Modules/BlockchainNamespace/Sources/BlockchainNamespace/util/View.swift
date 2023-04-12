#if canImport(SwiftUI)

import Extensions
import OptionalSubscripts
import SwiftUI

@propertyWrapper
public struct BlockchainApp: DynamicProperty {

    @EnvironmentObject<App.EnvironmentObject> var object
    @Environment(\.context) var context

    public init() {}

    public var wrappedValue: AppProtocol { object.environmentObject.app }
    public var projectedValue: BlockchainApp { self }

    public func post(
        event: Tag.Event,
        context: Tag.Context = [:],
        file: String = #fileID,
        line: Int = #line
    ) {
        object.post(event: event.key(to: self.context), context: self.context + context, file: file, line: line)
    }

    public func post(
        value: AnyHashable,
        of event: Tag.Event,
        file: String = #fileID,
        line: Int = #line
    ) {
        object.post(value: value, of: event.key(to: context), file: file, line: line)
    }

    public func post(
        error: some Error,
        context: Tag.Context = [:],
        file: String = #fileID,
        line: Int = #line
    ) {
        object.post(error: error, context: self.context + context, file: file, line: line)
    }

    public func id(_ event: Tag.Event) -> Tag.Reference {
        event.key(to: context)
    }

    public subscript(event: Tag.Event) -> Tag.Reference {
        event.key(to: context)
    }
}

extension App {

    public class EnvironmentObject: ObservableObject, AppProtocol {

        let app: AppProtocol

        public var language: Language { app.language }
        public var events: Session.Events { app.events }
        public var state: Session.State { app.state }
        public var clientObservers: Client.Observers { app.clientObservers }
        public var sessionObservers: Session.Observers { app.sessionObservers }
        public var remoteConfiguration: Session.RemoteConfiguration { app.remoteConfiguration }
        public var environmentObject: App.EnvironmentObject { self }
        public var deepLinks: App.DeepLink { app.deepLinks }
        public var local: Optional<Any>.Store { app.local }
        public var napis: NAPI.Store { app.napis }
        public var description: String { app.description }

        public init(_ app: AppProtocol) {
            self.app = app
        }

        public func register(
            napi root: I_blockchain_namespace_napi,
            domain: L,
            policy: L_blockchain_namespace_napi_napi_policy.JSON?,
            repository: @escaping (Tag.Reference) -> AnyPublisher<AnyJSON, Never>,
            in context: Tag.Context
        ) async throws {
            try await app.register(napi: root, domain: domain, policy: policy, repository: repository, in: context)
        }
    }
}

extension View {

    public func app(_ app: AppProtocol) -> some View {
        environmentObject(app.environmentObject)
    }

    public func context(_ context: Tag.Context) -> some View {
        environment(\.context, context)
    }
}

extension EnvironmentValues {

    public var context: Tag.Context {
        get { self[BlockchainAppContext.self] }
        set { self[BlockchainAppContext.self] += newValue }
    }
}

public struct BlockchainAppContext: EnvironmentKey {
    public static let defaultValue: Tag.Context = [:]
}

#endif
