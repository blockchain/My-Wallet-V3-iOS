// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit

extension AnalyticsEvents.New {
    enum Dex: AnalyticsEvent, Hashable {
        enum Position: String {
            case source = "SOURCE"
            case destination = "DESTINATION"
        }

        /// DEX Onboarding Viewed - user is shown first step of the onboarding
        case onboardingViewed
        /// DEX Country Ineligible Viewed - user is shown ineligibility screen
        case countryIneligibleViewed
        /// DEX Swap Flip Clicked
        case swapFlipClicked
        /// DEX Swap Amount Entered - users enters an amount in the input field
        case swapAmountEntered(currency: String, position: Position)
        /// DEX Swap Input Opened - user opens the input coin selector
        case swapInputOpened
        /// DEX Swap Approve Token Clicked - user clicks in approve token to be able to swap
        case swapApproveTokenClicked
        /// DEX Swap Approve Token Confirmed - user confirms the approval of the token
        case swapApproveTokenConfirmed
        /// DEX Swap Output Opened - user opens the output coin selector
        case swapOutputOpened
        /// DEX Swap Output Not Found - user is shown the “No results for X”
        case swapOutputNotFound(textSearched: String)
        /// DEX Swap Output Selected - user selects a token output
        case swapOutputSelected(outputCurrency: String)
        /// DEX Swap Preview Viewed - user sees preview screen
        case swapPreviewViewed(QuotePayload)
        /// DEX Swap Confirm Clicked - user clicks in confirm swap
        case swapConfirmClicked(QuotePayload)
        /// DEX Swapping Viewed - user sees the swapping screen
        case swappingViewed
        /// DEX Swap Executed Viewed - users sees the congrats screen
        case swapExecutedViewed
        /// DEX Swap Failed Viewed - users sees the failed screen
        case swapFailedViewed
        /// DEX Settings Opened - user opens the settings flyout
        case settingsOpened
        /// DEX Slippage Changed - user changes slippage
        case slippageChanged

        var type: AnalyticsEventType { .nabu }

        var name: String { "DEX \(defaultName)" }
    }
}

extension AnalyticsEvents.New.Dex {
    struct QuotePayload: Hashable {
        var inputCurrency: String
        var inputAmount: String
        var inputAmountUsd: String?
        var outputCurrency: String
        var expectedOutputAmount: String
        var expectedOutputAmountUsd: String?
        var minOutputAmount: String?
        var slippageAllowed: String
        var networkFeeAmount: String
        var networkFeeCurrency: String
        var blockchainFeeAmount: String?
        var blockchainFeeAmountUsd: String?
        var blockchainFeeCurrency: String?
        var inputNetwork: String?
        var outputNetwork: String?
    }
}
