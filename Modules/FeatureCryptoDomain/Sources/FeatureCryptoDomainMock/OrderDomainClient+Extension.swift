// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#if DEBUG
import Combine
@testable import FeatureCryptoDomainData
import Foundation
import NetworkKit

private class OrderDomainClientMock: OrderDomainClientAPI {

    let success: Bool

    init(success: Bool) {
        self.success = success
    }

    func postOrder(
        payload: PostOrderRequest
    ) -> AnyPublisher<PostOrderResponse, Errors.NabuNetworkError> {
        if success {
            let response = PostOrderResponse(isFree: payload.isFree, redirectUrl: nil, order: nil)
            return .just(response)
        } else {
            return .failure(.unknown)
        }
    }
}

extension OrderDomainClient {

    static var mock: OrderDomainClientAPI { OrderDomainClientMock(success: true) }

    public static func test(
        _ requests: [URLRequest: Data] = [:]
    ) -> (
        client: OrderDomainClient,
        communicator: ReplayNetworkCommunicator
    ) {
        let communicator = ReplayNetworkCommunicator(requests, in: Bundle.module)
        return (
            OrderDomainClient(
                networkAdapter: NetworkAdapter(
                    communicator: communicator
                ),
                requestBuilder: RequestBuilder(
                    config: Network.Config(
                        scheme: "https",
                        host: "api.staging.blockchain.info",
                        components: ["nabu-gateway"]
                    ),
                    headers: ["Authorization": "Bearer Token"]
                )
            ),
            communicator
        )
    }
}
#endif
