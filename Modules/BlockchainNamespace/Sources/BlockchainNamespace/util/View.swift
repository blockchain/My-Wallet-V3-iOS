#if canImport(SwiftUI)

import Extensions
import OptionalSubscripts
import SwiftUI

@propertyWrapper
public struct BlockchainApp: DynamicProperty {

    @Environment(\.app) var app
    @Environment(\.context) var context

    public init() {}

    public var wrappedValue: AppProtocol { app }
    public var projectedValue: BlockchainApp { self }

    public func post(
        event: Tag.Event,
        context: Tag.Context = [:],
        file: String = #fileID,
        line: Int = #line
    ) {
        app.post(event: event.key(to: self.context), context: self.context + context, file: file, line: line)
    }

    public func post(
        value: AnyHashable,
        of event: Tag.Event,
        file: String = #fileID,
        line: Int = #line
    ) {
        app.post(value: value, of: event.key(to: context), file: file, line: line)
    }

    public func post(
        error: some Error,
        context: Tag.Context = [:],
        file: String = #fileID,
        line: Int = #line
    ) {
        app.post(error: error, context: self.context + context, file: file, line: line)
    }

    public func id(_ event: Tag.Event) -> Tag.Reference {
        event.key(to: context)
    }

    public subscript(event: Tag.Event) -> Tag.Reference {
        event.key(to: context)
    }
}

extension View {

    public func app(_ app: AppProtocol) -> some View {
        environment(\.app, app)
    }

    public func context(_ context: Tag.Context) -> some View {
        environment(\.context, context)
    }

    public func context(_ key: Tag.Context.Key, _ value: Tag.Context.Value) -> some View {
        environment(\.context, [key: value])
    }
}

extension EnvironmentValues {

    public var app: AppProtocol {
        get { self[BlockchainAppEnvironmentKey.self] }
        set { self[BlockchainAppEnvironmentKey.self] = newValue }
    }

    public var context: Tag.Context {
        get { self[BlockchainAppContext.self] }
        set { self[BlockchainAppContext.self] += newValue }
    }
}

public struct BlockchainAppContext: EnvironmentKey {
    public static let defaultValue: Tag.Context = [:]
}

public struct BlockchainAppEnvironmentKey: EnvironmentKey {
    public static let defaultValue: AppProtocol = runningApp
}

#endif
