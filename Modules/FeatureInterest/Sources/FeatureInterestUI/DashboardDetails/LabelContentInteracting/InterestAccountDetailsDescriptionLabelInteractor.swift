// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureInterestDomain
import Localization
import MoneyKit
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

final class InterestAccountDetailsDescriptionLabelInteractor {

    typealias InteractionState = LabelContent.State.Interaction
    typealias LocalizationId = LocalizationConstants.Interest.Screen.AccountDetails

    final class TotalInterest: LabelContentInteracting {

        private lazy var setup: Void = service
            .fetchInterestAccountDetailsForCryptoCurrency(cryptoCurrency)
            .asObservable()
            .map(\.value)
            .compactMap { $0?.totalInterest }
            .compactMap { CryptoValue.create(minor: $0, currency: self.cryptoCurrency) }
            .map(\.displayString)
            .map { .loaded(next: .init(text: $0)) }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)

        let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
        var state: Observable<InteractionState> {
            _ = setup
            return stateRelay.asObservable()
        }

        // MARK: - Private Properties

        private let service: InterestAccountServiceAPI
        private let cryptoCurrency: CryptoCurrency
        private let disposeBag = DisposeBag()

        // MARK: - Private Accessors

        init(
            service: InterestAccountServiceAPI,
            cryptoCurrency: CryptoCurrency
        ) {
            self.service = service
            self.cryptoCurrency = cryptoCurrency
        }
    }

    final class PendingDeposit: LabelContentInteracting {

        private lazy var setup: Void = service
            .fetchInterestAccountDetailsForCryptoCurrency(cryptoCurrency)
            .asObservable()
            .map(\.value)
            .compactMap { $0?.pendingInterest }
            .compactMap { CryptoValue.create(minor: $0, currency: self.cryptoCurrency) }
            .map(\.displayString)
            .map { .loaded(next: .init(text: $0)) }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)

        let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
        var state: Observable<InteractionState> {
            _ = setup
            return stateRelay.asObservable()
        }

        // MARK: - Private Properties

        private let service: InterestAccountServiceAPI
        private let cryptoCurrency: CryptoCurrency
        private let disposeBag = DisposeBag()

        // MARK: - Private Accessors

        init(
            service: InterestAccountServiceAPI,
            cryptoCurrency: CryptoCurrency
        ) {
            self.service = service
            self.cryptoCurrency = cryptoCurrency
        }
    }

    final class LockUpDuration: LabelContentInteracting {

        private lazy var setup: Void = service
            .fetchInterestAccountLimitsForCryptoCurrency(cryptoCurrency)
            .asObservable()
            .map(\.wrapped)
            .compactMap { $0?.lockupDescription }
            .map { .loaded(next: .init(text: $0)) }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)

        let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
        var state: Observable<InteractionState> {
            _ = setup
            return stateRelay.asObservable()
        }

        // MARK: - Private Properties

        private let service: InterestAccountServiceAPI
        private let cryptoCurrency: CryptoCurrency
        private let disposeBag = DisposeBag()

        // MARK: - Private Accessors

        init(
            service: InterestAccountServiceAPI,
            cryptoCurrency: CryptoCurrency
        ) {
            self.service = service
            self.cryptoCurrency = cryptoCurrency
        }
    }

    final class Rates: LabelContentInteracting {

        private lazy var setup: Void = service
            .rate(for: cryptoCurrency)
            .asObservable()
            .compactMap { "\($0)% \(LocalizationId.annually)" }
            .map { .loaded(next: .init(text: $0)) }
            .catchAndReturn(.loading)
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)

        let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
        var state: Observable<InteractionState> {
            _ = setup
            return stateRelay.asObservable()
        }

        // MARK: - Private Properties

        private let service: InterestAccountServiceAPI
        private let cryptoCurrency: CryptoCurrency
        private let disposeBag = DisposeBag()

        // MARK: - Private Accessors

        init(
            service: InterestAccountServiceAPI,
            cryptoCurrency: CryptoCurrency
        ) {
            self.service = service
            self.cryptoCurrency = cryptoCurrency
        }
    }

    final class NextPayment: LabelContentInteracting {

        private lazy var setup: Void = {
            var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
            components.day = 1
            let month = components.month ?? 0
            components.month = month + 1
            components.calendar = .current
            let next = components.date ?? Date()
            Observable.just(DateFormatter.long.string(from: next))
                .map { .loaded(next: .init(text: $0)) }
                .bindAndCatch(to: stateRelay)
                .disposed(by: disposeBag)
        }()

        let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
        var state: Observable<InteractionState> {
            _ = setup
            return stateRelay.asObservable()
        }

        // MARK: - Private Properties

        private let date: Date
        private let cryptoCurrency: CryptoCurrency
        private let disposeBag = DisposeBag()

        // MARK: - Private Accessors

        init(
            date: Date = Date(),
            cryptoCurrency: CryptoCurrency
        ) {
            self.date = date
            self.cryptoCurrency = cryptoCurrency
        }
    }
}
