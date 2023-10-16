// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Combine
import ComposableArchitecture
import DIKit
import Errors
import FeatureAccountPickerUI
import FeatureWithdrawalLocksUI
import Localization
import MoneyKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import SwiftUI
import ToolKit
import UIComponentsKit

class FeatureAccountPickerControllableAdapter: BaseScreenViewController {

    // MARK: - Private Properties

    fileprivate var disposeBag = DisposeBag()
    var shouldOverrideNavigationEffects: Bool = false

    fileprivate let modelSelectedRelay = PublishRelay<AccountPickerCellItem>()
    fileprivate let uxRelay = PublishRelay<UX.Dialog>()
    fileprivate let backButtonRelay = PublishRelay<Void>()
    fileprivate let closeButtonRelay = PublishRelay<Void>()
    private let searchRelay = PublishRelay<String?>()
    private let accountFilterRelay = PublishRelay<AccountType?>()
    fileprivate let sections = PassthroughSubject<[AccountPickerSection], Never>()
    fileprivate let header = PassthroughSubject<HeaderStyle, Error>()
    fileprivate let topMoversVisible = PassthroughSubject<Bool, Never>()

    lazy var onSegmentSelectionChanged: ((Tag) -> Void)? = { [app, accountFilterRelay] selection in
        // Account switcher to automatically filter based on some condition
        guard app.currentMode == .pkw else {
            return
        }
        let showTrading = selection == blockchain.ux.asset.account.swap.segment.filter.trading
        accountFilterRelay.accept(showTrading ? .trading : .nonCustodial)
    }

    fileprivate lazy var accountPicker = AccountPicker(
        app: DIKit.resolve(),
        rowSelected: { [weak self, modelSelectedRelay] (identifier: AnyHashable) -> Void in
            if let viewModel = self?.model(for: identifier) {
                modelSelectedRelay.accept(viewModel)
            }
        },
        uxSelected: { [uxRelay] ux in uxRelay.accept(ux) },
        backButtonTapped: { [backButtonRelay] in backButtonRelay.accept(()) },
        closeButtonTapped: { [closeButtonRelay] in closeButtonRelay.accept(()) },
        search: { [searchRelay] searchText in searchRelay.accept(searchText) },
        sections: { [sections] in sections.eraseToAnyPublisher() },
        updateSingleAccounts: { [weak self] ids in
            guard let self else { return .empty() }
            let presenters = Dictionary<AnyHashable, AccountPickerCellItem.Presenter?>(
                uniqueKeysWithValues: ids.map { ($0, self.presenter(for: $0)) }
            )
            let fiatCurrencyService: FiatCurrencyServiceAPI = DIKit.resolve()
            let publishers = presenters
                .compactMap { id, presenter
                    -> AnyPublisher<(AnyHashable, AccountPickerRow.SingleAccount.Balances), Error>? in

                    guard case .singleAccount(let item, _, _) = presenter else {
                        return nil
                    }
                    return fiatCurrencyService.displayCurrencyPublisher
                        .flatMap { fiatCurrency in
                            item.safeBalancePair(fiatCurrency: fiatCurrency)
                        }
                        .map { (balance: MoneyValue?, quote: MoneyValue?) in
                            AccountPickerRow.SingleAccount.Balances(
                                fiatBalance: quote?.displayString ?? "",
                                cryptoBalance: balance?.displayString ?? ""
                            )
                        }
                        .prepend(.loading)
                        .map { (id, $0) }
                        .eraseError()
                        .eraseToAnyPublisher()
                }

            return Publishers.MergeMany(publishers)
                .collect(publishers.count)
                .map { Dictionary($0) { _, rhs in rhs } } // Don't care which value we take, just no dupes
                .eraseToAnyPublisher()
        },
        updateAccountGroups: { [weak self] (ids: Set<AnyHashable>) -> AnyPublisher<[AnyHashable: AccountPickerRow.AccountGroup.Balances], Error> in
            guard let self else { return .empty() }
            let presenters = Dictionary<AnyHashable, AccountPickerCellItem.Presenter?>(
                uniqueKeysWithValues: ids.map { ($0, self.presenter(for: $0)) }
            )
            let fiatCurrencyService: FiatCurrencyServiceAPI = DIKit.resolve()
            let publishers = presenters
                .compactMap { id, presenter
                    -> AnyPublisher<(AnyHashable, AccountPickerRow.AccountGroup.Balances), Error>? in

                    guard case .accountGroup(let item) = presenter else {
                        return nil
                    }
                    return fiatCurrencyService.displayCurrencyPublisher
                        .flatMap { fiatCurrency in
                            item.safeBalancePair(fiatCurrency: fiatCurrency)
                        }
                        .map { (_: MoneyValue?, quote: MoneyValue?) in
                            guard let quote else {
                                return .loading
                            }
                            return AccountPickerRow.AccountGroup.Balances(
                                fiatBalance: quote.displayString,
                                currencyCode: quote.currency.code
                            )
                        }
                        .prepend(.loading)
                        .map { (id, $0) }
                        .eraseError()
                        .eraseToAnyPublisher()
                }

            return Publishers.MergeMany(publishers)
                .collect(publishers.count)
                .map { Dictionary($0) { _, rhs in rhs } } // Don't care which value we take, just no dupes.
                .eraseToAnyPublisher()
        },
        header: { [header] in header.eraseToAnyPublisher() },
        onSegmentSelectionChanged: onSegmentSelectionChanged
    )

    fileprivate var models: [AccountPickerSectionViewModel] = []

    let app: AppProtocol

    // MARK: - Lifecycle

    init(app: AppProtocol) {
        self.app = app
        super.init(nibName: nil, bundle: nil)

        let accountPickerView = AccountPickerView(
            accountPicker: accountPicker,
            badgeView: { [unowned self] identity in
                badgeView(for: identity)
            },
            descriptionView: { [unowned self] identity in
                descriptionView(for: identity)
            },
            iconView: { [unowned self] identity in
                iconView(for: identity)
            },
            multiBadgeView: { [unowned self] identity in
                multiBadgeView(for: identity)
            },
            withdrawalLocksView: { [unowned self] in
                withdrawalLocksView()
            }
        )
        .app(app)

        let child = UIHostingController(
            rootView: accountPickerView
        )
        addChild(child)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.semantic.light
        children.forEach { child in
            view.addSubview(child.view)
            child.view.fillSuperview(usesSafeAreaLayoutGuide: false)
            child.didMove(toParent: self)
        }
    }

    // MARK: - Methods

    override func navigationBarLeadingButtonPressed() {
        guard shouldOverrideNavigationEffects else {
            super.navigationBarLeadingButtonPressed()
            return
        }
        switch leadingButtonStyle {
        case .close:
            closeButtonRelay.accept(())
        case .back:
            backButtonRelay.accept(())
        default:
            super.navigationBarLeadingButtonPressed()
        }
    }

    override func navigationBarTrailingButtonPressed() {
        guard shouldOverrideNavigationEffects else {
            super.navigationBarTrailingButtonPressed()
            return
        }
        switch trailingButtonStyle {
        case .close:
            closeButtonRelay.accept(())
        default:
            super.navigationBarLeadingButtonPressed()
        }
    }

    // MARK: - View Functions

    func model(for identity: AnyHashable) -> AccountPickerCellItem? {
        models.lazy
            .flatMap(\.items)
            .first(where: { $0.identity == identity })
    }

    func presenter(for identity: AnyHashable) -> AccountPickerCellItem.Presenter? {
        model(for: identity)?
            .presenter
    }

    @ViewBuilder
    func badgeView(for identity: AnyHashable) -> some View {
        switch presenter(for: identity) {
        case .singleAccount(let account, _, _):
            BadgeImageViewRepresentable(
                viewModel: SingleAccountBadgeImageViewModel.badgeModel(account: account),
                size: 24
            )
        case .accountGroup:
            BadgeImageViewRepresentable(
                viewModel: {
                    let value: BadgeImageViewModel = .primary(
                        image: .local(name: "icon-wallet", bundle: .platformUIKit),
                        contentColor: .semantic.background,
                        cornerRadius: .none,
                        accessibilityIdSuffix: "walletBalance"
                    )
                    value.marginOffsetRelay.accept(0)
                    return value
                }(),
                size: 24
            )
        case .linkedBankAccount(let account, _):
            if let icon = account.data.icon {
                AsyncMedia(url: icon)
            } else {
                ImageLocation.local(name: "icon-bank", bundle: .platformUIKit).image
            }
        default:
            EmptyView()
        }
    }

    @ViewBuilder func descriptionView(for identity: AnyHashable) -> some View {
        let model = model(for: identity)
        let isTradingAccount = model?.account is CryptoTradingAccount
        let label = model?.account?.label ?? ""
        switch model?.presenter {
        case .singleAccount where !isTradingAccount && !label.isEmpty:
            Text(label)
                .typography(.paragraph1)
                .foregroundColor(.semantic.text)
                .scaledToFill()
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        default:
            EmptyView()
        }
    }

    @ViewBuilder
    func iconView(for identity: AnyHashable) -> some View {
        let model = model(for: identity)
        let isTradingAccount = model?.account is CryptoTradingAccount
        switch model?.presenter {
        case .singleAccount(let account, let action, _) where !isTradingAccount:
            let model = SingleAccountBadgeImageViewModel.iconModel(account: account, action: action)
            BadgeImageViewRepresentable(
                viewModel: model ?? .empty,
                size: 16
            )
        default:
            EmptyView()
        }
    }

    @ViewBuilder
    func multiBadgeView(for identity: AnyHashable) -> some View {
        switch presenter(for: identity) {
        case .linkedBankAccount(_, let presenter):
            MultiBadgeViewRepresentable(viewModel: presenter.model)
        case .singleAccount(_, _, let presenter):
            MultiBadgeViewRepresentable(viewModel: presenter.model)
        default:
            EmptyView()
        }
    }

    @ViewBuilder func withdrawalLocksView() -> some View {
        let store = Store<WithdrawalLocksState, WithdrawalLocksAction>(
            initialState: .init(),
            reducer: { WithdrawalLocksReducer { _ in } }
        )
        WithdrawalLocksView(store: store)
    }
}

extension FeatureAccountPickerControllableAdapter: AccountPickerViewControllable {

    // swiftlint:disable cyclomatic_complexity
    func connect(state: Driver<AccountPickerPresenter.State>) -> Driver<AccountPickerInteractor.Effects> {
        disposeBag = DisposeBag()

        let stateWait: Driver<AccountPickerPresenter.State> = rx.viewDidLoad
            .asDriver()
            .flatMap { _ in
                state
            }

        stateWait
            .map(\.navigationModel)
            .drive(weak: self) { (self, model) in
                if let model {
                    self.navigationController?.setNavigationBarHidden(false, animated: false)
                    self.titleViewStyle = model.titleViewStyle
                    self.set(
                        barStyle: model.barStyle,
                        leadingButtonStyle: model.leadingButton,
                        trailingButtonStyle: model.trailingButton
                    )
                } else {
                    self.navigationController?.setNavigationBarHidden(true, animated: false)
                }
            }
            .disposed(by: disposeBag)

        stateWait.map(\.headerModel)
            .drive(weak: self) { (self, headerType) in
                let header: HeaderStyle
                switch headerType {
                case .default(let model):
                    header = .normal(
                        title: model.title,
                        subtitle: model.subtitle,
                        image: model.imageContent.imageResource,
                        tableTitle: model.tableTitle,
                        searchable: model.searchable
                    )
                case .simple(let model):
                    header = .simple(
                        subtitle: model.subtitle,
                        searchable: model.searchable,
                        switchable: model.switchable,
                        switchTitle: model.switchTitle
                    )
                case .none:
                    header = .none
                }
                self.header.send(header)
            }
            .disposed(by: disposeBag)

        stateWait.map(\.sections)
            .drive(weak: self) { (self: FeatureAccountPickerControllableAdapter, sectionModels: [AccountPickerSectionViewModel]) in
                self.models = sectionModels
                var sections: [AccountPickerSection] = []
                let items = sectionModels.flatMap(\.items)

                let includesPaymentMethodAccount = items.contains { item -> Bool in
                    item.account is FiatAccount
                }

                let isDeposit: Bool? = try? self.app.state.get(blockchain.ux.transaction.id) == "deposit"

                let warnings = items.flatMap { item -> [UX.Dialog] in
                    let dialogs: [UX.Dialog?] = [
                        (isDeposit == nil || isDeposit == true) ? (item.account as? FiatAccountCapabilities)?.capabilities?.deposit?.ux : nil,
                        (isDeposit == nil || isDeposit == false) ? (item.account as? FiatAccountCapabilities)?.capabilities?.withdrawal?.ux : nil
                    ]
                    return dialogs.compacted().array
                }

                if includesPaymentMethodAccount, warnings.isNotEmpty {
                    sections.append(.warning(warnings))
                }

                sections.append(.accounts(items.map(\.row)))
                self.sections.send(sections)
            }
            .disposed(by: disposeBag)

        let modelSelected = modelSelectedRelay
            .compactMap(\.account)
            .map { AccountPickerInteractor.Effects.select($0) }
            .asDriver(onErrorJustReturn: .none)

        let buttonSelected = modelSelectedRelay
            .filter(\.isButton)
            .map { _ in AccountPickerInteractor.Effects.button }
            .asDriver(onErrorJustReturn: .none)

        let badgeSelected = uxRelay
            .map { AccountPickerInteractor.Effects.ux($0) }
            .asDriverCatchError()

        let backButtonEffect = backButtonRelay
            .map { AccountPickerInteractor.Effects.back }
            .asDriverCatchError()

        let closeButtonEffect = closeButtonRelay
            .map { AccountPickerInteractor.Effects.closed }
            .asDriverCatchError()

        let searchEffect = searchRelay
            .map { AccountPickerInteractor.Effects.filter($0) }
            .asDriverCatchError()

        let accountFilterEffect = accountFilterRelay
            .map { AccountPickerInteractor.Effects.accountFilter($0) }
            .asDriverCatchError()

        return .merge(
            modelSelected,
            badgeSelected,
            buttonSelected,
            backButtonEffect,
            closeButtonEffect,
            searchEffect,
            accountFilterEffect
        )
    }
}

extension AccountPickerCellItem {
    var row: AccountPickerRow {
        switch presenter {
        case .emptyState(let labelContent):
            let model = AccountPickerRow.Label(
                id: identity,
                text: labelContent.text
            )
            return .label(model)
        case .button(let viewModel):
            let model = AccountPickerRow.Button(
                id: identity,
                text: viewModel.textRelay.value
            )
            return .button(model)

        case .linkedBankAccount(let account, _):
            let model = AccountPickerRow.LinkedBankAccount(
                id: identity,
                title: account.label,
                description: LocalizationConstants.accountEndingIn + " \(account.accountNumber)",
                capabilities: .init(
                    canWithdrawal: account.data.capabilities?.withdrawal?.enabled,
                    canDeposit: account.data.capabilities?.deposit?.enabled
                )
            )
            return .linkedBankAccount(model)

        case .paymentMethodAccount(let account):
            let method = account.paymentMethodType
            let model = AccountPickerRow.PaymentMethod(
                id: identity,
                block: method.block,
                ux: method.ux,
                title: account.label,
                description: String(
                    format: LocalizationConstants.maxPurchaseArg,
                    method.balance.displayString
                ),
                badge: account.logoResource,
                badgeBackground: Color(account.logoBackgroundColor),
                capabilities: .init(
                    canWithdrawal: account.capabilities?.withdrawal?.enabled,
                    canDeposit: account.capabilities?.deposit?.enabled
                )
            )
            return .paymentMethodAccount(model)

        case .accountGroup(let account):
            let model = AccountPickerRow.AccountGroup(
                id: identity,
                title: account.label,
                description: LocalizationConstants.Dashboard.Portfolio.totalBalance
            )
            return .accountGroup(model)

        case .singleAccount(let account, _, _):
            let model = AccountPickerRow.SingleAccount(
                id: identity,
                currency: account.currencyType.code,
                title: account.currencyType.name,
                description: account.currencyType.isFiatCurrency
                    ? account.currencyType.displayCode
                    : account.label
            )
            return .singleAccount(model)

        case .withdrawalLocks:
            return .withdrawalLocks
        }
    }
}
