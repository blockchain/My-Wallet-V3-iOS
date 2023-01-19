// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import Combine
import DIKit
import FeatureProductsDomain

private let productsId = blockchain.api.nabu.gateway.products

public class UserProductsObserver: Client.Observer {

    private let app: AppProtocol
    private let service: ProductsServiceAPI

    private var subscription: AnyCancellable?, task: Task<Void, Never>?

    public init(app: AppProtocol, service: ProductsServiceAPI = resolve()) {
        self.app = app
        self.service = service
    }

    public func start() {
        subscription = app.on(blockchain.user.event.did.update, blockchain.ux.kyc.event.status.did.change)
            .flatMap { [service] _ in service.streamProducts() }
            .sink(to: My.update, on: self)
    }

    public func stop() {
        subscription = nil
        task = nil
    }

    func update(_ result: Result<[ProductValue], ProductsServiceError>) {
        task = Task {
            do {
                var batch = App.BatchUpdates()
                let products = try result.get()
                for product in products {
                    batch.append((productsId[product.id.value].is.eligible, product.enabled))
                    batch.append((productsId[product.id.value].ineligible.reason, product.reasonNotEligible?.reason))
                    batch.append((productsId[product.id.value].ineligible.type, product.reasonNotEligible?.type))
                    batch.append((productsId[product.id.value].ineligible.message, product.reasonNotEligible?.message))
                    batch.append(
                        (
                            blockchain.api.nabu.gateway.products[product.id.value].ineligible.learn.more,
                            product.reasonNotEligible?.learnMoreUrl
                        )
                    )
                }
                try await app.batch(updates: batch)
            } catch {
                app.post(error: error)
            }
        }
    }
}
