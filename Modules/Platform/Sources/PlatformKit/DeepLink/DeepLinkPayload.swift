// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct DeepLinkPayload {
    public let route: DeepLinkRoute
    public let params: [String: String]
}

extension DeepLinkPayload {
    public static func create(from url: String, supportedRoutes: [DeepLinkRoute]) -> DeepLinkPayload? {
        guard let route = DeepLinkRoute.route(from: url, supportedRoutes: supportedRoutes) else { return nil }
        return DeepLinkPayload(route: route, params: extractParams(from: url))
    }

    private static func extractParams(from url: String) -> [String: String] {
        guard let url = URL(string: url) else { return [:] }

        let fragment = url.fragment.flatMap(URL.init(string:))

        let parameters: [String: String] = if let fragment {
            url.queryArgs.merging(fragment.queryArgs, uniquingKeysWith: { $1 })
        } else {
            url.queryArgs
        }

        return parameters
    }
}
