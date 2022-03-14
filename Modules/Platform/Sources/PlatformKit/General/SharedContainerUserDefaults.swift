// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift
import ToolKit

public final class SharedContainerUserDefaults: UserDefaults {

    // MARK: - Public Static

    public static let `default` = SharedContainerUserDefaults()

    // MARK: - Static

    static let name = String(describing: "group.rainydayapps.blockchain")

    // MARK: - Public Properties

    public let portfolioRelay = PublishSubject<Portfolio?>()

    // MARK: - Rx

    private var portfolioObservable: Observable<Portfolio?> {
        portfolioRelay
            .asObservable()
    }

    // MARK: - Setup

    private lazy var setup: Void = portfolioObservable
        .bindAndCatch(to: rx.rx_portfolio)
        .disposed(by: disposeBag)

    // MARK: - Types

    enum Keys: String {
        case portfolio
        case shouldSyncPortfolio
    }

    // MARK: - Private Properties

    private let disposeBag = DisposeBag()

    // MARK: - Init

    public convenience init() {
        self.init(suiteName: SharedContainerUserDefaults.name)!
        _ = setup
    }

    public var portfolioSyncEnabled: Observable<Bool> {
        rx.observe(Bool.self, Keys.shouldSyncPortfolio.rawValue)
            .map { value in
                value ?? false
            }
    }

    public var portfolio: Portfolio? {
        get {
            codable(Portfolio.self, forKey: Keys.portfolio.rawValue)
        }
        set {
            set(codable: newValue, forKey: Keys.portfolio.rawValue)
        }
    }

    public var shouldSyncPortfolio: Bool {
        get {
            bool(forKey: Keys.shouldSyncPortfolio.rawValue)
        }
        set {
            set(newValue, forKey: Keys.shouldSyncPortfolio.rawValue)
        }
    }

    public func reset() {
        shouldSyncPortfolio = false
    }
}

extension Reactive where Base: SharedContainerUserDefaults {
    public var portfolioSyncEnabled: Binder<Bool> {
        Binder(base) { container, payload in
            container.shouldSyncPortfolio = payload
        }
    }

    public var rx_portfolio: Binder<Portfolio?> {
        Binder(base) { container, payload in
            container.portfolio = payload
        }
    }
}
