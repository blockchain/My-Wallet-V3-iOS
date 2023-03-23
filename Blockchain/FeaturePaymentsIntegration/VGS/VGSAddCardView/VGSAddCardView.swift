// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import BlockchainUI
import Combine
import FeatureCardPaymentDomain
import SwiftUI
import VGSCollectSDK

private enum FieldTag: Int {
    case cardName = 100
    case cardNumber = 101
    case cardExpiry = 102
    case cardCvv = 103
}

private typealias L10n = LocalizationConstants.TextField
private typealias L10nButton = LocalizationConstants.CardDetailsScreen

public struct VGSAddCardView: View {

    @BlockchainApp var app

    private let configBuilder: VGSConfigurationBuilder
    private let dismissBlock: () -> Void
    private let completeBlock: (CardPayload) -> Void

    @StateObject private var viewModel: VGSAddCardViewModel

    private let cardNameError: String = L10n.Gesture.invalidCardholderName
    private let cardNumberError: String = L10n.Gesture.invalidCardNumber
    private let cardExpiryError: String = L10n.Gesture.invalidExpirationDate
    private let cardCvvError: String = L10n.Gesture.invalidCVV

    typealias CardSuccessRateStatus = VGSAddCardViewModel.CardSuccessRateStatus

    private let vgsCollect: VGSCollect
    private let environment: VGSEnvironment

    public init(
        environment: VGSEnvironment,
        vgsCollect: VGSCollect,
        cardTokenId: String,
        configBuilder: VGSConfigurationBuilder,
        completeBlock: @escaping (CardPayload) -> Void,
        dismissBlock: @escaping () -> Void
    ) {
        self.environment = environment
        self.configBuilder = configBuilder
        self.completeBlock = completeBlock
        self.dismissBlock = dismissBlock
        self.vgsCollect = vgsCollect

        self._viewModel = .init(
            wrappedValue: VGSAddCardViewModel(
                environment: environment,
                cardTokenId: cardTokenId,
                vgsCollector: vgsCollect
            )
        )
    }

    public var body: some View {
        ScrollView {
            formView
                .background(Color.semantic.background)
        }
        .sheet(isPresented: $viewModel.presentError) {
            if let error = viewModel.uxError {
                ErrorView(ux: error) {
                    viewModel.uxError = nil
                    viewModel.presentError.toggle()
                }
            }
        }
        .onAppear {
            viewModel.startTextfieldObservation()
        }
    }

    public var cardNameView: some View {
        VStack(alignment: .leading, spacing: 0) {
            VGSFormLabelView(L10n.Title.Card.name)
            VGS.Input(
                configuration: .cardHolderName(vgsConfigurationBuilder: configBuilder),
                isValid: .constant(viewModel.isCardNameValid),
                collector: vgsCollect,
                onDelegateCallback: viewModel.handleTextfieldCallback(_:)
            )
            .frame(height: 48)
            if !viewModel.isCardNameValid {
                Text(cardNameError)
                    .typography(.caption1)
                    .foregroundColor(.textError)
                    .multilineTextAlignment(.leading)
                    .padding(.top, 2)
            }
        }
        .padding(.top, 8)
        .padding(.horizontal, Spacing.padding3)
    }

    public var cardNumberView: some View {
        VStack(alignment: .leading, spacing: 0) {
            VGSFormLabelView(L10n.Title.Card.number)
            VGS.Input(
                configuration: .cardNumber(vgsConfigurationBuilder: configBuilder),
                isValid: .constant(viewModel.isCardNumberValid),
                collector: vgsCollect,
                onDelegateCallback: viewModel.handleTextfieldCallback(_:)
            )
            .frame(height: 48)
            if !viewModel.isCardNumberValid {
                Text(cardNumberError)
                    .typography(.caption1)
                    .foregroundColor(.textError)
                    .multilineTextAlignment(.leading)
                    .padding(.top, 2)
            } else if let status = viewModel.lastCardSuccessRate,
                     let message = status.message,
                     let errorTextColor = status.errorTextColor
            {
                Text(message)
                    .typography(.caption1)
                    .foregroundColor(errorTextColor)
                    .multilineTextAlignment(.leading)
                    .padding(.top, 2)
            }
        }
        .padding(.top, 8)
        .padding(.horizontal, Spacing.padding3)
    }

    public var cardExpiryView: some View {
        VStack(alignment: .leading, spacing: 0) {
            VGSFormLabelView(L10n.Title.Card.expirationDate)
            VGS.Input(
                configuration: .cardExpiration(vgsConfigurationBuilder: configBuilder),
                isValid: .constant(viewModel.isCardExpiryValid),
                collector: vgsCollect,
                onDelegateCallback: viewModel.handleTextfieldCallback(_:)
            )
            .frame(height: 48)
            if !viewModel.isCardExpiryValid {
                Text(cardExpiryError)
                    .typography(.caption1)
                    .foregroundColor(.textError)
                    .multilineTextAlignment(.leading)
                    .padding(.top, 2)
            } else {
                EmptyView()
            }
        }
    }

    public var cardCvvView: some View {
        VStack(alignment: .leading, spacing: 0) {
            VGSFormLabelView(L10n.Title.Card.cvv)
            VGS.Input(
                configuration: .cardCVV(vgsConfigurationBuilder: configBuilder),
                isValid: .constant(viewModel.isCardCvvValid),
                collector: vgsCollect,
                onDelegateCallback: viewModel.handleTextfieldCallback(_:)
            )
            .frame(height: 48)
            if !viewModel.isCardCvvValid {
                Text(cardCvvError)
                    .typography(.caption1)
                    .foregroundColor(.textError)
                    .multilineTextAlignment(.leading)
                    .padding(.top, 2)
            } else {
                EmptyView()
            }
        }
    }

    public var formView: some View {
        VStack {
            cardNameView
            cardNumberView

            HStack(alignment: .top, spacing: Spacing.padding1) {
                cardExpiryView
                cardCvvView
            }
            .padding(.top, 8)
            .padding(.horizontal, Spacing.padding3)

            PrimaryButton(
                title: L10nButton.button,
                isLoading: viewModel.isLoading,
                action: {
                    viewModel.isLoading = true
                    viewModel.sendDataToVGS(
                        vgsCollect: vgsCollect,
                        onSuccess: completeBlock
                    )
                }
            )
            .disabled(!viewModel.formIsValid || viewModel.isLoading)
            .padding(.vertical, Spacing.padding2)
            .padding(.horizontal, Spacing.padding3)

            HStack(spacing: Spacing.textSpacing) {
                IconButton(icon: Icon.lockClosed, action: {})
                    .frame(width: 16, height: 16)
                Text(LocalizationConstants.CardDetailsScreen.notice)
                    .typography(.caption1)
                    .foregroundColor(.semantic.text)
            }
            .padding(.vertical, Spacing.padding1)
            .padding(.horizontal, Spacing.padding2)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.semantic.light)
            )
            .padding(.horizontal, Spacing.padding1)

            VGSAddCardFooterView()
                .app(app)
                .padding(Spacing.padding3)

            Spacer()
        }
    }
}
