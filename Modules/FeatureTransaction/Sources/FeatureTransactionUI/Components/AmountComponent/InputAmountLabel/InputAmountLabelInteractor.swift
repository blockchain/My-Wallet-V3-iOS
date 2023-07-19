// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import PlatformKit
import RxCocoa
import RxRelay
import RxSwift

public final class InputAmountLabelInteractor {

    // MARK: - Properties

    public let scanner: MoneyValueInputScanner
    public let interactor: AmountLabelViewInteractor

    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(currency: Currency, integralPlacesLimit: Int = 10) {
        self.scanner = MoneyValueInputScanner(
            maxDigits: .init(integral: integralPlacesLimit, fractional: currency.displayPrecision)
        )
        self.interactor = AmountLabelViewInteractor(currency: currency)

        interactor.currency
            .map { .init(integral: integralPlacesLimit, fractional: $0.displayPrecision) }
            .bindAndCatch(to: scanner.maxDigitsRelay)
            .disposed(by: disposeBag)
    }
}
