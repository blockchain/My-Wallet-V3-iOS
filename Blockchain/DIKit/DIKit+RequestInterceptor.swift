// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import NetworkKit

// MARK: - Blockchain Module

extension DependencyContainer {

    static var blockchainNetworkRequestInterceptor = module {
        single { interceptor() }
    }
}

// [
//    {
//        "pattern": {
//            "method": "PUT",
//            "url": "/users/current/address/initial$"
//        },
//        "emit": "blockchain.app.fraud.sardine.submit"
//    },
//    {
//        "pattern": {
//            "method": "PUT",
//            "url": "/users/current/address$"
//        },
//        "emit": "blockchain.app.fraud.sardine.submit"
//    }
// ]

struct Intercept: Decodable {
    let pattern: Pattern
    let emit: Tag.Reference
    let wait: Wait?
}

extension Intercept {

    struct Pattern: Decodable {
        let method: String
        let url: String
    }

    struct Wait: Decodable {
        let until: [Tag.Reference]
    }
}

private func interceptor(app: AppProtocol = resolve()) -> RequestInterceptor {
    RequestInterceptor { request in
        app.publisher(for: blockchain.app.configuration.outbound.request.interceptor, as: [Intercept?].self)
            .replaceError(with: [])
            .map { intercepts -> [Intercept] in intercepts.compacted().array }
            .map { intercepts -> AnyPublisher<NetworkRequest, Never> in
                do {
                    if let intercept = try intercepts.first(
                        where: { intercept in
                            let regex = try NSRegularExpression(pattern: intercept.pattern.url)
                            return intercept.pattern.method.lowercased() == request.method.string.lowercased() && regex.matches(request.endpoint.absoluteString)
                        }
                    ) {
                        let publisher: AnyPublisher<NetworkRequest, Never>
                        if let wait = intercept.wait {
                            publisher = app.on(wait.until).replaceOutput(with: request).first().eraseToAnyPublisher()
                        } else {
                            publisher = .just(request)
                        }
                        return publisher
                            .handleEvents(receiveSubscription: { [app] _ in app.post(event: intercept.emit) })
                            .eraseToAnyPublisher()
                    } else {
                        return .just(request)
                    }
                } catch {
                    return .just(request)
                }
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
}
