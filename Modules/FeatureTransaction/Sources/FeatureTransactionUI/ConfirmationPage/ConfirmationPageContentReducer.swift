// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import DIKit
import FeatureTransactionDomain
import Localization
import MoneyKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit
import UIComponentsKit
import UIKit

protocol ConfirmationPageContentReducing {
    /// The title of the checkout screen
    var title: String { get }
    /// The `Cells` on the `ConfirmationPage`
    var cells: [DetailsScreen.CellType] { get }
    var buttons: [ButtonViewModel] { get }
    var disclaimers: [DisclaimerViewModel] { get }
    var continueButtonViewModel: ButtonViewModel { get }
    var cancelButtonViewModel: ButtonViewModel { get }
}

final class ConfirmationPageContentReducer: ConfirmationPageContentReducing {

    // MARK: - Types

    typealias ConfirmationModel = TransactionConfirmations

    // MARK: - Private Types

    private typealias LocalizedString = LocalizationConstants.Transaction

    // MARK: - CheckoutScreenContentReducing

    var title: String = ""
    var cells: [DetailsScreen.CellType] = []
    var navigationBarAppearance: DetailsScreen.NavigationBarAppearance = .hidden

    let continueButtonViewModel: ButtonViewModel
    let cancelButtonViewModel: ButtonViewModel

    var header: HeaderBuilder?

    /// Buttons that should be displayed on the confirmation screen.
    /// Wallet connect transactions will require a `Cancel` button so
    /// we will have to introspect the `TransactionState` to determine
    /// what buttons to show. This is the only time the `Cancel` button
    /// should be visible.
    var buttons: [ButtonViewModel] = []

    var disclaimers: [DisclaimerViewModel] = []

    let termsCheckboxViewModel: CheckboxViewModel = .termsCheckboxViewModel
    var arDepositCheckboxViewModel: CheckboxViewModel!

    /// A `CheckboxViewModel` that prompts the user to confirm
    /// that they will be transferring funds to their rewards account.
    /// This `CheckboxViewModel` needs data from the `TransactionState`
    /// so we cannot initialize until we receive it.
    var transferCheckboxViewModel: CheckboxViewModel?

    let messageRecorder: MessageRecording
    let arAgreementUpdated = PublishRelay<Bool>()
    let transferAgreementUpdated = PublishRelay<Bool>()
    let termsUpdated = PublishRelay<Bool>()
    let showACHDepositTermsTapped = PublishRelay<String>()
    let availableToWithdrawDateInfoTapped = PublishRelay<Void>()
    let hyperlinkTapped = PublishRelay<TitledLink>()
    let memoUpdated = PublishRelay<(String, TransactionConfirmations.Memo)>()
    let memoModel: TextFieldViewModel
    private var disposeBag = DisposeBag()
    private var cancellables = Set<AnyCancellable>()
    private let withdrawalLocksCheckRepository: WithdrawalLocksCheckRepositoryAPI
    private let analyticsRecorder: AnalyticsEventRecorderAPI

    // MARK: - Private Properties

    init(
        messageRecorder: MessageRecording = resolve(),
        withdrawalLocksCheckRepository: WithdrawalLocksCheckRepositoryAPI = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve()
    ) {
        self.messageRecorder = messageRecorder
        self.withdrawalLocksCheckRepository = withdrawalLocksCheckRepository
        self.analyticsRecorder = analyticsRecorder
        self.cancelButtonViewModel = .cancel(with: LocalizedString.Confirmation.cancel)
        self.continueButtonViewModel = .primary(with: "")
        self.memoModel = TextFieldViewModel(
            with: .memo,
            validator: TextValidationFactory.Send.memo,
            messageRecorder: messageRecorder
        )
    }

    func setup(for state: TransactionState) {
        disposeBag = DisposeBag()
        title = Self.screenTitle(state: state)
        continueButtonViewModel.textRelay.accept(Self.confirmCtaText(state: state))
        continueButtonViewModel.backgroundColorRelay.accept(Self.confirmCtaBackgroundColor(state: state))
        navigationBarAppearance = .custom(
            leading: state.stepsBackStack.isEmpty ? .none : .back,
            trailing: .none,
            barStyle: .darkContent(ignoresStatusBar: false, background: .white)
        )

        buttons = createButtons(state: state)
        disclaimers = createDisclaimers(state: state)
        cells = createCells(state: state)
        header = createHeader(state: state)
    }

    private func createButtons(state: TransactionState) -> [ButtonViewModel] {
        var buttons = [continueButtonViewModel]
        if state.destination is StaticTransactionTarget {
            buttons.insert(cancelButtonViewModel, at: 0)
        }
        return buttons
    }

    private func createDisclaimers(state: TransactionState) -> [DisclaimerViewModel] {
        var disclaimers = [DisclaimerViewModel]()
        if TransactionFlowDescriptor.confirmDisclaimerVisibility(action: state.action) {
            if state.action == .buy {
                let paymentMethod = (state.source as? PaymentMethodAccount)?.paymentMethod
                let disclaimerViewModel = DisclaimerViewModel(text: nil)
                withdrawalLocksCheckRepository.withdrawalLocksCheck(
                    paymentMethod: paymentMethod?.type.requestType.rawValue,
                    currencyCode: state.source?.currencyType.code
                )
                .map {
                    TransactionFlowDescriptor.confirmDisclaimerForBuy(
                        paymentMethod: paymentMethod,
                        lockDays: $0.lockDays
                    ).attributed
                        + " ".attributed
                        + TransactionFlowDescriptor.confirmDisclaimerText(
                            action: state.action,
                            currencyCode: state.asset.code,
                            accountLabel: state.destination?.label ?? "",
                            isSafeConnect: (state.source as? PaymentMethodAccount)?.isYapily == true
                                || (state.source as? LinkedBankAccount)?.data.partner == .yapily
                        )
                }
                .sink(receiveValue: { text in
                    disclaimerViewModel.textSubject.send(text)
                })
                .store(in: &cancellables)
                disclaimers.append(disclaimerViewModel)
            } else {
                let text = TransactionFlowDescriptor
                    .confirmDisclaimerText(
                        action: state.action,
                        currencyCode: state.asset.code,
                        accountLabel: state.destination?.label ?? "",
                        isSafeConnect: (state.source as? PaymentMethodAccount)?.isYapily == true
                        || (state.source as? LinkedBankAccount)?.data.partner == .yapily
                    )
                if text.string.isNotEmpty {
                    disclaimers.append(
                        DisclaimerViewModel(
                            text: text
                        )
                    )
                }
            }
        }
        return disclaimers
    }

    // swiftlint:disable:next function_body_length
    private func createCells(state: TransactionState) -> [DetailsScreen.CellType] {
        guard let pendingTransaction = state.pendingTransaction else {
            return []
        }

        let amount = state.amount
        let fee = pendingTransaction.feeAmount
        let value = (try? amount + fee) ?? .zero(currency: amount.currency)

        // NOTE: This is not ideal. We do not know the
        // amount, fee, and total amount for the transaction
        // until we receive the `TransactionState`. That means
        // we cannot initialize a `transferCheckboxViewModel` until
        // this `setup(for state:)` function is called. So, we check to
        // see if this is `nil` prior to initializing it.
        if transferCheckboxViewModel == nil {

            let message: String

            switch (state.action, state.pendingTransaction?.limits?.earn?.bondingDays) {
            case (.stakingDeposit, 0):
                message = LocalizedString.Staking.transferAgreementNoBonding
            case (.stakingDeposit, 1):
                message = LocalizedString.Staking.transferAgreementDayBonding
            case (.stakingDeposit, _):
                message = LocalizedString.Staking.transferAgreementDaysBonding
            case (.activeRewardsDeposit, _):
                message = LocalizedString.Transfer.transferAgreementAR
            case _:
                message = LocalizedString.Transfer.transferAgreement
            }

            transferCheckboxViewModel = .init(
                inputs: [
                    .text(
                        string: String(
                            format: message, value.displayString, "\(state.pendingTransaction?.limits?.earn?.bondingDays ?? 7)"
                        )
                    )
                ]
            )
        }

        let confirmations = pendingTransaction.confirmations

        let interactors: [DefaultLineItemCellPresenter] = confirmations
            .filter { confirmation -> Bool in
                !confirmation.isCustom
            }
            .compactMap(\.formatted)
            .map { data -> (title: LabelContentInteracting, subtitle: LabelContentInteracting) in
                (DefaultLabelContentInteractor(knownValue: data.0), DefaultLabelContentInteractor(knownValue: data.1))
            }
            .map { data in
                DefaultLineItemCellInteractor(title: data.title, description: data.subtitle)
            }
            .map { interactor in
                DefaultLineItemCellPresenter(
                    interactor: interactor,
                    accessibilityIdPrefix: interactor.title.stateRelay.value.value?.text ?? ""
                )
            }

        var bitpayItemIfNeeded: [DetailsScreen.CellType] = confirmations
            .filter(\.isBitPay)
            .compactMap(\.formatted)
            .map { data -> (title: LabelContentInteracting, subtitle: LabelContentInteracting) in
                (DefaultLabelContentInteractor(knownValue: data.0), DefaultLabelContentInteractor(knownValue: data.1))
            }
            .map { data in
                DefaultLineItemCellInteractor(title: data.title, description: data.subtitle)
            }
            .map { interactor -> DetailsScreen.CellType in
                let presenter = DefaultLineItemCellPresenter(
                    interactor: interactor,
                    accessibilityIdPrefix: interactor.title.stateRelay.value.value?.text ?? ""
                )
                setupBitPay(on: presenter)
                return .lineItem(presenter)
            }
        if !bitpayItemIfNeeded.isEmpty {
            bitpayItemIfNeeded.append(.separator)
        }

        let confirmationLineItems: [DetailsScreen.CellType] = interactors
            .reduce(into: [DetailsScreen.CellType]()) { result, lineItem in
                result.append(.lineItem(lineItem))
                result.append(.separator)
            }

        let errorModels: [DetailsScreen.CellType] = confirmations
            .filter(\.isErrorNotice)
            .compactMap(\.formatted)
            .map(\.subtitle)
            .map { subtitle -> DefaultLabelContentPresenter in
                DefaultLabelContentPresenter(
                    knownValue: subtitle,
                    descriptors: .init(
                        fontWeight: .semibold,
                        contentColor: .destructive,
                        fontSize: 14.0,
                        accessibility: .none
                    )
                )
            }
            .map { presenter -> DetailsScreen.CellType in
                .label(presenter)
            }

        let imageNoticeModels: [DetailsScreen.CellType] = confirmations
            .filter(\.isImageNotice)
            .compactMap { confirmation -> TransactionConfirmations.ImageNotice? in
                confirmation as? TransactionConfirmations.ImageNotice
            }
            .map { model -> NoticeViewModel in
                let imageResource = URL(string: model.imageURL)
                    .flatMap(ImageResource.remote)
                let imageViewContent = ImageViewContent(
                    imageResource: imageResource,
                    accessibility: .none,
                    renderingMode: .normal
                )
                let title = LabelContent(text: model.title, font: .main(.semibold, 16), color: .darkTitleText)
                let subtitle = LabelContent(text: model.subtitle, font: .main(.medium, 12), color: .descriptionText)

                return NoticeViewModel(
                    imageViewContent: imageViewContent,
                    imageViewSize: .edge(40),
                    labelContents: [title, subtitle],
                    verticalAlignment: .center
                )
            }
            .map { model -> DetailsScreen.CellType in
                .notice(model)
            }

        let noticeModels: [DetailsScreen.CellType] = confirmations
            .filter(\.isNotice)
            .compactMap(\.formatted)
            .map(\.subtitle)
            .map { subtitle -> DefaultLabelContentPresenter in
                DefaultLabelContentPresenter(
                    knownValue: subtitle,
                    descriptors: .init(
                        fontWeight: .medium,
                        contentColor: .darkTitleText,
                        fontSize: 14,
                        accessibility: .none
                    )
                )
            }
            .map { presenter -> DetailsScreen.CellType in
                .label(presenter)
            }

        let memo: TransactionConfirmations.Memo? = confirmations
            .filter(\.isMemo)
            .compactMap { confirmation -> TransactionConfirmations.Memo? in
                confirmation as? TransactionConfirmations.Memo
            }
            .first

        let terms: ConfirmationModel.AnyBoolOption<Bool>? = confirmations
            .filter(\.isTermsOfService)
            .compactMap { confirmation -> ConfirmationModel.AnyBoolOption<Bool>? in
                confirmation as? ConfirmationModel.AnyBoolOption<Bool>
            }
            .first

        let transferAgreement: ConfirmationModel.AnyBoolOption<Bool>? = confirmations
            .filter(\.isTransferAgreement)
            .compactMap { confirmation -> ConfirmationModel.AnyBoolOption<Bool>? in
                confirmation as? ConfirmationModel.AnyBoolOption<Bool>
            }
            .first

        let depositACHTerms: TransactionConfirmations.DepositTerms? = confirmations
            .filter(\.isDepositACHTerms)
            .compactMap { confirmation -> TransactionConfirmations.DepositTerms? in
                confirmation as? TransactionConfirmations.DepositTerms
            }
            .first

        let availableToWithdrawDate: TransactionConfirmations.AvailableToWithdrawDate? = confirmations
            .filter(\.isAvailableToWithdrawDate)
            .compactMap { confirmation -> TransactionConfirmations.AvailableToWithdrawDate? in
                confirmation as? TransactionConfirmations.AvailableToWithdrawDate
            }
            .first

        var memoModels: [DetailsScreen.CellType] = []
        if let memo {
            let subtitle = memo.formatted?.subtitle ?? ""
            memoModel.originalTextRelay.accept(subtitle)
            memoModel
                .focusRelay
                .filter { $0 == .off(.endEditing) }
                .mapToVoid()
                .withLatestFrom(memoModel.textRelay)
                .distinctUntilChanged()
                .map { text in
                    (text: text, oldModel: memo)
                }
                .bind(to: memoUpdated)
                .disposed(by: disposeBag)
            memoModels.append(.textField(memoModel))
        }

        var checkboxModels: [DetailsScreen.CellType] = []
        if terms != nil, transferAgreement != nil {

            termsCheckboxViewModel
                .selectedRelay
                .distinctUntilChanged()
                .bind(to: termsUpdated)
                .disposed(by: disposeBag)

            termsCheckboxViewModel
                .tapRelay
                .asObservable()
                .bind(to: hyperlinkTapped)
                .disposed(by: disposeBag)

            transferCheckboxViewModel?
                .selectedRelay
                .distinctUntilChanged()
                .bind(to: transferAgreementUpdated)
                .disposed(by: disposeBag)

            checkboxModels.append(
                contentsOf: [
                    .checkbox(termsCheckboxViewModel),
                    .checkbox(transferCheckboxViewModel!)
                ]
            )

            if state.action == .activeRewardsDeposit {

                arDepositCheckboxViewModel = arDepositCheckboxViewModel ?? .init(
                    inputs: [
                        .text(string: LocalizationConstants.Transaction.Transfer.ToS.arDeposit.interpolating(state.source!.currencyType.displayCode))
                    ]
                )

                arDepositCheckboxViewModel
                    .selectedRelay
                    .distinctUntilChanged()
                    .bind(to: arAgreementUpdated)
                    .disposed(by: disposeBag)

                checkboxModels.append(.checkbox(arDepositCheckboxViewModel))
            }
        }

        var depositTermsModels: [DetailsScreen.CellType] = []
        if let depositACHTerms {
            let depositACHTermsViewModel = TermsViewCellModel(
                text: .init(string: depositACHTerms.formatted?.subtitle ?? ""),
                readMoreButtonTitle: depositACHTerms.readMoreButtonTitle,
                detailsDescription: depositACHTerms.detailsDesription
            )
            depositACHTermsViewModel
                .tapRelay
                .asObservable()
                .bind(to: showACHDepositTermsTapped)
                .disposed(by: disposeBag)
            depositTermsModels.append(
                contentsOf: [
                    .terms(depositACHTermsViewModel)
                ]
            )
        }

        var availableToWithdrawDateModels: [DetailsScreen.CellType] = []
        if let availableToWithdrawDate {
            let cellModel = LabelInfoViewCellModel(
                title: availableToWithdrawDate.formatted?.title,
                subtitle: availableToWithdrawDate.formatted?.subtitle,
                isInfoButtonVisible: true
            )
            cellModel
                .tapInfoRelay
                .asObservable()
                .bind(to: availableToWithdrawDateInfoTapped)
                .disposed(by: disposeBag)
            availableToWithdrawDateModels.append(
                contentsOf: [
                    .labelInfo(cellModel)
                ]
            )
        }

        let topCells: [DetailsScreen.CellType] = imageNoticeModels + noticeModels
        let midCells: [DetailsScreen.CellType] = bitpayItemIfNeeded
        + confirmationLineItems + memoModels + availableToWithdrawDateModels
        let bottomCells: [DetailsScreen.CellType] = errorModels + checkboxModels + depositTermsModels
        return topCells + [.separator] + midCells + bottomCells
    }

    func createHeader(state: TransactionState) -> HeaderBuilder? {
        guard let quoteExpirationTimer = state.pendingTransaction?.confirmations
            .first(where: { $0.isQuoteExpirationTimer }) as? TransactionConfirmations.QuoteExpirationTimer
        else {
            return nil
        }
        return ConfrimationQuoteRefreshHeaderBuilder(quoteExpirationTimer.expirationDate)
    }

    static func screenTitle(state: TransactionState) -> String {
        switch state.action {
        case .sign:
            return LocalizedString.Confirmation.signatureRequest
        case .send:
            return LocalizedString.Confirmation.sendRequest
        default:
            return LocalizedString.Confirmation.confirm
        }
    }

    static func confirmCtaText(state: TransactionState) -> String {
        switch state.action {
        case .swap:
            return LocalizedString.Swap.swapNow
        case .send:
            return LocalizedString.Confirmation.confirm
        case .buy:
            let paymentMethod = state.source as? PaymentMethodAccount
            let isApplePay = paymentMethod?.paymentMethodType.method.isApplePay ?? false
            return isApplePay ? LocalizedString.Swap.buyWithApplePay : LocalizedString.Swap.buyNow
        case .sell:
            return LocalizedString.Swap.sellNow
        case .sign:
            return LocalizedString.Confirmation.confirm
        case .deposit:
            return LocalizedString.Deposit.depositNow
        case .interestTransfer:
            return LocalizedString.Transfer.transferNow
        case .stakingDeposit, .activeRewardsDeposit:
            return LocalizedString.Deposit.depositNow
        case .withdraw,
             .interestWithdraw,
             .activeRewardsWithdraw:
            return LocalizedString.Withdraw.withdrawNow
        case .receive,
             .viewActivity:
            fatalError("ConfirmationPageContentReducer: \(state.action) not supported.")
        }
    }

    static func confirmCtaBackgroundColor(state: TransactionState) -> UIColor {
        guard case .buy = state.action,
              let paymentMethod = state.source as? PaymentMethodAccount,
              paymentMethod.paymentMethodType.method.isApplePay
        else {
            return .primaryButton
        }
        return .black
    }

    // MARK: - Private methods

    private func setupBitPay(on presenter: DefaultLineItemCellPresenter) {
        let bitPayLogo = UIImage(named: "bitpay-logo")

        presenter.imageWidthRelay.accept(bitPayLogo?.size.width ?? 0)
        presenter.imageRelay.accept(bitPayLogo)
    }
}

extension TransactionConfirmation {
    var isCustom: Bool {
        isQuoteExpirationTimer || isErrorNotice || isNotice || isMemo || isBitPay
        || isCheckbox || isDepositACHTerms || isAvailableToWithdrawDate
    }

    var isCheckbox: Bool {
        self is TransactionConfirmations.AnyBoolOption<Bool>
    }

    var isImageNotice: Bool {
        self is TransactionConfirmations.ImageNotice
    }

    var isQuoteExpirationTimer: Bool {
        self is TransactionConfirmations.QuoteExpirationTimer
    }

    var isBitPay: Bool {
        self is TransactionConfirmations.BitPayCountdown
    }

    var isNotice: Bool {
        self is TransactionConfirmations.Notice
    }

    var isErrorNotice: Bool {
        self is TransactionConfirmations.ErrorNotice
    }

    var isRequiredAgreement: Bool {
        isTermsOfService && isTransferAgreement
    }

    var isTermsOfService: Bool {
        (self as? TransactionConfirmations.AnyBoolOption<Bool>)?.type == .agreementInterestTandC
    }

    var isTransferAgreement: Bool {
        (self as? TransactionConfirmations.AnyBoolOption<Bool>)?.type == .agreementInterestTransfer
    }

    var isARAgreement: Bool {
        (self as? TransactionConfirmations.AnyBoolOption<Bool>)?.type == .agreementARDeposit
    }

    var isDepositACHTerms: Bool {
        (self as? TransactionConfirmations.DepositTerms)?.type == .depositACHTerms
    }

    var isAvailableToWithdrawDate: Bool {
        self is TransactionConfirmations.AvailableToWithdrawDate
    }

    var isMemo: Bool {
        self is TransactionConfirmations.Memo
    }
}
