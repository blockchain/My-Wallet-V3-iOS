import BlockchainNamespace
import Dependencies

extension App: DependencyKey {
    public static var liveValue: AppProtocol = runningApp ?? App.preview
    public static var previewValue: AppProtocol = runningApp ?? App.preview
    #if DEBUG
    public static var testValue: AppProtocol = runningApp is App.Test ? runningApp : App.test
    #endif
}

extension DependencyValues {

    public var app: AppProtocol {
        get { self[App.self] }
        set { self[App.self] = newValue }
    }
}
