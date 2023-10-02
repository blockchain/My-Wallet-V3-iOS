// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import MoneyKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import ToolKit

final class SendAuxiliaryViewInteractor {

    private let contentLabelViewInteractor = ContentLabelViewInteractor()
    private let networkLabelViewInteractor = ContentLabelViewInteractor()

    let resetToMaxAmountRelay = PublishRelay<Void>()
    let networkFeeTappedRelay = PublishRelay<Void>()
    let availableBalanceTappedRelay = PublishRelay<Void>()
    let imageRelay = PublishRelay<ImageViewContent>()

    var networkFeeContentViewInteractor: ContentLabelViewInteractorAPI {
        networkLabelViewInteractor
    }

    var availableBalanceContentViewInteractor: ContentLabelViewInteractorAPI {
        contentLabelViewInteractor
    }

    func connect(stream: Observable<MoneyValue>) -> Disposable {
        stream
            .map(\.displayString)
            .map { ValueCalculationState.value($0) }
            .bindAndCatch(to: contentLabelViewInteractor.stateSubject)
    }

    func connect(fee: Observable<MoneyValue>) -> Disposable {
        fee
            .map(\.displayString)
            .map { ValueCalculationState.value($0) }
            .bindAndCatch(to: networkLabelViewInteractor.stateSubject)
    }

    /// Streams reset to max events
    var resetToMaxAmount: Observable<Void> {
        resetToMaxAmountRelay
            .asObservable()
    }

    /// Streams network fee tap events
    var networkFeeTapped: Observable<Void> {
        networkFeeTappedRelay
            .asObservable()
    }

    var availableBalanceTapped: Observable<Void> {
        availableBalanceTappedRelay
            .asObservable()
    }
}

final class ContentLabelViewInteractor: ContentLabelViewInteractorAPI {

    var contentCalculationState: Observable<ValueCalculationState<String>> {
        stateSubject.asObservable()
    }

    let stateSubject: BehaviorSubject<ValueCalculationState<String>> = .init(value: .calculating)
}
