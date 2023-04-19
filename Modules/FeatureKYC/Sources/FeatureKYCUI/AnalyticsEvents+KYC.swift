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
                return "kyc_verify_email_button_click"
            // KYC - country selected
            case .kycCountrySelected:
                return "kyc_country_selected"
            // KYC - personal detail changed
            case .kycPersonalDetailSet:
                return "kyc_personal_detail_set"
            // KYC - address changed
            case .kycAddressDetailSet:
                return "kyc_address_detail_set"
            // KYC - verify identity start button click
            case .kycVerifyIdStartButtonClick:
                return "kyc_verify_id_start_button_click"
            // KYC - info veriff info submitted
            case .kycVeriffInfoSubmitted:
                return "kyc_veriff_info_submitted"
            // KYC - unlock tier 1 (silver) clicked
            case .kycUnlockGoldClick:
                return "kyc_unlock_gold_click"
            // KYC - phone number update button click
            case .kycPhoneUpdateButtonClick:
                return "kyc_phone_update_button_click"
            // KYC - email update button click
            case .kycEmailUpdateButtonClick:
                return "kyc_email_update_button_click"
            case .kycEnterEmail:
                return "kyc_enter_email"
            case .kycConfirmEmail:
                return "kyc_confirm_email"
            case .kycMoreInfoNeeded:
                return "kyc_more_info_needed"
            case .kycWelcome:
                return "kyc_welcome"
            case .kycCountry:
                return "kyc_country"
            case .kycStates:
                return "kyc_states"
            case .kycProfile:
                return "kyc_profile"
            case .kycAddress:
                return "kyc_address"
            case .kycEnterPhone:
                return "kyc_enter_phone"
            case .kycConfirmPhone:
                return "kyc_confirm_phone"
            case .kycVerifyIdentity:
                return "kyc_verify_identity"
            case .kycResubmitDocuments:
                return "kyc_resubmit_documents"
            case .kycAccountStatus:
                return "kyc_account_status"
            case .kycInformationControllerViewModelNilError:
                return "kyc_information_controller_view_model_nil_error"
            case .kycUnverifiedStart:
                return "kyc_unverified_start"
            case .kycVerifiedStart:
                return "kyc_verified_start"
            case .kycVerifiedComplete:
                return "kyc_verified_complete"
            case .kycTiersLocked:
                return "kyc_tiers_locked"
            case .kycEmail:
                return "kyc_email"
            }
        }

        var params: [String: String]? {
            switch self {
            case .kycInformationControllerViewModelNilError(let vc):
                return ["presenting_view_controller": vc]
            default:
                return nil
            }
        }
    }
}
