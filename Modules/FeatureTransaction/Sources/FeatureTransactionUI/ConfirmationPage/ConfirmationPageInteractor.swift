// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import DIKit
import FeatureTransactionDomain
import PlatformKit
import PlatformUIKit
import RIBs
import RxCocoa
import RxSwift
import ToolKit

protocol ConfirmationPageInteractable: Interactable {
    var router: ConfirmationPageRouting? { get set }
    var listener: ConfirmationPageListener? { get set }
}

final class ConfirmationPageInteractor: PresentableInteractor<ConfirmationPagePresentable>,
    ConfirmationPageInteractable
{
    weak var router: ConfirmationPageRouting?
    weak var listener: ConfirmationPageListener?

    private let app: AppProtocol
    private let transactionModel: TransactionModel
    private let webViewRouter: WebViewRouterAPI

    init(
        app: AppProtocol = resolve(),
        presenter: ConfirmationPagePresentable,
        transactionModel: TransactionModel,
        webViewRouter: WebViewRouterAPI = resolve()
    ) {
        self.app = app
        self.transactionModel = transactionModel
        self.webViewRouter = webViewRouter
        super.init(presenter: presenter)
    }

    override func didBecomeActive() {
        super.didBecomeActive()

        transactionModel.process(action: .validateTransaction)

        let actionDriver: Driver<Action> = transactionModel
            .state
            .map { Action.load($0) }
            .asDriver(onErrorJustReturn: .empty)

        presenter.continueButtonTapped
            .throttle(.seconds(5), latest: false)
            .delay(.milliseconds(300))
            .asObservable()
            .subscribe(onNext: { [app, transactionModel] in
                transactionModel.process(action: .executeTransaction)
                app.post(event: blockchain.ux.transaction.checkout.confirmed)
            })
            .disposeOnDeactivate(interactor: self)

        presenter.connect(action: actionDriver)
            .drive(onNext: handle(effect:))
            .disposeOnDeactivate(interactor: self)
    }

    func handle(effect: Effects) {
        switch effect {
        case .none:
            break
        case .close:
            listener?.closeFlow()
        case .back:
            listener?.checkoutDidTapBack()
            app.post(event: blockchain.ux.transaction.checkout.article.plain.navigation.bar.button.back)
        case .toggleTermsOfServiceAgreement(let value):
            let model = TransactionConfirmations.AnyBoolOption<Bool>(
                value: value,
                type: .agreementInterestTandC
            )
            transactionModel.process(action: .modifyTransactionConfirmation(model))
        case .toggleHoldPeriodAgreement(let value):
            let model = TransactionConfirmations.AnyBoolOption<Bool>(
                value: value,
                type: .agreementInterestTransfer
            )
            transactionModel.process(action: .modifyTransactionConfirmation(model))
        case .tappedHyperlink(let titledLink):
            router?.showWebViewWithTitledLink(titledLink)
        case .showACHDepositTerms(let termsDescription):
            router?.showACHDepositTerms(termsDescription: termsDescription)
        case .showAvailableToWithdrawDateInfo:
            router?.showAvailableToWithdrawDateInfo()
        }
    }
}

extension ConfirmationPageInteractor {
    enum Action: Equatable {
        case empty
        case load(TransactionState)
    }

    enum Effects: Equatable {
        case none
        case close
        case back
        case tappedHyperlink(TitledLink)
        case toggleTermsOfServiceAgreement(Bool)
        case toggleHoldPeriodAgreement(Bool)
        case showACHDepositTerms(termsDescription: String)
        case showAvailableToWithdrawDateInfo
    }
}
