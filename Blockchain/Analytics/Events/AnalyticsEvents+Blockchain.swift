// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import MoneyKit
import PlatformKit

/// Analytics events classified by flow as described in the following Google Sheet:
/// https://docs.google.com/spreadsheets/d/1oJCRld_KrabJ9WyDKgMEnYYn5w79qUEhfOxnB6XQs9Q/edit?ts=5d6fb6a6#gid=0
/// To add an event please follow the the steps:
/// 1. Add the event under the relevant flow. If the flow does not exist, create a new one.
/// 2. Verify the validation test passes
/// 3. Add parameters if needed
/// 4. Copy the geenrated scripts here
/// 5. Implement the event using `AnalyticsEventRecorderAPI`
extension AnalyticsEvents {

    private enum Parameter {
        static let asset = "asset"
        static let currency = "currency"
    }

    // MARK: - Exchange

    enum Exchange: AnalyticsEvent {
        case exchangeConnectNowTapped
        case exchangeLearnMoreTapped
        case exchangeAnnouncementTapped

        var name: String {
            switch self {
            // User taps on "Connect Now" in the Exchange splash screen
            case .exchangeConnectNowTapped:
                return "exchange_connect_now_tapped"
            // User taps on "Learn More" in the Exchange splash screen
            case .exchangeLearnMoreTapped:
                return "exchange_learn_more_tapped"
            // Users taps on the CTA in the Exchange announcement
            case .exchangeAnnouncementTapped:
                return "exchange_announcement_tapped"
            }
        }
    }

    // MARK: - Login / Signup

    enum Onboarding: AnalyticsEvent {
        case walletCreation
        case walletCreationError
        case walletManualLogin
        case walletAutoPairingError
        case walletAutoPairing
        case walletDashboard
        case loginSecondPasswordViewed

        var name: String {
            switch self {
            // User creates Wallet
            case .walletCreation:
                return "wallet_creation"
            // Error is received while creating a wallet
            case .walletCreationError:
                return "wallet_creation_error"
            // User logs in manually to the Wallet
            case .walletManualLogin:
                return "wallet_manual_login"
            // User receives an error during scan (auto pairing)
            case .walletAutoPairingError:
                return "wallet_auto_pairing_error"
            // User logs in automatically to the Wallet
            case .walletAutoPairing:
                return "wallet_auto_pairing"
            // User sees the dashboard
            case .walletDashboard:
                return "wallet_dashboard"
            // User sees second password
            case .loginSecondPasswordViewed:
                return "login_second_password_viewed"
            }
        }
    }

    // MARK: - Wallet Intro Flow

    enum WalletIntro: AnalyticsEvent {
        case walletIntroOffered
        case walletIntroPortfolioViewed
        case walletIntroSendViewed
        case walletIntroRequestViewed
        case walletIntroSwapViewed
        case walletIntroBuysellViewed

        var name: String {
            switch self {
            // Intro - User shown card to begin Wallet Intro
            case .walletIntroOffered:
                return "wallet_intro_offered"
            // Intro - User views "View your portfolio" card
            case .walletIntroPortfolioViewed:
                return "wallet_intro_portfolio_viewed"
            // Intro - User views "Send" card
            case .walletIntroSendViewed:
                return "wallet_intro_send_viewed"
            // Intro - User views "Request" card
            case .walletIntroRequestViewed:
                return "wallet_intro_request_viewed"
            // Intro - User views "Swap" card
            case .walletIntroSwapViewed:
                return "wallet_intro_swap_viewed"
            // Intro - User views "Buy and Sell" card
            case .walletIntroBuysellViewed:
                return "wallet_intro_buysell_viewed"
            }
        }

        var params: [String: String]? {
            nil
        }
    }

    // MARK: - Bitpay

    enum Bitpay: AnalyticsEvent {
        case bitpayPaymentSuccess
        case bitpayPaymentFailure(error: Error?)
        case bitpayPaymentExpired
        case bitpayUrlScanned(asset: CryptoCurrency)
        case bitpayUrlPasted(asset: CryptoCurrency)
        case bitpayUrlDeeplink(asset: CryptoCurrency)

        var name: String {
            switch self {
            // User successfully pays a Bitpay payment request
            case .bitpayPaymentSuccess:
                return "bitpay_payment_success"
            // User fails to pay a Bitpay payment request
            case .bitpayPaymentFailure:
                return "bitpay_payment_failure"
            // User's payment request expired
            case .bitpayPaymentExpired:
                return "bitpay_payment_expired"
            // User scans a Bitpay QR code
            case .bitpayUrlScanned:
                return "bitpay_url_scanned"
            // User pastes a bitpay URL in the address field
            case .bitpayUrlPasted:
                return "bitpay_url_pasted"
            // User deep links into the app after tapping a Bitpay URL
            case .bitpayUrlDeeplink:
                return "bitpay_url_deeplink"
            }
        }

        var params: [String: String]? {
            switch self {
            case .bitpayUrlDeeplink(asset: let asset),
                 .bitpayUrlScanned(asset: let asset),
                 .bitpayUrlPasted(asset: let asset):
                return ["currency": asset.code]
            case .bitpayPaymentExpired,
                 .bitpayPaymentSuccess:
                return nil
            case .bitpayPaymentFailure(error: let error):
                guard let error else { return nil }
                return ["error": String(describing: error)]
            }
        }
    }

    // MARK: - Send flow

    enum Send: AnalyticsEvent {
        case sendTabItemClick
        case sendFormConfirmClick(asset: CryptoCurrency)
        case sendFormConfirmSuccess(asset: CryptoCurrency)
        case sendFormConfirmFailure(asset: CryptoCurrency)
        case sendFormShowErrorAlert(asset: CryptoCurrency)
        case sendFormErrorAppear(asset: CryptoCurrency)
        case sendFormErrorClick(asset: CryptoCurrency)
        case sendFormUseBalanceClick(asset: CryptoCurrency)
        case sendFormExchangeButtonClick(asset: CryptoCurrency)
        case sendFormQrButtonClick(asset: CryptoCurrency)
        case sendSummaryConfirmClick(asset: CryptoCurrency)
        case sendSummaryConfirmSuccess(asset: CryptoCurrency)
        case sendSummaryConfirmFailure(asset: CryptoCurrency)
        case sendBitpayPaymentFailure(asset: CryptoCurrency)
        case sendBitpayPaymentSuccess(asset: CryptoCurrency)

        var name: String {
            switch self {
            // Send - tab item click
            case .sendTabItemClick:
                return "send_tab_item_click"
            // Send - form send click
            case .sendFormConfirmClick:
                return "send_form_confirm_click"
            // Send - form send success
            case .sendFormConfirmSuccess:
                return "send_form_confirm_success"
            // Send - form send failure
            case .sendFormConfirmFailure:
                return "send_form_confirm_failure"
            // Send - form show error alert
            case .sendFormShowErrorAlert:
                return "send_form_show_error_alert"
            // Send - form send error appears (⚠️)
            case .sendFormErrorAppear:
                return "send_form_error_appear"
            // Send - form send error click (⚠️)
            case .sendFormErrorClick:
                return "send_form_error_click"
            // Send - use spendable balance click
            case .sendFormUseBalanceClick:
                return "send_form_use_balance_click"
            // Send - Exchange button click
            case .sendFormExchangeButtonClick:
                return "send_form_exchange_button_click"
            // Send - QR button click
            case .sendFormQrButtonClick:
                return "send_form_qr_button_click"
            // Send - summary send click
            case .sendSummaryConfirmClick:
                return "send_summary_confirm_click"
            // Send - summary send success
            case .sendSummaryConfirmSuccess:
                return "send_summary_confirm_success"
            // Send - summary send failure
            case .sendSummaryConfirmFailure:
                return "send_summary_confirm_failure"
            // Send - bitpay send failure
            case .sendBitpayPaymentFailure:
                return "send_bitpay_payment_failure"
            // Send - bitpay send success
            case .sendBitpayPaymentSuccess:
                return "send_bitpay_payment_success"
            }
        }

        var params: [String: String]? {
            let assetParamName = Parameter.asset
            switch self {
            case .sendTabItemClick:
                return nil
            case .sendFormConfirmClick(asset: let asset):
                return [assetParamName: asset.code]
            case .sendFormConfirmSuccess(asset: let asset):
                return [assetParamName: asset.code]
            case .sendFormConfirmFailure(asset: let asset):
                return [assetParamName: asset.code]
            case .sendFormErrorAppear(asset: let asset):
                return [assetParamName: asset.code]
            case .sendFormErrorClick(asset: let asset):
                return [assetParamName: asset.code]
            case .sendFormUseBalanceClick(asset: let asset):
                return [assetParamName: asset.code]
            case .sendFormShowErrorAlert(asset: let asset):
                return [assetParamName: asset.code]
            case .sendFormExchangeButtonClick(asset: let asset):
                return [assetParamName: asset.code]
            case .sendFormQrButtonClick(asset: let asset):
                return [assetParamName: asset.code]
            case .sendSummaryConfirmClick(asset: let asset):
                return [assetParamName: asset.code]
            case .sendSummaryConfirmSuccess(asset: let asset):
                return [assetParamName: asset.code]
            case .sendSummaryConfirmFailure(asset: let asset):
                return [assetParamName: asset.code]
            case .sendBitpayPaymentFailure(asset: let asset):
                return [assetParamName: asset.code]
            case .sendBitpayPaymentSuccess(asset: let asset):
                return [assetParamName: asset.code]
            }
        }
    }

    // MARK: - Swap flow

    enum Swap: AnalyticsEvent {
        case swapTabItemClick

        var name: String {
            switch self {
            // Swap - tab item click
            case .swapTabItemClick:
                return "swap_tab_item_click"
            }
        }

        var params: [String: String]? {
            nil
        }
    }

    // MARK: - Transactions flow

    enum Transactions: AnalyticsEvent {
        case transactionsTabItemClick
        case transactionsListItemClick(asset: CryptoCurrency)
        case transactionsItemShareClick(asset: CryptoCurrency)
        case transactionsItemWebViewClick(asset: CryptoCurrency)

        var name: String {
            switch self {
            // Transactions - tab item click
            case .transactionsTabItemClick:
                return "transactions_tab_item_click"
            // Transactions - transaction item clicked
            case .transactionsListItemClick:
                return "transactions_list_item_click"
            // Transaction - share button clicked
            case .transactionsItemShareClick:
                return "transactions_item_share_click"
            // Transaction - view on web clicked
            case .transactionsItemWebViewClick:
                return "transactions_item_web_view_click"
            }
        }

        var params: [String: String]? {
            switch self {
            // Transactions - transaction item clicked
            case .transactionsListItemClick(asset: let asset):
                return [Parameter.asset: asset.code]
            // Transaction - share button clicked
            case .transactionsItemShareClick(asset: let asset):
                return [Parameter.asset: asset.code]
            // Transaction - view on web clicked
            case .transactionsItemWebViewClick(asset: let asset):
                return [Parameter.asset: asset.code]
            default:
                return nil
            }
        }
    }

    // MARK: - KYC flow

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
            }
        }

        var params: [String: String]? {
            nil
        }
    }

    // MARK: - Asset Selector

    enum AssetSelection: AnalyticsEvent {
        case assetSelectorOpen(asset: CryptoCurrency)
        case assetSelectorClose(asset: CryptoCurrency)

        var name: String {
            switch self {
            // Asset Selector - asset selector opened
            case .assetSelectorOpen:
                return "asset_selector_open"
            // Asset Selector - asset selector closed
            case .assetSelectorClose:
                return "asset_selector_close"
            }
        }

        var params: [String: String]? {
            switch self {
            case .assetSelectorOpen(asset: let asset):
                return [Parameter.asset: asset.code]
            case .assetSelectorClose(asset: let asset):
                return [Parameter.asset: asset.code]
            }
        }
    }
}
