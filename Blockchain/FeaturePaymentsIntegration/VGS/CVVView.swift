// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Combine
import Errors
import ErrorsUI
import Extensions
import FeatureCardPaymentDomain
import FeatureVGSData
import SwiftUI

struct CardDetails: Equatable {
    let name: String
    let numberSuffix: String
    let cvvLength: Int

    init(data: CardData) {
        self.name = data.label
        self.numberSuffix = data.suffix
        self.cvvLength = data.type.cvvLength
    }
}

private typealias L10n = LocalizationConstants.CVVView

struct CVVView: View {

    @BlockchainApp var app

    @State private var cvv = ""
    @State private var cvvIsFirstResponder = true

    private let paymentId: String
    private let dismissBlock: () -> Void

    @StateObject private var viewModel: Model

    init(
        vgsClient: VGSClientAPI,
        cardRepository: CardListRepositoryAPI,
        paymentId: String,
        paymentMethodId: String,
        dismissBlock: @escaping () -> Void
    ) {
        self.paymentId = paymentId
        self.dismissBlock = dismissBlock
        self._viewModel = .init(
            wrappedValue: .init(
                vgsClient: vgsClient,
                cardRepository: cardRepository,
                paymentMethodId: paymentMethodId
            )
        )
    }

    var body: some View {
        switch viewModel.state {
        case .loading:
            loadingContent
        case .loaded(let details):
            PrimaryNavigationView {
                mainContent(cardDetails: details)
            }
        case .error(let error):
            PrimaryNavigationView {
                ErrorView(
                    ux: error,
                    dismiss: dismissBlock
                )
            }
        }
    }

    @ViewBuilder
    private var loadingContent: some View {
        Spacer()
        ProgressView()
            .progressViewStyle(.circular)
            .onAppear {
                viewModel.fetchCardDetails()
            }
        Spacer()
    }

    @ViewBuilder
    private func mainContent(cardDetails: CardDetails) -> some View {
        VStack(spacing: 0) {
            Image("cvv-badge", bundle: .componentLibrary)
                .foregroundColor(.semantic.title)
                .padding(.top, 50)

            Text(L10n.contentTitle)
                .typography(.title3)
                .foregroundColor(.semantic.title)
                .padding(.top, 16)

            Text(L10n.contentDescription)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .typography(.bodyMono)
                .multilineTextAlignment(.center)
                .foregroundColor(.semantic.text)
                .padding(.top, 8)

            Input(
                text: $cvv,
                isFirstResponder: $cvvIsFirstResponder,
                label: L10n.cvvCode,
                subText: viewModel.cvvDisplaysError ? L10n.incorrectCVVCode : nil,
                subTextStyle: viewModel.cvvDisplaysError ? .error : .default,
                placeholder: "000",
                characterLimit: cardDetails.cvvLength,
                state: viewModel.cvvDisplaysError ? .error : .default,
                configuration: { textField in
                    textField.keyboardType = .numberPad
                    textField.returnKeyType = .done
                },
                trailing: {
                    IconButton(icon: Icon.lockClosed, action: {})
                        .frame(width: 24, height: 24)
                }
            )
            .onChange(of: cvv, perform: { newValue in
                viewModel.cvvInput = newValue
            })
            .padding(.top, 40)

            AlertCard(
                title: cardDetails.name,
                message: String(format: L10n.cardEndingTitle, cardDetails.numberSuffix)
            )
            .padding(.top, 17)

            Spacer()
            PrimaryButton(title: L10n.next, isLoading: viewModel.submitting) {
                cvvIsFirstResponder = false
                viewModel.postCvv(paymentId: paymentId, cvv: cvv, completion: { hasError in
                    if let error = hasError {
                        app.post(
                            event: blockchain.ux.payment.method.vgs.cvv.sent,
                            context: [blockchain.ux.payment.method.vgs.cvv.sent.failed.with.error: error]
                        )
                        dismissBlock()
                    } else {
                        app.state.set(blockchain.ux.payment.method.vgs.cvv.sent.payment.ids, to: [paymentId])
                        app.post(event: blockchain.ux.payment.method.vgs.cvv.sent)
                        dismissBlock()
                    }
                })
            }
            .disabled(viewModel.cvvInvalid)
        }
        .onAppear {
            viewModel.startValidation(details: cardDetails)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text(L10n.title)
                        .typography(.body2)
                        .foregroundColor(.semantic.title)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.semantic.background)
        .padding()
        .navigationBarBackButtonHidden(true)
    }
}

extension CVVView {
    class Model: ObservableObject {
        enum State: Equatable {
            case loading
            case loaded(CardDetails)
            case error(UX.Error)
        }

        private let vgsClient: VGSClientAPI
        private let cardRepository: CardListRepositoryAPI
        private let paymentMethodId: String

        private var cancellables: Set<AnyCancellable> = []

        @Published var cvvInput: String = ""
        @Published var cvvInvalid: Bool = false
        @Published var state: State = .loading

        @Published var submitting: Bool = false

        var cvvDisplaysError: Bool {
            cvvInput.isNotEmpty && cvvInvalid
        }

        init(
            vgsClient: VGSClientAPI,
            cardRepository: CardListRepositoryAPI,
            paymentMethodId: String
        ) {
            self.vgsClient = vgsClient
            self.cardRepository = cardRepository
            self.paymentMethodId = paymentMethodId
        }

        func postCvv(
            paymentId: String,
            cvv: String,
            completion: @escaping (NabuError?) -> Void
        ) {
            submitting = true
            vgsClient
                .postCVV(paymentId: paymentId, cvv: cvv)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { [weak self] streamCompletion in
                        self?.submitting = false
                        if case .failure(let error) = streamCompletion {
                            completion(error)
                        }
                    },
                    receiveValue: { [weak self] _ in
                        self?.submitting = false
                        completion(nil)
                    }
                )
                .store(in: &cancellables)
        }

        func fetchCardDetails() {
            cardRepository.card(by: paymentMethodId)
                .receive(on: DispatchQueue.main)
                .map { cardData -> State in
                    if let cardData {
                        return .loaded(CardDetails(data: cardData))
                    } else {
                        return .error(
                            UX.Error(
                                title: L10n.Error.unknownErrorTitle,
                                message: L10n.Error.errorMessage
                            )
                        )
                    }
                }
                .assign(to: &$state)
        }

        func startValidation(details: CardDetails) {
            $cvvInput
                .debounce(for: .milliseconds(250), scheduler: DispatchQueue.main)
                .map { value -> Bool in
                    value.count < details.cvvLength
                }
                .assign(to: &$cvvInvalid)
        }
    }
}
