// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import Localization
import MoneyKit
import PlatformKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

final class AddNewBankAccountPagePresenter: DetailsScreenPresenterAPI, AddNewBankAccountPresentable {

    // MARK: - Types

    private typealias AnalyticsEvent = AnalyticsEvents.SimpleBuy
    private typealias LocalizedString = LocalizationConstants.SimpleBuy.TransferDetails
    private typealias AccessibilityId = Accessibility.Identifier.SimpleBuy.TransferDetails

    // MARK: - Navigation Properties

    let reloadRelay: PublishRelay<Void> = .init()

    let navigationBarTrailingButtonAction: DetailsScreen.BarButtonAction
    let navigationBarLeadingButtonAction: DetailsScreen.BarButtonAction = .default

    let titleViewRelay: BehaviorRelay<Screen.Style.TitleView> = .init(value: .none)

    var navigationBarAppearance: DetailsScreen.NavigationBarAppearance {
        .custom(
            leading: .none,
            trailing: .close,
            barStyle: .darkContent(ignoresStatusBar: false, background: .white)
        )
    }

    // MARK: - Screen Properties

    private(set) var buttons: [ButtonViewModel] = []
    private(set) var cells: [DetailsScreen.CellType] = []

    // MARK: - Private Properties

    private let disposeBag = DisposeBag()
    private let termsTapRelay = PublishRelay<TitledLink>()
    private let navigationCloseRelay = PublishRelay<Void>()

    // MARK: - Injected

    private let fiatCurrency: FiatCurrency
    private let isOriginDeposit: Bool
    private let analyticsRecorder: AnalyticsEventRecorderAPI

    // MARK: - Setup

    init(
        isOriginDeposit: Bool,
        fiatCurrency: FiatCurrency,
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve()
    ) {
        self.isOriginDeposit = isOriginDeposit
        self.fiatCurrency = fiatCurrency
        self.analyticsRecorder = analyticsRecorder

        self.navigationBarTrailingButtonAction = .custom { [navigationCloseRelay] in
            navigationCloseRelay.accept(())
        }
    }

    func connect(action: Driver<AddNewBankAccountAction>) -> Driver<AddNewBankAccountEffects> {
        let details = action
            .flatMap { action -> Driver<AddNewBankAccountDetailsInteractionState> in
                switch action {
                case .details(let state):
                    return .just(state)
                }
            }

        details
            .drive(weak: self) { (self, state) in
                switch state {
                case .invalid(.valueCouldNotBeCalculated):
                    self.analyticsRecorder.record(
                        event: AnalyticsEvents.SimpleBuy.sbLinkBankLoadingError(
                            currencyCode: self.fiatCurrency.code
                        )
                    )
                case .value(let account):
                    self.setup(account: account)
                case .calculating, .invalid(.empty), .invalid(.ux):
                    break
                }
            }
            .disposed(by: disposeBag)

        let closeTapped = navigationCloseRelay
            .map { _ in AddNewBankAccountEffects.close }
            .asDriverCatchError()

        let termsTapped = termsTapRelay
            .map(AddNewBankAccountEffects.termsTapped)
            .asDriverCatchError()

        return Driver.merge(closeTapped, termsTapped)
    }

    func viewDidLoad() {
        analyticsRecorder.record(
            event: AnalyticsEvents.SimpleBuy.sbLinkBankScreenShown(currencyCode: fiatCurrency.code)
        )
    }

    private func setup(account: PaymentAccountDescribing) {
        let contentReducer = ContentReducer(
            account: account,
            isOriginDeposit: isOriginDeposit,
            analyticsRecorder: analyticsRecorder
        )

        // MARK: Nav Bar

        titleViewRelay.accept(.text(value: contentReducer.title))

        // MARK: Cells Setup

        contentReducer.lineItems
            .forEach { cells.append(.lineItem($0)) }
        cells.append(.separator)
        for noticeViewModel in contentReducer.noticeViewModels {
            cells.append(.notice(noticeViewModel))
        }

        if let termsTextViewModel = contentReducer.termsTextViewModel {
            termsTextViewModel.tap
                .bindAndCatch(to: termsTapRelay)
                .disposed(by: disposeBag)
            cells.append(.interactableTextCell(termsTextViewModel))
        }

        reloadRelay.accept(())
    }
}

// MARK: - Content Reducer

extension AddNewBankAccountPagePresenter {

    final class ContentReducer {

        let title: String
        let lineItems: [LineItemCellPresenting]
        let noticeViewModels: [NoticeViewModel]
        let termsTextViewModel: InteractableTextViewModel!

        init(
            account: PaymentAccountDescribing,
            isOriginDeposit: Bool,
            analyticsRecorder: AnalyticsEventRecorderAPI
        ) {

            typealias FundsString = LocalizedString.Funds

            if isOriginDeposit {
                self.title = "\(FundsString.Title.depositPrefix) \(account.currency)"
            } else {
                self.title = "\(FundsString.Title.addBankPrefix) \(account.currency) \(FundsString.Title.addBankSuffix) "
            }

            self.lineItems = account.fields.transferDetailsCellsPresenting(analyticsRecorder: analyticsRecorder)

            let font = UIFont.main(.medium, 12)

            let processingTimeNoticeDescription: String

            switch account.currency {
            case .ARS:
                processingTimeNoticeDescription = FundsString.Notice.ProcessingTime.Description.ARS
                self.termsTextViewModel = InteractableTextViewModel(
                    inputs: [
                        .text(string: FundsString.Notice.recipientNameARS)
                    ],
                    textStyle: .init(color: .descriptionText, font: font),
                    linkStyle: .init(color: .linkableText, font: font)
                )
            case .BRL:
                processingTimeNoticeDescription = FundsString.Notice.ProcessingTime.Description.BRL
                self.termsTextViewModel = InteractableTextViewModel(
                    inputs: [
                        .text(string: FundsString.Notice.recipientNameBRL)
                    ],
                    textStyle: .init(color: .descriptionText, font: font),
                    linkStyle: .init(color: .linkableText, font: font)
                )
            case .USD:
                processingTimeNoticeDescription = FundsString.Notice.ProcessingTime.Description.USD
                self.termsTextViewModel = InteractableTextViewModel(
                    inputs: [
                        .text(string: FundsString.Notice.recipientNameUSD)
                    ],
                    textStyle: .init(color: .descriptionText, font: font),
                    linkStyle: .init(color: .linkableText, font: font)
                )
            case .GBP:
                processingTimeNoticeDescription = FundsString.Notice.ProcessingTime.Description.GBP
                self.termsTextViewModel = InteractableTextViewModel(
                    inputs: [
                        .text(string: FundsString.Notice.recipientNameGBPPrefix),
                        .url(string: " \(FundsString.Notice.termsAndConditions) ", url: TermsUrlLink.gbp),
                        .text(string: FundsString.Notice.recipientNameGBPSuffix)
                    ],
                    textStyle: .init(color: .descriptionText, font: font),
                    linkStyle: .init(color: .linkableText, font: font)
                )
            case .EUR:
                processingTimeNoticeDescription = FundsString.Notice.ProcessingTime.Description.EUR
                self.termsTextViewModel = InteractableTextViewModel(
                    inputs: [.text(string: FundsString.Notice.recipientNameEUR)],
                    textStyle: .init(color: .descriptionText, font: font),
                    linkStyle: .init(color: .linkableText, font: font)
                )
            default:
                processingTimeNoticeDescription = ""
                self.termsTextViewModel = nil
            }

            let amount = MoneyValue.one(currency: account.currency)
            let instructions = String(
                format: FundsString.Notice.Instructions.description,
                amount.displayString,
                account.currency.displayCode
            )

            self.noticeViewModels = [
                (
                    title: FundsString.Notice.Instructions.title,
                    description: instructions,
                    image: ImageResource.local(name: "Icon-Info", bundle: .platformUIKit)
                ),
                (
                    title: FundsString.Notice.BankTransferOnly.title,
                    description: FundsString.Notice.BankTransferOnly.description,
                    image: ImageResource.local(name: "icon-bank", bundle: .platformUIKit)
                ),
                (
                    title: FundsString.Notice.ProcessingTime.title,
                    description: processingTimeNoticeDescription,
                    image: ImageResource.local(name: "clock-icon", bundle: .platformUIKit)
                )
            ]
            .map {
                NoticeViewModel(
                    imageViewContent: ImageViewContent(
                        imageResource: $0.image,
                        renderingMode: .template(.titleText)
                    ),
                    labelContents: [
                        LabelContent(
                            text: $0.title,
                            font: .main(.semibold, 12),
                            color: .titleText
                        ),
                        LabelContent(
                            text: $0.description,
                            font: .main(.medium, 12),
                            color: .descriptionText
                        )
                    ],
                    verticalAlignment: .top
                )
            }
        }
    }
}

extension [PaymentAccountProperty.Field] {
    private typealias AccessibilityId = Accessibility.Identifier.SimpleBuy.TransferDetails

    fileprivate func transferDetailsCellsPresenting(analyticsRecorder: AnalyticsEventRecorderAPI) -> [LineItemCellPresenting] {

        func isCopyable(field: TransactionalLineItem) -> Bool {
            switch field {
            case .paymentAccountField(.accountNumber),
                 .paymentAccountField(.iban),
                 .paymentAccountField(.bankCode),
                 .paymentAccountField(.sortCode):
                return true
            case .paymentAccountField(.field(name: _, value: _, help: _, copy: let copy)):
                return copy
            default:
                return false
            }
        }

        func analyticsEvent(field: TransactionalLineItem) -> AnalyticsEvents.SimpleBuy? {
            switch field {
            case .paymentAccountField:
                return .sbLinkBankDetailsCopied
            default:
                return nil
            }
        }

        return map { TransactionalLineItem.paymentAccountField($0) }
            .map { field in
                if isCopyable(field: field) {
                    return field.defaultCopyablePresenter(
                        analyticsEvent: analyticsEvent(field: field),
                        analyticsRecorder: analyticsRecorder,
                        accessibilityIdPrefix: AccessibilityId.lineItemPrefix
                    )
                } else {
                    return field.defaultPresenter(accessibilityIdPrefix: AccessibilityId.lineItemPrefix)
                }
            }
    }
}
