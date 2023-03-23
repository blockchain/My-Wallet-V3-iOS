// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureKYCDomain
import PlatformKit
import PlatformUIKit
import ToolKit

/// Router for handling the KYC verify email flow
public final class KYCDeepLinkRouter: DeepLinkRouting {

    private let kycSettings: KYCSettingsAPI
    private let kycRouter: KYCRouterAPI

    public init(
        kycSettings: KYCSettingsAPI = resolve(),
        kycRouter: KYCRouterAPI = resolve()
    ) {
        self.kycSettings = kycSettings
        self.kycRouter = kycRouter
    }

    public func routeIfNeeded() -> Bool {
        // Only route if the user actually tapped on the verify email link
        guard kycSettings.didTapOnKycDeepLink else {
            return false
        }
        kycSettings.didTapOnKycDeepLink = false

        // Only route if the user was completing kyc
        guard kycSettings.isCompletingKyc else {
            return false
        }

        guard let viewController = UIApplication.shared.firstKeyWindow?.rootViewController else {
            return false
        }
        kycRouter.start(tier: .verified, parentFlow: .onboarding, from: viewController)
        return true
    }
}
