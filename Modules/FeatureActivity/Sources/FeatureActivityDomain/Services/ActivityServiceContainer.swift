// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxRelay
import RxSwift
import ToolKit

public protocol ActivityServiceContaining {
    var exchangeProviding: ExchangeProviding { get }
    var fiatCurrency: FiatCurrencySettingsServiceAPI { get }
    var selectionService: WalletPickerSelectionServiceAPI { get }
}

final class ActivityServiceContainer: ActivityServiceContaining {
    let fiatCurrency: FiatCurrencySettingsServiceAPI
    let selectionService: WalletPickerSelectionServiceAPI
    let exchangeProviding: ExchangeProviding

    private let disposeBag = DisposeBag()
    private lazy var setup: Void = selectionService
        .selectedData
        .bind { [weak self] selection in
            self?.selectionService.record(selection: selection)
        }
        .disposed(by: disposeBag)

    init(
        fiatCurrency: FiatCurrencySettingsServiceAPI = resolve(),
        exchangeProviding: ExchangeProviding = resolve()
    ) {
        selectionService = WalletPickerSelectionService()
        self.fiatCurrency = fiatCurrency
        self.exchangeProviding = exchangeProviding
    }
}
