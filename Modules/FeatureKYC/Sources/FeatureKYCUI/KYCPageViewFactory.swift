// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import FeatureKYCDomain
import PlatformKit
import ToolKit

/// Factory for constructing a KYCBaseViewController
class KYCPageViewFactory {
    private let analyticsRecorder: AnalyticsEventRecorderAPI

    init(analyticsRecorder: AnalyticsEventRecorderAPI = resolve()) {
        self.analyticsRecorder = analyticsRecorder
    }

    // swiftlint:disable:next cyclomatic_complexity
    func createFrom(
        pageType: KYCPageType,
        in coordinator: KYCRouter,
        payload: KYCPagePayload? = nil
    ) -> KYCBaseViewController {
        switch pageType {
        case .enterEmail:
            analyticsRecorder.record(event: AnalyticsEvents.KYC.kycEnterEmail)
            return KYCEnterEmailController.make(with: coordinator)
        case .confirmEmail:
            analyticsRecorder.record(event: AnalyticsEvents.KYC.kycConfirmEmail)
            let confirmEmailController = KYCConfirmEmailController.make(with: coordinator)
            if let payload, case .emailPendingVerification(let email) = payload {
                confirmEmailController.email = email
            }
            return confirmEmailController
        case .finish:
            return KYCApplicationCompleteController.make(with: coordinator)
        case .welcome:
            analyticsRecorder.record(event: AnalyticsEvents.KYC.kycWelcome)
            return KYCWelcomeController.make(with: coordinator)
        case .country:
            analyticsRecorder.record(event: AnalyticsEvents.KYC.kycCountry)
            return KYCCountrySelectionController.make(with: coordinator)
        case .states:
            analyticsRecorder.record(event: AnalyticsEvents.KYC.kycStates)
            let stateController = KYCStateSelectionController.make(with: coordinator)
            if let payload, case .countrySelected(let country) = payload {
                stateController.country = country
            }
            return stateController
        case .profile:
            analyticsRecorder.record(event: AnalyticsEvents.KYC.kycProfile)
            return KYCPersonalDetailsController.make(with: coordinator)
        case .profileNew:
            analyticsRecorder.record(event: AnalyticsEvents.KYC.kycProfile)
            return KYCPersonalDetailsControllerNew.make(with: coordinator)
        case .accountUsageForm:
            return KYCAccountUsageController.make(with: coordinator)
        case .address:
            analyticsRecorder.record(event: AnalyticsEvents.KYC.kycAddress)
            return KYCAddressController.make(with: coordinator)
        case .enterPhone:
            analyticsRecorder.record(event: AnalyticsEvents.KYC.kycEnterPhone)
            return KYCEnterPhoneNumberController.make(with: coordinator)
        case .confirmPhone:
            analyticsRecorder.record(event: AnalyticsEvents.KYC.kycConfirmPhone)
            let confirmPhoneNumberController = KYCConfirmPhoneNumberController.make(with: coordinator)
            if let payload, case .phoneNumberUpdated(let number) = payload {
                confirmPhoneNumberController.phoneNumber = number
            }
            return confirmPhoneNumberController
        case .verifyIdentity:
            analyticsRecorder.record(event: AnalyticsEvents.KYC.kycVerifyIdentity)
            return KYCVerifyIdentityController.make(with: coordinator)
        case .resubmitIdentity:
            analyticsRecorder.record(event: AnalyticsEvents.KYC.kycResubmitDocuments)
            return KYCResubmitIdentityController.make(with: coordinator)
        case .accountStatus:
            analyticsRecorder.record(event: AnalyticsEvents.KYC.kycAccountStatus)
            let controller = KYCInformationController.make(with: coordinator)
            switch payload {
            case .accountStatus(status: let status, isReceivingAirdrop: let airdrop):
                let model = KYCInformationViewModel.create(for: status)
                let config = KYCInformationViewConfig.create(for: status, isReceivingAirdrop: airdrop)
                controller.viewConfig = config
                controller.viewModel = model
            default:
                break
            }
            return controller
        case .applicationComplete:
            return KYCApplicationCompleteController.make(with: coordinator)
        }
    }
}
