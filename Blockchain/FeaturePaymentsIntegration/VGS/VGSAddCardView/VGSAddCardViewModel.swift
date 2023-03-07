// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import BlockchainUI
import Combine
import Errors
import FeatureCardPaymentData
import FeatureCardPaymentDomain
import VGSCollectSDK

private typealias L10n = LocalizationConstants.TextField.Gesture
private typealias L10nErrors = LocalizationConstants.CardDetailsScreen.Errors

class VGSAddCardViewModel: ObservableObject {
    private let cardTokenId: String
    private let vgsCollector: VGSCollect

    var cancellables: Set<AnyCancellable> = []

    var checkSuccessRateCancellable: AnyCancellable?

    @Published var isCardNameValid: Bool = true
    @Published var isCardNumberValid: Bool = true
    @Published var isCardExpiryValid: Bool = true
    @Published var isCardCvvValid: Bool = true

    @Published var formIsValid = false
    @Published var lastCardSuccessRate: CardSuccessRateStatus?
    @Published var isLoading = false

    @Published var presentError: Bool = false
    @Published var uxError: UX.Error?

    private let environment: VGSEnvironment

    init(
        environment: VGSEnvironment,
        cardTokenId: String,
        vgsCollector: VGSCollect
    ) {
        self.environment = environment
        self.cardTokenId = cardTokenId
        self.vgsCollector = vgsCollector
    }

    func startTextfieldObservation() {
        vgsCollector.observeStates = { [weak self] textFields in
            guard let self = self else { return }
            var formIsValid = true

            for textField in textFields {
                formIsValid = formIsValid && textField.state.isValid
                guard textField.isFirstResponder == false, textField.state.isDirty else {
                    return
                }
                self.handleTextFieldValidation(textField)
            }

            let canAddCard = self.lastCardSuccessRate?.canAddCard ?? false
            self.formIsValid = !self.isLoading && formIsValid && canAddCard
        }
    }

    func handleTextFieldValidation(_ textfield: VGSTextField) {
        guard let type = textfield.configuration?.type else { return }
        let isValid = textfield.state.isValid
        switch type {
        case .cardNumber:
            isCardNumberValid = isValid
        case .cardHolderName:
            isCardNameValid = isValid
        case .cvc:
            isCardCvvValid = isValid
        case .expDate:
            isCardExpiryValid = isValid
        default:
            break
        }
    }

    func handleTextfieldCallback(_ value: VGS.Input.DelegateCallback) {
        switch value {
        case .onReturn(let textField, _):
            handleTextFieldValidation(textField)
        case .onDidChange(let textField, let type) where type == .cardNumber:
            if let cardState = textField.state as? CardState, cardState.isValid {
                isLoading = true
                isCardNumberValid = true
                checkSuccessRateCancellable?.cancel()
                checkSuccessRateCancellable = checkSuccessRate(for: cardState.bin)
                    .first()
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] status in
                        self?.isLoading = false
                        self?.lastCardSuccessRate = status
                        print("latestBinError: \(status.message ?? "best")")
                    }
            } else {
                isLoading = false
                lastCardSuccessRate = nil
            }
        case .onDidEndEditing(let textField, _):
            handleTextFieldValidation(textField)
        default:
            break
        }
    }

    func checkSuccessRate(
        for cardBinNumber: String
    ) -> AnyPublisher<CardSuccessRateStatus, CardSuccessRateServiceError> {
        print("checkingSuccessRate... \(cardBinNumber)")
        return environment.cardSuccessRateService(cardBinNumber)
            .map { successRateData -> CardSuccessRateStatus in
                print(successRateData)
                let blockCard = successRateData.block
                let ux = successRateData.ux
                switch (blockCard, ux) {
                case (true, .some(let ux)):
                    return .blocked(UX.Error(nabu: ux))
                case (false, .some(let ux)):
                    return .unblocked(UX.Error(nabu: ux))
                case (false, .none):
                    return .best
                default:
                    return .best
                }
            }
            .eraseToAnyPublisher()
    }

    func sendDataToVGS(
        vgsCollect: VGSCollect,
        onSuccess: @escaping (CardPayload) -> Void
    ) {
        /// Check if textfields are valid
        vgsCollect.textFields.forEach { textField in
            textField.borderColor = textField.state.isValid ? .lightGray : .red
        }

        /// extra information will be sent together with all sensitive information from VGSCollect fields
        var extraData = [String: Any]()
        extraData["bc_card_token_id"] = cardTokenId
        extraData["address"] = address()

        vgsCollect.sendData(
            path: "/webhook/vgs/tokenize",
            extraData: extraData
        ) { [weak self] response in
            switch response {
            case .success(_, let data, _):
                if let data = data, let json = String(data: data, encoding: .utf8) {
                    if let vgsResponse = VGSTokenizeResponse.fromResponse(json: json) {
                        self?.waitForCardToBeAdded(
                            cardId: vgsResponse.beneficiaryId,
                            onSuccess: onSuccess
                        )
                    }
                }
            case .failure(let code, _, _, let error):
                switch code {
                case 400..<499:
                    // Wrong request. This also can happend when your Routs not setup yet or your <vaultId> is wrong
                    print("Wrong Request Error: \(code)")
                    self?.showError(uxError: .init(
                        title: L10nErrors.networkErrorTitle,
                        message: String(format: L10nErrors.networkErrorMessageWithCode, code)
                    ))
                case VGSErrorType.inputDataIsNotValid.rawValue:
                    if let error = error as? VGSError {
                        self?.showError(uxError: .init(
                            title: L10nErrors.networkErrorTitle,
                            message: String(format: L10nErrors.networkErrorMessageWithError, error)
                        ))
                    }
                    self?.showError(uxError: .init(
                        title: L10nErrors.networkErrorTitle,
                        message: String(format: L10nErrors.networkErrorMessageWithCode, code)
                    ))
                default:
                    self?.showError(uxError: .init(
                        title: L10nErrors.networkErrorTitle,
                        message: String(format: L10nErrors.networkErrorMessageWithCode, code)
                    ))
                }
            }
            return
        }
    }

    func waitForCardToBeAdded(
        cardId: String,
        onSuccess: @escaping (CardPayload) -> Void
    ) {
        environment.waitForActivationOfCard(cardId)
            .poll(max: 60, until: { $0.state != .pending }, delay: .seconds(1))
            .flatMap { [environment] payload -> AnyPublisher<CardPayload, Error> in
                environment
                    .fetchCardsAndPreferId(payload.identifier)
                    .eraseError()
                    .map { _ in payload }
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.showError(
                            uxError: UX.Error(error: error)
                        )
                        return
                    }
                },
                receiveValue: { cardPayload in
                    onSuccess(cardPayload)
                }
            )
            .store(in: &cancellables)
    }

    func address() -> [String: Any] {
        let line1 = try? app.state.get(blockchain.user.address.line_1, as: String.self)
        let line2 = try? app.state.get(blockchain.user.address.line_2, as: String.self)
        let state = try? app.state.get(blockchain.user.address.state, as: String.self)
        let city = try? app.state.get(blockchain.user.address.city, as: String.self)
        let postCode = try? app.state.get(blockchain.user.address.postal.code, as: String.self)
        let countryCode = try? app.state.get(blockchain.user.address.country.code, as: String.self)
        return [
            "line1": line1 ?? "",
            "line2": line2 ?? "",
            "city": city ?? "",
            "state": state ?? "",
            "postCode": postCode ?? "",
            "countryCode": countryCode ?? ""
        ]
    }

    private func showError(uxError: UX.Error) {
        self.uxError = uxError
        self.presentError = true
    }
}

extension VGSAddCardViewModel {
    enum CardSuccessRateStatus {
        case best                   // The card prefix has the best chance of success
        case unblocked(UX.Error?)   // The card prefix is permissable but has a chance of failure
        case blocked(UX.Error?)     // The card prefix belongs to a card that will not work

        var message: String? {
            switch self {
            case .best:
                return nil
            case .unblocked(let ux):
                return ux?.title ?? L10n.thisCardOftenDeclines
            case .blocked(let ux):
                return ux?.title ?? L10n.buyingCryptoNotSupported
            }
        }

        var errorTextColor: Color? {
            switch self {
            case .best:
                return nil
            case .unblocked:
                return .semantic.warning
            case .blocked:
                return .textError
            }
        }

        var borderColor: Color? {
            switch self {
            case .best:
                return .borderPrimary
            case .unblocked:
                return .semantic.warning
            case .blocked:
                return .borderError
            }
        }

        var canAddCard: Bool {
            switch self {
            case .blocked:
                return false
            default:
                return true
            }
        }
    }
}
