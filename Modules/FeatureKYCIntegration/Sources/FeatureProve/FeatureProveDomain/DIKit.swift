// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit

extension DependencyContainer {

    // MARK: - FeatureProveDomain Module

    public static var featureProveDomain = module {

        // MARK: - Services

        factory { () -> MobileAuthInfoServiceAPI in
            MobileAuthInfoService(
                repository: DIKit.resolve()
            )
        }

        factory { () -> FlowKYCInfoServiceAPI in
            FlowKYCInfoService(
                repository: DIKit.resolve()
            )
        }

        factory { () -> PrefillInfoServiceAPI in
            PrefillInfoService(
                repository: DIKit.resolve()
            )
        }

        factory { () -> ConfirmInfoServiceAPI in
            ConfirmInfoService(
                repository: DIKit.resolve()
            )
        }

        factory { () -> PhoneVerificationServiceAPI in
            PhoneVerificationService(
                repository: DIKit.resolve()
            )
        }
    }
}
