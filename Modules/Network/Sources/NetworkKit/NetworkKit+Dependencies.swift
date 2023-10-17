import Dependencies
import DIKit

public struct NetworkAdapterDependencyKey: DependencyKey {

    public static var liveValue: NetworkAdapterAPI = resolve(
        tag: DIKitContext.retail // TODO: Remove DIKit
    )

    public static var previewValue: NetworkAdapterAPI = NetworkAdapter(
        communicator: EphemeralNetworkCommunicator(session: .shared)
    )

    public static var testValue: NetworkAdapterAPI = NetworkAdapter(
        communicator: ReplayNetworkCommunicator([:])
    )
}


public struct RequestBuilderDependencyKey: DependencyKey {

    public static var liveValue: RequestBuilder = resolve(
        tag: DIKitContext.retail // TODO: Remove DIKit
    )

    public static var previewValue: RequestBuilder = RequestBuilder(
        config: Network.Config.retailConfig
    )

    public static var testValue: RequestBuilder = RequestBuilder(
        config: Network.Config.retailConfig
    )
}

extension DependencyValues {

    public var networkAdapter: NetworkAdapterAPI {
        get { self[NetworkAdapterDependencyKey.self] }
        set { self[NetworkAdapterDependencyKey.self] = newValue }
    }

    public var requestBuilder: RequestBuilder {
        get { self[RequestBuilderDependencyKey.self] }
        set { self[RequestBuilderDependencyKey.self] = newValue }
    }
}