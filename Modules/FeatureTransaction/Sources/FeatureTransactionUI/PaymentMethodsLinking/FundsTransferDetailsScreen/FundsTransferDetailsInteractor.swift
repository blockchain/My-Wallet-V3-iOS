// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import MoneyKit
import PlatformKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

public typealias FundsTransferDetailsInteractionState = ValueCalculationState<PaymentAccountDescribing>

public protocol FundsTransferDetailsInteractorAPI: AnyObject {
    var state: Observable<FundsTransferDetailsInteractionState> { get }
    var fiatCurrency: FiatCurrency { get }
}

public final class InteractiveFundsTransferDetailsInteractor: FundsTransferDetailsInteractorAPI {

    // MARK: - Properties

    public var state: Observable<FundsTransferDetailsInteractionState> {
        _ = setup
        return paymentAccountRelay.compactMap { $0 }
    }

    public let fiatCurrency: FiatCurrency

    private let paymentAccountService: PaymentAccountServiceAPI
    private let paymentAccountRelay = BehaviorRelay<FundsTransferDetailsInteractionState>(value: .invalid(.empty))
    private let disposeBag = DisposeBag()

    private lazy var setup: Void = paymentAccountService.paymentAccount(for: fiatCurrency)
        .asObservable()
        .map { .value($0) }
        .startWith(.calculating)
        .catchAndReturn(.invalid(.valueCouldNotBeCalculated))
        .bindAndCatch(to: paymentAccountRelay)
        .disposed(by: disposeBag)

    // MARK: - Setup

    public init(
        paymentAccountService: PaymentAccountServiceAPI = resolve(),
        fiatCurrency: FiatCurrency
    ) {
        self.paymentAccountService = paymentAccountService
        self.fiatCurrency = fiatCurrency
    }
}
