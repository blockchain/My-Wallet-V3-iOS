//
//  DeepLinkRoute.swift
//  Blockchain
//
//  Created by Chris Arriola on 10/29/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

enum DeepLinkRoute: String, CaseIterable {
    case xlmAirdop
}

extension DeepLinkRoute {

    static func route(from url: URL) -> DeepLinkRoute? {
        guard let lastPathWithProperties = url.absoluteString.components(separatedBy: "/").last else {
            return nil
        }

        let pathToParametersComponents = lastPathWithProperties.components(separatedBy: "?")
        guard let path = pathToParametersComponents.first else {
            return nil
        }

        // Get parameters
        var parameters = [String: String]()
        let parameterPairs = pathToParametersComponents.last?.components(separatedBy: "&")
        parameterPairs?.forEach { pair in
            let paramComponents = pair.components(separatedBy: "=")
            guard let key = paramComponents.first,
                let value = paramComponents.last else {
                return
            }
            parameters[key] = value
        }

        return DeepLinkRoute.route(path: path, parameters: parameters)
    }

    private static func route(path: String, parameters: [String: String]?) -> DeepLinkRoute? {
        return DeepLinkRoute.allCases.first { route -> Bool in
            if route.supportedPath == path {
                if let key = route.requiredKeyParam,
                    let value = route.requiredValueParam,
                    let routeParameters = parameters {
                    return routeParameters[key] == value
                }
            }
            return false
        }
    }

    private var supportedPath: String {
        switch self {
        case .xlmAirdop:
            return "referral"
        }
    }

    private var requiredKeyParam: String? {
        switch self {
        case .xlmAirdop:
            return "campaign"
        }
    }

    private var requiredValueParam: String? {
        switch self {
        case .xlmAirdop:
            return "sunriver"
        }
    }
}
