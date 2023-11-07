// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public enum DeepLinkRoute: CaseIterable {
    case kyc
    case kycVerifyEmail
    case kycDocumentResubmission
    case openBankingLink
    case openBankingApprove
}

extension DeepLinkRoute {

    public static func route(
        from url: String,
        supportedRoutes: [DeepLinkRoute] = DeepLinkRoute.allCases
    ) -> DeepLinkRoute? {
        guard let url = URL(string: url) else {
            return nil
        }

        let fragment = url.fragment.flatMap { fragment in
            URL(string: fragment)
        }

        let path: String
        let parameters: [String: String]

        if let fragment {
            path = fragment.path
            parameters = url.queryArgs.merging(fragment.queryArgs, uniquingKeysWith: { $1 })
        } else {
            path = url.path
            parameters = url.queryArgs
        }

        return DeepLinkRoute.route(
            path: path,
            parameters: parameters,
            supportedRoutes: supportedRoutes
        )
    }

    private static func route(
        path: String,
        parameters: [String: String]?,
        supportedRoutes: [DeepLinkRoute] = DeepLinkRoute.allCases
    ) -> DeepLinkRoute? {
        supportedRoutes.first { route -> Bool in
            guard path.hasSuffix(route.supportedPath) else {
                return false
            }
            guard let key = route.requiredKeyParam,
                  let value = route.requiredValueParam,
                  let routeParameters = parameters
            else {
                return true
            }
            guard let optionalKey = route.optionalKeyParameter,
                  let value = routeParameters[optionalKey],
                  FlowContext(rawValue: value) != nil
            else {
                return routeParameters[key] == value
            }
            return false
        }
    }

    private var supportedPath: String {
        switch self {
        case .kycVerifyEmail,
             .kycDocumentResubmission:
            "login"
        case .kyc:
            "kyc"
        case .openBankingLink:
            "ob-bank-link"
        case .openBankingApprove:
            "ob-bank-approval"
        }
    }

    private var requiredKeyParam: String? {
        switch self {
        case .kyc,
             .kycVerifyEmail,
             .kycDocumentResubmission:
            "deep_link_path"
        case .openBankingLink, .openBankingApprove:
            nil
        }
    }

    private var requiredValueParam: String? {
        switch self {
        case .kycVerifyEmail:
            "email_verified"
        case .kycDocumentResubmission:
            "verification"
        case .kyc:
            "kyc"
        case .openBankingLink, .openBankingApprove:
            nil
        }
    }

    private var optionalKeyParameter: String? {
        switch self {
        case .kycVerifyEmail:
            "context"
        case .kyc,
             .kycDocumentResubmission,
             .openBankingLink,
             .openBankingApprove:
            nil
        }
    }
}
