// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainUI
import DelegatedSelfCustodyDomain
import FeatureDexData
import FeatureDexDomain
import SwiftUI

public struct DexDashboardAnalytics: Reducer {

    private typealias Event = AnalyticsEvents.New.Dex

    @Dependency(\.app) var app
    var analyticsRecorder: AnalyticsEventRecorderAPI

    init(analyticsRecorder: AnalyticsEventRecorderAPI) {
        self.analyticsRecorder = analyticsRecorder
    }

    public var body: some Reducer<DexDashboard.State, DexDashboard.Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                .none
            case .setIntro:
                .none
            case .introAction(let introAction):
                reduce(&state.intro, introAction)
            case .mainAction(let mainAction):
                reduce(&state.main, mainAction)
            case .binding:
                .none
            }
        }
    }

    private func reduce(_ state: inout DexMain.State, _ action: DexMain.Action) -> Effect<DexDashboard.Action> {
        switch action {
        case .refreshQuote:
            if state.source.isCurrentInput, let currency = state.source.currency, state.source.amount?.isPositive == true {
                record(.swapAmountEntered(currency: currency.code, position: .source))
            } else if state.destination.isCurrentInput, let currency = state.destination.currency, state.destination.amount?.isPositive == true {
                record(.swapAmountEntered(currency: currency.code, position: .destination))
            }
        case .sourceAction(.onTapCurrencySelector):
            record(.swapInputOpened)
        case .destinationAction(.onTapCurrencySelector):
            record(.swapOutputOpened)
        case .didTapAllowance:
            record(.swapApproveTokenClicked)
        case .binding(\.allowance.$transactionHash):
            record(.swapApproveTokenConfirmed)
        case .destinationAction(.didSelectCurrency(let balance)):
            record(.swapOutputSelected(outputCurrency: balance.currency.code))
        case .binding(\DexMain.State.settings.$slippage):
            record(.slippageChanged)
        case .didTapSettings:
            record(.settingsOpened)
        case .didTapFlip:
            record(.swapFlipClicked)
        case .didTapPreview:
            if let payload = QuotePayloadFactory.create(state.quote?.success) {
                record(.swapPreviewViewed(payload))
            }
        case .confirmationAction(.confirm):
            if let payload = QuotePayloadFactory.create(state.quote?.success) {
                record(.swapConfirmClicked(payload))
            }
        case .confirmationAction(.binding(\.$pendingTransaction)):
            switch state.confirmation?.pendingTransaction?.status {
            case .none:
                break
            case .error:
                record(.swapFailedViewed)
            case .inProgress:
                record(.swappingViewed)
            case .success:
                record(.swapExecutedViewed)
            }
        case .destinationAction(.assetPicker(.binding(\.$searchText))):
            if let assetPicker = state.destination.assetPicker,
               assetPicker.searchResults.isEmpty
            {
                record(.swapOutputNotFound(textSearched: String(assetPicker.searchText.prefix(32))))
            }
        default:
            break
        }
        return .none
    }

    private func reduce(_ state: inout DexIntro.State, _ action: DexIntro.Action) -> Effect<DexDashboard.Action> {
        switch action {
        case .onAppear:
            record(.onboardingViewed)
        default:
            break
        }
        return .none
    }

    private func record(_ event: Event) {
        analyticsRecorder.record(event: event)
    }
}

enum QuotePayloadFactory {

    static func create(
        _ quote: DexQuoteOutput?,
        service: EnabledCurrenciesServiceAPI = EnabledCurrenciesService.default
    ) -> AnalyticsEvents.New.Dex.QuotePayload? {
        guard let quote else {
            return nil
        }
        let inputNetwork = quote.sellAmount.currency.network()
        let outputNetwork = quote.buyAmount.amount.currency.network()
        let networkFee = quote.networkFee
        return AnalyticsEvents.New.Dex.QuotePayload(
            inputCurrency: quote.sellAmount.code,
            inputAmount: "\(quote.sellAmount.displayMajorValue)",
            outputCurrency: quote.buyAmount.amount.code,
            expectedOutputAmount: "\(quote.buyAmount.amount.displayMajorValue)",
            minOutputAmount: quote.buyAmount.minimum.flatMap { "\($0.displayMajorValue)" },
            slippageAllowed: quote.slippage,
            networkFeeAmount: networkFee.flatMap { "\($0.displayMajorValue)" },
            networkFeeCurrency: networkFee?.currency.code,
            inputNetwork: inputNetwork?.networkConfig.networkTicker,
            outputNetwork: outputNetwork?.networkConfig.networkTicker
        )
    }
}
