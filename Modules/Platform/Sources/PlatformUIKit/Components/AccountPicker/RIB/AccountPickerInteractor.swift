// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DIKit
import Errors
import MoneyKit
import PlatformKit
import RIBs
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

public protocol AccountPickerRouting: ViewableRouting {
    // Declare methods the interactor can invoke to manage sub-tree via the router.
}

public final class AccountPickerInteractor: PresentableInteractor<AccountPickerPresentable>, AccountPickerInteractable {

    // MARK: - Properties

    weak var router: AccountPickerRouting?

    // MARK: - Private Properties

    private let searchRelay: PublishRelay<String?> = .init()
    private let accountFilterRelay: PublishRelay<AccountType?> = .init()

    private let accountProvider: AccountPickerAccountProviding
    private let didSelect: AccountPickerDidSelect?
    private let disposeBag = DisposeBag()
    private weak var listener: AccountPickerListener?

    private let app: AppProtocol
    private let initialAccountTypeFilter: AccountType?
    private let eligiblePaymentService: PaymentMethodsServiceAPI

    // MARK: - Init

    init(
        presenter: AccountPickerPresentable,
        accountProvider: AccountPickerAccountProviding,
        listener: AccountPickerListenerBridge,
        app: AppProtocol = resolve(),
        initialAccountTypeFilter: AccountType?,
        eligiblePaymentService: PaymentMethodsServiceAPI = resolve()
    ) {
        self.app = app
        self.accountProvider = accountProvider
        self.initialAccountTypeFilter = initialAccountTypeFilter
        self.eligiblePaymentService = eligiblePaymentService
        switch listener {
        case .simple(let didSelect):
            self.didSelect = didSelect
            self.listener = nil
        case .listener(let listener):
            self.didSelect = nil
            self.listener = listener
        }
        super.init(presenter: presenter)
    }

    // MARK: - Methods

    override public func didBecomeActive() {
        super.didBecomeActive()

        let button = presenter.button
        if let button {
            button.tapRelay
                .bind { [weak self] in
                    guard let self else { return }
                    handle(effects: .button)
                }
                .disposeOnDeactivate(interactor: self)
        }

        let searchObservable = searchRelay.asObservable()
            .startWith(nil)
            .distinctUntilChanged()
            .debounce(.milliseconds(350), scheduler: MainScheduler.asyncInstance)

        let accountFilterObservable = accountFilterRelay.asObservable()
            .startWith(initialAccountTypeFilter)
            .distinctUntilChanged()

        let interactorState: Driver<State> = Observable
            .combineLatest(
                accountProvider.accounts.flatMap { [app] accounts in
                    accounts.snapshot(app: app).asObservable()
                },
                searchObservable,
                accountFilterObservable,
                eligiblePaymentService.paymentMethods.asObservable()
            )
            .map { [app, button] accounts, searchString, accountFilter, paymentMethods -> State in
                let isFiltering = searchString
                    .flatMap { !$0.isEmpty } ?? false

                var interactors = accounts
                    .filter { snapshot in
                        snapshot.account.currencyType.matchSearch(searchString)
                    }
                    .filter { snapshot in
                        guard let filter = accountFilter else {
                            return true
                        }
                        return snapshot.account.accountType == filter
                    }
                    .sorted(by: >)
                    .map(\.account)
                    .map(\.accountPickerCellItemInteractor)

                if interactors.isEmpty {
                    interactors.append(.emptyState)
                }

                let action = try app.state.get(blockchain.ux.transaction.id, as: AssetAction.self)

                if
                    paymentMethods.isNotEmpty,
                    let button,
                    paymentMethods.contains(where: { method in action != .withdraw || method.capabilities?.contains(.withdrawal) != false })
                {
                    interactors.append(.button(button))
                }

                return State(
                    isFiltering: isFiltering,
                    interactors: interactors
                )
            }
            .asDriver(onErrorJustReturn: .empty)

        presenter
            .connect(state: interactorState)
            .drive(onNext: handle(effects:))
            .disposeOnDeactivate(interactor: self)
    }

    // MARK: - Private methods

    private func handle(effects: Effects) {
        switch effects {
        case .select(let account):
            didSelect?(account)
            listener?.didSelect(blockchainAccount: account)
        case .back:
            listener?.didTapBack()
        case .closed:
            listener?.didTapClose()
        case .filter(let string):
            searchRelay.accept(string)
        case .accountFilter(let filter):
            accountFilterRelay.accept(filter)
        case .button:
            listener?.didSelectActionButton()
        case .ux(let ux):
            listener?.didSelect(ux: ux)
        case .none:
            break
        }
    }
}

extension AccountPickerInteractor {
    public struct State {
        static let empty = State(isFiltering: false, interactors: [])
        let isFiltering: Bool
        let interactors: [AccountPickerCellItem.Interactor]
    }

    public enum Effects {
        case select(BlockchainAccount)
        case back
        case closed
        case ux(UX.Dialog)
        case filter(String?)
        case accountFilter(AccountType?)
        case button
        case none
    }
}

extension BlockchainAccount {

    fileprivate var accountPickerCellItemInteractor: AccountPickerCellItem.Interactor {
        switch self {
        case is PaymentMethodAccount:
            return .paymentMethodAccount(self as! PaymentMethodAccount)

        case is LinkedBankAccount:
            let account = self as! LinkedBankAccount
            return .linkedBankAccount(account)

        case is SingleAccount:
            let singleAccount = self as! SingleAccount
            return .singleAccount(singleAccount, AccountAssetBalanceViewInteractor(account: singleAccount))

        case is AccountGroup:
            let accountGroup = self as! AccountGroup
            return .accountGroup(
                accountGroup,
                AccountGroupBalanceCellInteractor(
                    balanceViewInteractor: WalletBalanceViewInteractor(account: accountGroup)
                )
            )

        default:
            impossible()
        }
    }
}

struct BlockchainAccountSnapshot: Comparable {

    let account: BlockchainAccount
    let balance: FiatValue
    let count: Int
    let isSelectedAsset: Bool
    let volume24h: BigInt

    static func == (lhs: BlockchainAccountSnapshot, rhs: BlockchainAccountSnapshot) -> Bool {
        lhs.account.identifier == rhs.account.identifier
            && lhs.balance == rhs.balance
            && lhs.count == rhs.count
            && lhs.volume24h == rhs.volume24h
            && lhs.isSelectedAsset == rhs.isSelectedAsset
    }

    static func < (lhs: BlockchainAccountSnapshot, rhs: BlockchainAccountSnapshot) -> Bool {
        (
            lhs.isSelectedAsset ? 1 : 0,
            lhs.count,
            lhs.balance.minorAmount,
            lhs.account.currencyType == .bitcoin ? 1 : 0,
            lhs.volume24h
        ) < (
            rhs.isSelectedAsset ? 1 : 0,
            rhs.count,
            rhs.balance.minorAmount,
            rhs.account.currencyType == .bitcoin ? 1 : 0,
            rhs.volume24h
        )
    }
}

extension BlockchainAccount {

    var empty: (snapshot: BlockchainAccountSnapshot, Void) {
        (
            snapshot: BlockchainAccountSnapshot(
                account: self,
                balance: .zero(currency: .USD),
                count: 0,
                isSelectedAsset: false,
                volume24h: 0
            ), ()
        )
    }
}

private enum BlockchainAccountSnapshotError: Error {
    case isNotEnabled
    case noTradingCurrency
}

extension Collection<BlockchainAccount> {

    func snapshot(
        app: AppProtocol
    ) -> AnyPublisher<[BlockchainAccountSnapshot], Never> {
        Task<[BlockchainAccountSnapshot], Error>.Publisher {
            guard try await app.get(blockchain.ux.transaction.smart.sort.order.is.enabled) else {
                throw BlockchainAccountSnapshotError.isNotEnabled
            }
            guard let currency: FiatCurrency = try await app.get(
                blockchain.user.currency.preferred.fiat.display.currency
            ) else {
                throw BlockchainAccountSnapshotError.noTradingCurrency
            }

            let usdPrices = try await Dictionary<String, L_blockchain_api_nabu_gateway_price_type.JSON?>(
                uniqueKeysWithValues:
                    map { account in
                        app.publisher(
                            for: blockchain.api.nabu.gateway.price.at.time["yesterday"].crypto[account.currencyType.code].fiat["USD"],
                            as: L_blockchain_api_nabu_gateway_price_type.JSON.self
                        )
                        .map { result in
                            (account.identifier, result.value)
                        }
                    }
                    .combineLatest()
                    .stream()
                    .next()
            )

            var accounts = [BlockchainAccountSnapshot]()
            for account in self {
                let currencyCode = account.currencyType.code
                let count: Int? = try? await app.get(
                    blockchain.ux.transaction.source.target[currencyCode].count.of.completed
                )
                let currentId: String? = try? await app.get(
                    blockchain.ux.transaction.source.target.id
                )
                let balance = try? await account.fiatBalance(fiatCurrency: currency)
                    .stream()
                    .next()
                let volume24h: BigInt? = usdPrices[account.identifier].flatMap { currency -> BigInt? in
                    guard let currency else { return nil }
                    return try? currency.quote.value.amount(BigInt.self) * BigInt(currency.volume(Double?.self).or(.zero))
                }
                let isSelectedAsset: Bool? = currentId.flatMap { currentId in
                    currentId.caseInsensitiveCompare(currencyCode) == .orderedSame
                }
                accounts.append(
                    BlockchainAccountSnapshot(
                        account: account,
                        balance: balance?.fiatValue ?? .zero(currency: currency),
                        count: count ?? 0,
                        isSelectedAsset: isSelectedAsset ?? false,
                        volume24h: volume24h ?? .zero
                    )
                )
            }
            return accounts
        }
        .replaceError(with: map(\.empty.snapshot))
        .eraseToAnyPublisher()
    }
}
