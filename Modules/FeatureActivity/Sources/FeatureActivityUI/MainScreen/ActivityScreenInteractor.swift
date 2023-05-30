// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureActivityDomain
import MoneyKit
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift
import ToolKit

final class ActivityScreenInteractor {

    typealias State = ValueCalculationState<[ActivityItemInteractor]>

    // MARK: - Public Properties

    var fiatCurrency: Observable<FiatCurrency> {
        serviceContainer
            .fiatCurrency
            .displayCurrencyPublisher
            .asObservable()
    }

    var selectedData: Observable<BlockchainAccount> {
        serviceContainer.selectionService.selectedData
    }

    var activityBalance: Observable<FiatValue> {
        Observable
            .combineLatest(fiatCurrency, selectedData)
            .flatMap { (fiatCurrency: FiatCurrency, account: BlockchainAccount) in
                account.fiatBalance(fiatCurrency: fiatCurrency)
                    .asObservable()
                    .compactMap(\.fiatValue)
                    .catchAndReturn(.zero(currency: fiatCurrency))
            }
    }

    var state: Observable<State> {
        stateRelay
            .asObservable()
    }

    var isEmpty: Observable<Bool> {
        stateRelay
            .asObservable()
            .map { value in
                switch value {
                case .invalid(let error):
                    return error == .empty
                case .value(let values):
                    return values.isEmpty
                case .calculating:
                    return false
                }
            }
    }

    // MARK: - Private Properties

    private let refreshRelay: PublishRelay<Void> = .init()
    private let stateRelay = BehaviorRelay<State>(value: .invalid(.empty))
    private let serviceContainer: ActivityServiceContaining
    private let disposeBag = DisposeBag()

    init(serviceContainer: ActivityServiceContaining) {
        self.serviceContainer = serviceContainer

        NotificationCenter.default
            .publisher(for: .transaction)
            .mapToVoid()
            .asObservable()
            .delay(.seconds(2), scheduler: MainScheduler.instance)
            .bind(to: refreshRelay)
            .disposed(by: disposeBag)

        Observable
            .combineLatest(selectedData, refreshRelay.asObservable())
            .map(\.0)
            .flatMapLatest { account -> Observable<[ActivityItemEvent]> in
                if let group: AccountGroup = account as? AccountGroup {
                    return group
                        .activityStream
                        .throttle(
                            for: .milliseconds(250),
                            scheduler: DispatchQueue.global(qos: .userInitiated),
                            latest: true
                        )
                        .asObservable()
                }
                if let account: BlockchainAccountActivity = account as? BlockchainAccountActivity {
                    return account.activity.asObservable()
                }
                return Observable.just([])
            }
            .map { (items: [ActivityItemEvent]) in
                State(with: items, exchangeProviding: serviceContainer.exchangeProviding)
            }
            .startWith(.calculating)
            .catchAndReturn(.invalid(.empty))
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }

    func refresh() {
        refreshRelay.accept(())
    }
}

extension ActivityScreenInteractor.State {

    /// Initializer that receives the loading state and
    /// maps it to `self`
    fileprivate init(
        with items: [ActivityItemEvent],
        exchangeProviding: ExchangeProviding
    ) {
        let interactors: [ActivityItemInteractor] = items
            .filter { item in
                switch item {
                case .buySell(let item) where item.status == .expired:
                    return false
                case .buySell(let item):
                    return item.status != .pendingConfirmation && !item.paymentProcessorErrorOccurred
                case .interest(let item):
                    return item.type != .unknown
                default:
                    return true
                }
            }
            .sorted(by: >)
            .map { item in
                ActivityItemInteractor(
                    activityItemEvent: item,
                    pairExchangeService: exchangeProviding[item.inputAmount.currencyType]
                )
            }
        self = interactors.isEmpty ? .invalid(.empty) : .value(interactors)
    }
}
