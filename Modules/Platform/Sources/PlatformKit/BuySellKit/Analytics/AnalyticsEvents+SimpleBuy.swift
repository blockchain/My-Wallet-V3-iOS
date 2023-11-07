// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import MoneyKit
import ToolKit

extension AnalyticsEvents {

    public enum SimpleBuy: AnalyticsEvent {

        public enum PaymentMethod: String {
            case card
            case bank
            case funds
            case newCard
            case applePay

            public var string: String {
                switch self {
                case .card:
                    "CARD"
                case .funds:
                    "FUNDS"
                case .bank:
                    "BANK"
                case .newCard:
                    "NEW_CARD"
                case .applePay:
                    "APPLE_PAY"
                }
            }
        }

        public enum LinkedBankPartner: String {
            case ach = "ACH"
            case ob = "OB"
        }

        public enum CheckoutStatus: String {
            case success = "SUCCESS"
            case failure = "FAILURE"
            case timeout = "TIMEOUT"
        }

        public enum ParameterName {
            public static let paymentMethod = "paymentMethod"
            static let currency = "currency"
            static let amount = "amount"
        }

        case sbWantToBuyScreenShown
        case sbWantToBuyButtonClicked
        case sbWantToBuyButtonSkip
        case sbWantToBuyScreenError
        case sbBuyFormShown
        case sbBuyFormConfirmClick(currencyCode: String, amount: String, additionalParameters: [String: String])
        case sbBuyFormConfirmSuccess
        case sbBuyFormCryptoChanged(asset: String)
        case sbBuyFormMinFailure
        case sbBuyFormMinClicked
        case sbBuyFormMaxFailure
        case sbBuyFormMaxClicked
        case sbBuyFormFiatChanged(currencyCode: String)
        case sbBuyFormConfirmFailure
        case sbKycStart
        case sbKycVerifying
        case sbKycManualReview
        case sbKycPending
        case sbPostKycNotEligible
        case sbCheckoutShown(paymentMethod: PaymentMethod)
        case sbCheckoutConfirm(paymentMethod: PaymentMethod)
        case sbCheckoutCancel
        case sbCheckoutCancelPrompt
        case sbCheckoutCancelConfirmed(paymentMethod: PaymentMethod)
        case sbCheckoutCancelGoBack
        case sbBankDetailsShown(currencyCode: String)
        case sbBankDetailsCopied(bankName: String)
        case sbBankDetailsFinished
        case sbPendingModalShown(currencyCode: String)
        case sbPendingModalCancelClick
        case sbPendingBannerShown
        case sbPendingViewBankDetails
        case sbCancelOrderPrompt
        case sbCancelOrderConfirmed
        case sbCancelOrderGoBack
        case sbCancelOrderError
        case sbCustodyWalletCardShown
        case sbCustodyWalletCardClicked
        case sbBackupWalletCardShown
        case sbBackupWalletCardClicked
        case sbTradingWalletClicked(asset: CryptoCurrency)
        case sbTradingWalletSend(asset: CryptoCurrency)
        case sbWithdrawalScreenShown(asset: CryptoCurrency)
        case sbWithdrawalScreenClicked(asset: CryptoCurrency)
        case sbWithdrawalScreenSuccess
        case sbWithdrawalScreenFailure
        case sbPaymentMethodShown
        case sbPaymentMethodSelected(selection: PaymentMethod)
        case sbAddCardScreenShown
        case sbCardInfoSet
        case sbBillingAddressSet
        case sbThreeDSecureComplete
        case sbRemoveCard
        case sbCurrencySelectScreen
        case sbCurrencySelected(currencyCode: String)
        case sbCurrencyUnsupported
        case sbUnsupportedChangeCurrency
        case sbUnsupportedViewHome
        case sbCheckoutCompleted(status: CheckoutStatus)
        case sbSettingsAddCardClicked
        case sbRemoveBank
        case sbLinkBankClicked
        case sbSettingsNoInternet
        case sbLinkBankLoadingError(currencyCode: String)
        case sbLinkBankScreenShown(currencyCode: String)
        case sbLinkBankDetailsCopied
        case sbLinkBankEmailClicked
        case sbBankLinkSplashSeen(partner: LinkedBankPartner)
        case sbBankLinkSplashCTA(partner: LinkedBankPartner)
        case sbAchSuccess
        case sbAchClose
        case sbAchError
        case sbBankLinkSuccess(partner: LinkedBankPartner)
        case sbIncorrectAccountError(partner: LinkedBankPartner)
        case sbAlreadyLinkedError(partner: LinkedBankPartner)
        case sbBankLinkGenericError(partner: LinkedBankPartner)
        case sbAccountMismatchedError(partner: LinkedBankPartner)

        public var name: String {
            switch self {
            // Simple buy - I want to buy crypto screen shown (4.0)
            case .sbWantToBuyScreenShown:
                "sb_want_to_buy_screen_shown"
            // Simple buy - I want to buy crypto button clicked
            case .sbWantToBuyButtonClicked:
                "sb_want_to_buy_button_clicked"
            // Simple buy - Skip I already have crypto button clicked
            case .sbWantToBuyButtonSkip:
                "sb_want_to_buy_button_skip"
            // Simple buy - I want to buy crypto error (4.1)
            case .sbWantToBuyScreenError:
                "sb_want_to_buy_screen_error"
            // Simple buy - buy form shown (5.0)
            case .sbBuyFormShown:
                "sb_buy_form_shown"
            // Simple buy - confirm amount clicked (5.0)
            case .sbBuyFormConfirmClick:
                "sb_buy_form_confirm_click"
            // Simple buy - confirm amount success (5.0) *
            case .sbBuyFormConfirmSuccess:
                "sb_buy_form_confirm_success"
            // Simple buy - crypto changed (5.1)
            case .sbBuyFormCryptoChanged:
                "sb_buy_form_crypto_changed"
            // Simple buy - confirm amount min error (5.2)*
            case .sbBuyFormMinFailure:
                "sb_buy_form_min_failure"
            // Simple buy - buy mininum clicked (5.2)
            case .sbBuyFormMinClicked:
                "sb_buy_form_min_clicked"
            // Simple buy - confirm amount max error (5.3)*
            case .sbBuyFormMaxFailure:
                "sb_buy_form_max_failure"
            // Simple buy - buy maximum clicked (5.3)
            case .sbBuyFormMaxClicked:
                "sb_buy_form_max_clicked"
            // Simple buy - fiat changed (5.4)
            case .sbBuyFormFiatChanged:
                "sb_buy_form_fiat_changed"
            // Simple buy - confirm amount failed (5.5)*
            case .sbBuyFormConfirmFailure:
                "sb_buy_form_confirm_failure"
            // Simple buy - start gold flow (6.0)
            case .sbKycStart:
                "sb_kyc_start"
            // Simple buy - kyc verifying (6.1)
            case .sbKycVerifying:
                "sb_kyc_verifying"
            // Simple buy - kyc manual review (6.2)
            case .sbKycManualReview:
                "sb_kyc_manual_review"
            // Simple buy - kyc pending review (6.3)
            case .sbKycPending:
                "sb_kyc_pending"
            // Simple buy - post kyc not eligible (6.4)
            case .sbPostKycNotEligible:
                "sb_post_kyc_not_eligible"
            // Simple buy - checkout summary shown (7.0)
            case .sbCheckoutShown:
                "sb_checkout_shown"
            // Simple buy - checkout summary confirmed (7.0)
            case .sbCheckoutConfirm:
                "sb_checkout_confirm"
            // Simple buy - checkout summary press cancel (7.0)
            case .sbCheckoutCancel:
                "sb_checkout_cancel"
            // Simple buy - checkout cancellation prompt shown (7.1)
            case .sbCheckoutCancelPrompt:
                "sb_checkout_cancel_prompt"
            // Simple buy - checkout cancellation confirmed (7.1)
            case .sbCheckoutCancelConfirmed:
                "sb_checkout_cancel_confirmed"
            // Simple buy - checkout cancellation go back (7.1)
            case .sbCheckoutCancelGoBack:
                "sb_checkout_cancel_go_back"
            // Simple buy - bank details shown (7.2, 7.3)
            case .sbBankDetailsShown:
                "sb_bank_details_shown"
            // Simple buy - bank details copied (7.2, 7.3 & 8.2)
            case .sbBankDetailsCopied:
                "sb_bank_details_copied"
            // Simple buy - bank details finished (7.2, 7.3 & 8.2)
            case .sbBankDetailsFinished:
                "sb_bank_details_finished"
            // Simple buy - pending transfer modal shown (8.2)
            case .sbPendingModalShown:
                "sb_pending_modal_shown"
            // Simple buy - pending transfer, cancel button clicked (8.2)
            case .sbPendingModalCancelClick:
                "sb_pending_modal_cancel_click"
            // Simple buy - pending transfer, banner shown (8.0)
            case .sbPendingBannerShown:
                "sb_pending_banner_shown"
            // Simple buy - pending transfer, view bank transfer details clicked (8.0)
            case .sbPendingViewBankDetails:
                "sb_pending_view_bank_details"
            // Simple buy - checkout cancellation prompt (tbc, under 8.2)
            case .sbCancelOrderPrompt:
                "sb_cancel_order_prompt"
            // Simple buy - checkout cancellation confirmed (tbc, under 8.2)
            case .sbCancelOrderConfirmed:
                "sb_cancel_order_confirmed"
            // Simple buy - checkout cancellation go back (tbc, under 8.2)
            case .sbCancelOrderGoBack:
                "sb_cancel_order_go_back"
            // Simple buy - checkout cancel error (tbc, under 8.2)
            case .sbCancelOrderError:
                "sb_cancel_order_error"
            // Simple buy - your custody wallet card shown (9.1)
            case .sbCustodyWalletCardShown:
                "sb_custody_wallet_card_shown"
            // Simple buy - your custody wallet card clicked (9.1)
            case .sbCustodyWalletCardClicked:
                "sb_custody_wallet_card_clicked"
            // Simple buy - back up your wallet (10.1)
            case .sbBackupWalletCardShown:
                "sb_backup_wallet_card_shown"
            // Simple buy - back up your wallet clicked (10.1)
            case .sbBackupWalletCardClicked:
                "sb_backup_wallet_card_clicked"
            // Simple buy - trading wallet currency clicked (10.4)
            case .sbTradingWalletClicked:
                "sb_trading_wallet_clicked"
            // Simple buy - trading wallet currency send (10.4)
            case .sbTradingWalletSend:
                "sb_trading_wallet_send"
            // Simple buy - withdraw screen shown (11.0)
            case .sbWithdrawalScreenShown:
                "sb_withdrawal_screen_shown"
            // Simple buy - withdraw screen clicked (11.0)
            case .sbWithdrawalScreenClicked:
                "sb_withdrawal_screen_clicked"
            // Simple buy - withdraw screen success (11.1)
            case .sbWithdrawalScreenSuccess:
                "sb_withdrawal_screen_success"
            // Simple buy - withdraw screen faillure (11.2)
            case .sbWithdrawalScreenFailure:
                "sb_withdrawal_screen_failure"
            // Simple buy - payment method screen shown (2.0)
            case .sbPaymentMethodShown:
                "sb_payment_method_shown"
            // Simple buy - payment method selected (2.1)
            case .sbPaymentMethodSelected:
                "sb_payment_method_selected"
            // Simple buy - Billing Address Set (3.3)
            case .sbBillingAddressSet:
                "sb_billing_address_set"
            // Simple buy - 3DS Complete (3.4)
            case .sbThreeDSecureComplete:
                "sb_three_d_secure_complete"
            // Simple Buy - Remove Card (5.1)
            case .sbRemoveCard:
                "sb_remove_card"
            // Simple Buy - Select your currency (card shown, 0.1 Fiat)
            case .sbCurrencySelectScreen:
                "sb_currency_select_screen"
            // Simple Buy - Currency selected (clicked on currency, 0.1)
            case .sbCurrencySelected:
                "sb_currency_selected"
            // Simple Buy - Settings Add Card click (5.0/3.0(sell))
            case .sbSettingsAddCardClicked:
                "sb_settings_add_card_clicked"
            // Simple Buy - Remove Bank(3.5)
            case .sbRemoveBank:
                "sb_remove_bank"
            // Simple Buy - Link Bank clicked(3.0)
            case .sbLinkBankClicked:
                "sb_link_bank_clicked"
            // Simple Buy - settings no internet
            case .sbSettingsNoInternet:
                "sb_settings_no_internet"
            // Simple Buy - Link Bank loading error
            case .sbLinkBankLoadingError:
                "sb_link_bank_loading_error"
            // Simple Buy - Link Bank screen shown (3.1/3.2)
            case .sbLinkBankScreenShown:
                "sb_link_bank_screen_shown"
            // Simple Buy - Link Bank Details copied
            case .sbLinkBankDetailsCopied:
                "sb_link_bank_details_copied"
            // Simple Buy - Link Bank Email clicked
            case .sbLinkBankEmailClicked:
                "sb_link_bank_email_clicked"
            // Simple Buy - Currency Not Supported (screen shown, 0.2)
            case .sbCurrencyUnsupported:
                "sb_currency_unsupported"
            // Simple Buy - Change Currency (button clicked, 0.2)
            case .sbUnsupportedChangeCurrency:
                "sb_unsupported_change_currency"
            // Simple Buy - View Home (button clicked, 0.2)
            case .sbUnsupportedViewHome:
                "sb_unsupported_view_home"
            case .sbAddCardScreenShown:
                "sb_add_card_screen_shown"
            case .sbCardInfoSet:
                "sb_card_info_set"
            case .sbCheckoutCompleted:
                "sb_checkout_completed"
            case .sbBankLinkSplashSeen:
                "sb_bank_link_splash_seen"
            case .sbBankLinkSplashCTA:
                "sb_bank_link_splash_cont"
            case .sbAchSuccess:
                "sb_ach_success"
            case .sbAchClose:
                "sb_ach_close"
            case .sbAchError:
                "sb_ach_error"
            case .sbBankLinkSuccess:
                "sb_bank_link_success"
            case .sbAccountMismatchedError:
                "sb_acc_name_mis_error"
            case .sbIncorrectAccountError:
                "sb_incorrect_acc_error"
            case .sbAlreadyLinkedError:
                "sb_already_linkd_error"
            case .sbBankLinkGenericError:
                "sb_bank_link_gen_error"
            }
        }

        public var params: [String: String]? {

            switch self {
            case .sbCheckoutCompleted(status: let status):
                return ["status": status.rawValue]
            case .sbPaymentMethodSelected(selection: let selection):
                return ["selection": selection.rawValue]
            case .sbBankDetailsShown(currencyCode: let currencyCode),
                 .sbPendingModalShown(currencyCode: let currencyCode),
                 .sbBuyFormFiatChanged(currencyCode: let currencyCode),
                 .sbCurrencySelected(currencyCode: let currencyCode),
                 .sbLinkBankScreenShown(currencyCode: let currencyCode),
                 .sbLinkBankLoadingError(currencyCode: let currencyCode):
                return [ParameterName.currency: currencyCode]
            case .sbTradingWalletSend(asset: let currency),
                 .sbTradingWalletClicked(asset: let currency),
                 .sbWithdrawalScreenShown(asset: let currency),
                 .sbWithdrawalScreenClicked(asset: let currency):
                return ["asset": currency.code]
            case .sbBuyFormConfirmClick(currencyCode: let currencyCode, amount: let amount, additionalParameters: let additionalParameters):
                let parameters = [
                    ParameterName.currency: currencyCode,
                    ParameterName.amount: amount
                ]
                return parameters + additionalParameters
            case .sbCheckoutShown(paymentMethod: let method):
                return [ParameterName.paymentMethod: method.string]
            case .sbCheckoutCancelConfirmed(paymentMethod: let method):
                return [ParameterName.paymentMethod: method.string]
            case .sbCheckoutConfirm(paymentMethod: let method):
                return [ParameterName.paymentMethod: method.string]
            case .sbBankDetailsCopied(bankName: let bankName):
                return ["bank field name": bankName]
            case .sbBankLinkSplashCTA(let partner),
                 .sbBankLinkSplashSeen(let partner),
                 .sbBankLinkSuccess(let partner),
                 .sbAccountMismatchedError(let partner),
                 .sbIncorrectAccountError(let partner),
                 .sbAlreadyLinkedError(let partner),
                 .sbBankLinkGenericError(let partner):
                return ["partner": partner.rawValue]
            default:
                return nil
            }
        }
    }
}
