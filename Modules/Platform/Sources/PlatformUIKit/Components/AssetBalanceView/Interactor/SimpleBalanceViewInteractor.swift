// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxRelay
import RxSwift

public final class SimpleBalanceViewInteractor: AssetBalanceViewInteracting {

    public typealias InteractionState = AssetBalanceViewModel.State.Interaction

    public var state: Observable<InteractionState> {
        .just(
            .loaded(next: .init(
                fiatValue: fiatValue,
                cryptoValue: cryptoValue,
                pendingValue: nil
            ))
        )
    }

    // MARK: - Private Accessors

    private let fiatValue: MoneyValue
    private let cryptoValue: MoneyValue?

    // MARK: - Setup

    public init(
        fiatValue: MoneyValue,
        cryptoValue: MoneyValue?
    ) {
        self.fiatValue = fiatValue
        self.cryptoValue = cryptoValue
    }

    public func refresh() {}
}