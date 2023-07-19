// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import PlatformKit
import RxRelay
import RxSwift
import ToolKit

public final class AmountLabelViewInteractor {

    var currency: Observable<Currency> {
        currencyRelay
            .asObservable()
            .distinctUntilChanged { $0.code == $1.code }
            .subscribe(on: MainScheduler.asyncInstance)
    }

    // MARK: - Injected

    public let currencyRelay: BehaviorRelay<Currency>
    public let stateRelay = BehaviorRelay<ValidationState>(value: .valid)

    /// Streams the state of the view model
    public var state: Observable<ValidationState> {
        stateRelay.asObservable()
    }

    public init(currency: Currency) {
        self.currencyRelay = BehaviorRelay(value: currency)
    }
}
