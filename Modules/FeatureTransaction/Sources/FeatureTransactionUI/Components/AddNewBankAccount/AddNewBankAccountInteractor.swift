// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import MoneyKit
import PlatformKit
import PlatformUIKit
import RIBs
import RxCocoa
import RxSwift
import ToolKit

typealias AddNewBankAccountDetailsInteractionState = ValueCalculationState<PaymentAccountDescribing>

enum AddNewBankAccountAction {
    case details(AddNewBankAccountDetailsInteractionState)
}

public enum AddNewBankAccountEffects {
    case termsTapped(TitledLink)
    case close
}

public protocol AddNewBankAccountRouting: AnyObject {
    func showTermsScreen(link: TitledLink)
}

public protocol AddNewBankAccountListener: AnyObject {
    func dismissAddNewBankAccount()
}

protocol AddNewBankAccountPresentable: Presentable {
    func connect(action: Driver<AddNewBankAccountAction>) -> Driver<AddNewBankAccountEffects>
}

final class AddNewBankAccountInteractor: PresentableInteractor<AddNewBankAccountPresentable>,
    AddNewBankAccountInteractable
{

    weak var router: AddNewBankAccountRouting?
    weak var listener: AddNewBankAccountListener?

    private let fiatCurrency: FiatCurrency
    private let paymentAccountService: PaymentAccountServiceAPI

    init(
        presenter: AddNewBankAccountPresentable,
        fiatCurrency: FiatCurrency,
        paymentAccountService: PaymentAccountServiceAPI = resolve()
    ) {
        self.fiatCurrency = fiatCurrency
        self.paymentAccountService = paymentAccountService
        super.init(presenter: presenter)
    }

    override func didBecomeActive() {
        super.didBecomeActive()

        let detailsAction = paymentAccountService
            .paymentAccount(for: fiatCurrency)
            .asObservable()
            .map { AddNewBankAccountDetailsInteractionState.value($0) }
            .startWith(.calculating)
            .asDriver(onErrorJustReturn: .invalid(.valueCouldNotBeCalculated))
            .map(AddNewBankAccountAction.details)

        presenter.connect(action: detailsAction)
            .drive(onNext: handle(effect:))
            .disposeOnDeactivate(interactor: self)
    }

    func handle(effect: AddNewBankAccountEffects) {
        switch effect {
        case .close:
            listener?.dismissAddNewBankAccount()
        case .termsTapped(let link):
            router?.showTermsScreen(link: link)
        }
    }
}
