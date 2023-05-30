// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import Combine
import DIKit
import FeatureProductsDomain

public class UserProductsRepository {

    private let app: AppProtocol
    private let service: ProductsServiceAPI

    public init(app: AppProtocol, service: ProductsServiceAPI = resolve()) {
        self.app = app
        self.service = service
    }

    public func register() async throws {

        var policy = L_blockchain_namespace_napi_napi_policy.JSON()

        policy.invalidate.on = [
            blockchain.user.event.did.update[],
            blockchain.ux.kyc.event.status.did.change[]
        ]

        try await app.register(
            napi: blockchain.api.nabu.gateway.user,
            domain: blockchain.api.nabu.gateway.user.products,
            policy: policy,
            repository: { [service] _ in
                service.streamProducts()
                    .tryMap { result -> AnyJSON in
                        var products = L_blockchain_api_nabu_gateway_user_products.JSON()
                        for product in try result.get() {
                            products.product[product.id.value].is.eligible = product.enabled
                            products.product[product.id.value].ineligible.reason = product.reasonNotEligible?.reason
                            products.product[product.id.value].ineligible.type = product.reasonNotEligible?.type
                            products.product[product.id.value].ineligible.message = product.reasonNotEligible?.message
                            products.product[product.id.value].ineligible.learn.more = product.reasonNotEligible?.learnMoreUrl
                        }
                        return products.toJSON()
                    }
                    .replaceError(with: .empty)
                    .eraseToAnyPublisher()
            }
        )
    }
}
