// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import PlatformKit
import ToolKit

extension AnalyticsEvents {

    enum KYC: AnalyticsEvent {
        case kycVerifyEmailButtonClick
        case kycCountrySelected
        case kycPersonalDetailSet(fieldName: String)
        case kycAddressDetailSet
        case kycVerifyIdStartButtonClick
        case kycVeriffInfoSubmitted
        case kycUnlockGoldClick
        case kycPhoneUpdateButtonClick
        case kycEmailUpdateButtonClick
        case kycEnterEmail
        case kycConfirmEmail
        case kycMoreInfoNeeded
        case kycWelcome
        case kycCountry
        case kycStates
        case kycProfile
        case kycAddress
        case kycEnterPhone
        case kycConfirmPhone
        case kycVerifyIdentity
        case kycResubmitDocuments
        case kycAccountStatus
        case kycInformationControllerViewModelNilError(presentingViewController: String)
        case kycUnverifiedStart
        case kycVerifiedStart
        case kycVerifiedComplete
        case kycTiersLocked
        case kycEmail

        var name: String {
            switch self {
            // KYC - send verification email button click
            case .kycVerifyEmailButtonClick:
                "kyc_verify_email_button_click"
            // KYC - country selected
            case .kycCountrySelected:
                "kyc_country_selected"
            // KYC - personal detail changed
            case .kycPersonalDetailSet:
                "kyc_personal_detail_set"
            // KYC - address changed
            case .kycAddressDetailSet:
                "kyc_address_detail_set"
            // KYC - verify identity start button click
            case .kycVerifyIdStartButtonClick:
                "kyc_verify_id_start_button_click"
            // KYC - info veriff info submitted
            case .kycVeriffInfoSubmitted:
                "kyc_veriff_info_submitted"
            // KYC - unlock tier 1 (silver) clicked
            case .kycUnlockGoldClick:
                "kyc_unlock_gold_click"
            // KYC - phone number update button click
            case .kycPhoneUpdateButtonClick:
                "kyc_phone_update_button_click"
            // KYC - email update button click
            case .kycEmailUpdateButtonClick:
                "kyc_email_update_button_click"
            case .kycEnterEmail:
                "kyc_enter_email"
            case .kycConfirmEmail:
                "kyc_confirm_email"
            case .kycMoreInfoNeeded:
                "kyc_more_info_needed"
            case .kycWelcome:
                "kyc_welcome"
            case .kycCountry:
                "kyc_country"
            case .kycStates:
                "kyc_states"
            case .kycProfile:
                "kyc_profile"
            case .kycAddress:
                "kyc_address"
            case .kycEnterPhone:
                "kyc_enter_phone"
            case .kycConfirmPhone:
                "kyc_confirm_phone"
            case .kycVerifyIdentity:
                "kyc_verify_identity"
            case .kycResubmitDocuments:
                "kyc_resubmit_documents"
            case .kycAccountStatus:
                "kyc_account_status"
            case .kycInformationControllerViewModelNilError:
                "kyc_information_controller_view_model_nil_error"
            case .kycUnverifiedStart:
                "kyc_unverified_start"
            case .kycVerifiedStart:
                "kyc_verified_start"
            case .kycVerifiedComplete:
                "kyc_verified_complete"
            case .kycTiersLocked:
                "kyc_tiers_locked"
            case .kycEmail:
                "kyc_email"
            }
        }

        var params: [String: String]? {
            switch self {
            case .kycInformationControllerViewModelNilError(let vc):
                ["presenting_view_controller": vc]
            default:
                nil
            }
        }
    }
}
