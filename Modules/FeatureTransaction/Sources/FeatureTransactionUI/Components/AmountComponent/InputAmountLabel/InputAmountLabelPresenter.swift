// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxRelay
import RxSwift

public final class InputAmountLabelPresenter {

    // MARK: - Properties

    public let interactor: InputAmountLabelInteractor
    public let presenter: AmountLabelViewPresenter

    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(
        interactor: InputAmountLabelInteractor,
        currencyCodeSide: AmountLabelViewPresenter.CurrencyCodeSide
    ) {
        self.presenter = .init(
            interactor: interactor.interactor,
            currencyCodeSide: currencyCodeSide
        )
        self.interactor = interactor

        interactor.scanner.input
            .bindAndCatch(to: presenter.inputRelay)
            .disposed(by: disposeBag)
    }
}
