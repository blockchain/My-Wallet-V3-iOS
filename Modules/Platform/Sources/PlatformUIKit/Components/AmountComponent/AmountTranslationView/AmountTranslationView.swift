// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import PlatformKit
import RxCocoa
import RxRelay
import RxSwift
import SwiftUI
import ToolKit
import UIComponentsKit
import UIKit
import UIKitExtensions

public final class AmountTranslationView: UIView, AmountViewable {

    public var view: UIView {
        self
    }

    // MARK: - Properties

    private let app: AppProtocol
    private let fiatAmountLabelView = AmountLabelView()
    private let labelsContainerView = UIView()
    private let cryptoAmountLabelView = AmountLabelView()
    private let auxiliaryButton = ButtonView()
    private let swapButton: UIButton = {
        var swapButton = UIButton()
        swapButton.layer.borderWidth = 1
        swapButton.layer.cornerRadius = 20
        swapButton.layer.borderColor = UIColor.mediumBorder.cgColor
        swapButton.setImage(UIImage(named: "vertical-swap-icon", in: .platformUIKit, with: nil), for: .normal)
        return swapButton
    }()

    private let availableBalanceViewController: UIViewController?
    private let prefillViewController: UIViewController?
    private let recurringBuyFrequencySelector: UIViewController?
    private let presenter: AmountTranslationPresenter

    private let disposeBag = DisposeBag()

    private lazy var quickPriceViewController: UIViewController = UIHostingController(rootView: QuickPriceView().app(app))

    // MARK: - Init

    @available(*, unavailable)
    public required init?(coder: NSCoder) { unimplemented() }

    /// Init
    /// - Parameters:
    ///   - presenter: AmountTranslationPresenter
    ///   - app: AppProtocol
    ///   - prefillButtonsEnabled: Whether or not to show the prefill buttons
    ///   - shouldShowAvailableBalanceView: Whether or not to show the available balance view. This should
    ///  match `prefillButtonsEnabled` except for `Buy` in which case we don't want to show this.
    public init(
        presenter: AmountTranslationPresenter,
        app: AppProtocol,
        prefillButtonsEnabled: Bool = false,
        shouldShowAvailableBalanceView: Bool = false,
        shouldShowRecurringBuyFrequency: Bool = false
    ) {
        self.app = app
        self.presenter = presenter
        self.availableBalanceViewController = shouldShowAvailableBalanceView ? UIHostingController(
            rootView: AvailableBalanceView(
                store: .init(
                    initialState: .init(),
                    reducer: availableBalanceViewReducer,
                    environment: AvailableBalanceViewEnvironment(
                        app: app,
                        balancePublisher: presenter.interactor.accountBalancePublisher,
                        availableBalancePublisher: presenter.maxLimitPublisher,
                        feesPublisher: presenter.interactor.transactionFeePublisher,
                        transactionIsFeeLessPublisher: presenter.interactor.transactionIsFeeLessPublisher,
                        onViewTapped: {
                            presenter.interactor.availableBalanceViewTapped()
                        }
                    )
                )
            )
        ) : nil
        self.prefillViewController = prefillButtonsEnabled ? UIHostingController(
            rootView: PrefillButtonsView(
                store: .init(
                    initialState: .init(),
                    reducer: prefillButtonsReducer,
                    environment: PrefillButtonsEnvironment(
                        app: app,
                        lastPurchasePublisher: presenter.lastPurchasePublisher,
                        maxLimitPublisher: presenter.maxLimitPublisher,
                        onValueSelected: { [app, weak presenter] prefillMoneyValue, size in
                            guard let presenter else { return }
                            switch size {
                            case .max:
                                app.post(event: blockchain.ux.transaction.enter.amount.quick.fill.max)
                            default:
                                app.post(
                                    value: prefillMoneyValue,
                                    of: blockchain.ux.transaction.enter.amount.quick.fill.amount[size].value
                                )
                                presenter.interactor.set(amount: prefillMoneyValue.moneyValue)
                            }
                        }
                    )
                )
            )
        ) : nil

        self.recurringBuyFrequencySelector = shouldShowRecurringBuyFrequency ? UIHostingController(
            rootView: RecurringBuyButton(
                store: .init(
                    initialState: .init(),
                    reducer: recurringBuyButtonReducer,
                    environment: .init(
                        app: app,
                        recurringBuyButtonTapped: {
                            presenter.interactor.recurringBuyButtonTapped()
                        }
                    )
                ),
                trailingView: { Icon.chevronDown.color(.semantic.title) }
            )
            .app(app)
        ) : nil

        availableBalanceViewController?.view.backgroundColor = .background
        recurringBuyFrequencySelector?.view.backgroundColor = .background
        prefillViewController?.view.backgroundColor = .background

        super.init(frame: UIScreen.main.bounds)

        let stack = UIStackView(arrangedSubviews: [fiatAmountLabelView, quickPriceViewController.view])
        quickPriceViewController.view.backgroundColor = .clear
        stack.axis = .vertical
        labelsContainerView.addSubview(stack)
        stack.fillSuperview()

        labelsContainerView.addSubview(cryptoAmountLabelView)
        cryptoAmountLabelView.fillSuperview()

        fiatAmountLabelView.presenter = presenter.fiatPresenter.presenter
        cryptoAmountLabelView.presenter = presenter.cryptoPresenter.presenter

        swapButton.layout(size: .init(edge: 40))
        // a view to offset the swap button on the leading size, so that the inner stack view looks centered.
        let offsetView = UIView()
        offsetView.layout(size: .init(edge: 40))

        let innerStackView = UIStackView(arrangedSubviews: [offsetView, labelsContainerView, swapButton])
        innerStackView.axis = .horizontal
        innerStackView.alignment = .center
        innerStackView.spacing = Spacing.standard

        let contentStackView = UIStackView(arrangedSubviews: [innerStackView, auxiliaryButton])
        contentStackView.axis = .vertical
        contentStackView.alignment = .center
        contentStackView.spacing = Spacing.standard

        innerStackView.constraint(axis: .horizontal, to: contentStackView)

        // used to center the content
        let outerStackView = UIStackView(arrangedSubviews: [contentStackView])
        outerStackView.axis = .horizontal
        outerStackView.alignment = .center

        let prefillViewHeight: CGFloat = 42
        addSubview(outerStackView)
        outerStackView.layoutToSuperview(.leading, offset: Spacing.outer)
        outerStackView.layoutToSuperview(.trailing, offset: -Spacing.outer)
        outerStackView.layoutToSuperview(.top)
        outerStackView.layoutToSuperview(
            .bottom,
            offset: prefillButtonsEnabled ? -prefillViewHeight : -Spacing.standard
        )

        labelsContainerView.maximizeResistanceAndHuggingPriorities()

        auxiliaryButton.layoutToSuperview(.leading, relation: .greaterThanOrEqual)
        auxiliaryButton.layoutToSuperview(.trailing, relation: .lessThanOrEqual)

        if let availableBalanceView = availableBalanceViewController?.view {
            addSubview(availableBalanceView)
            availableBalanceView.layoutToSuperview(.top, .leading, .trailing)
            availableBalanceView.heightAnchor.constraint(equalToConstant: 40).isActive = true
            availableBalanceViewController?.willMove(toParent: nil)
        }
        if let prefillView = prefillViewController?.view {
            addSubview(prefillView)
            prefillView.layoutToSuperview(.bottom, .leading, .trailing)
            prefillView.heightAnchor.constraint(equalToConstant: prefillViewHeight).isActive = true
            prefillViewController?.willMove(toParent: nil)
        }
        if let recurringBuyButtonView = recurringBuyFrequencySelector?.view {
            addSubview(recurringBuyButtonView)
            recurringBuyButtonView.heightAnchor.constraint(equalToConstant: 40).isActive = true
            if let prefillView = prefillViewController?.view {
                recurringBuyButtonView.layoutToSuperview(.leading, .trailing)
                recurringBuyButtonView.layout(edge: .bottom, to: .top, of: prefillView, offset: -8.0)
            } else {
                recurringBuyButtonView.layoutToSuperview(.leading, .trailing, .bottom)
            }
            recurringBuyFrequencySelector?.willMove(toParent: nil)
        }

        presenter.swapButtonVisibility
            .drive(swapButton.rx.visibility)
            .disposed(by: disposeBag)

        swapButton.rx.tap
            .bindAndCatch(to: presenter.swapButtonTapRelay)
            .disposed(by: disposeBag)

        presenter.activeAmountInput
            .drive(
                onNext: { [weak self] input in
                    self?.didChangeActiveInput(to: input)
                }
            )
            .disposed(by: disposeBag)
    }

    override public func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow.isNil {
            quickPriceViewController.willMove(toParent: nil)
        } else {
            responderViewController?.addChild(quickPriceViewController)
        }
    }

    override public func didMoveToWindow() {
        super.didMoveToWindow()
        if window.isNil {
            quickPriceViewController.didMove(toParent: nil)
        } else {
            quickPriceViewController.didMove(toParent: responderViewController)
        }
    }

    // MARK: - Public Methods

    public func connect(input: Driver<AmountPresenterInput>) -> Driver<AmountPresenterState> {
        Driver.combineLatest(
            presenter.connect(input: input),
            presenter.activeAmountInput,
            presenter.auxiliaryButtonEnabled
        )
        .map { (state: $0.0, activeAmountInput: $0.1, auxiliaryEnabled: $0.2) }
        .map { [weak self] value in
            guard let self else { return .validInput(nil) }
            return self.performEffect(
                state: value.state,
                activeAmountInput: value.activeAmountInput,
                auxiliaryButtonEnabled: value.auxiliaryEnabled
            )
        }
    }

    // MARK: - Private Methods

    private func performEffect(
        state: AmountPresenterState,
        activeAmountInput: ActiveAmountInput,
        auxiliaryButtonEnabled: Bool
    ) -> AmountPresenterState {
        let textColor: UIColor
        switch state {
        case .validInput(let viewModel):
            textColor = .validInput
            auxiliaryButton.viewModel = viewModel
        case .invalidInput(let viewModel):
            textColor = .invalidInput
            auxiliaryButton.viewModel = viewModel
        }

        let shouldShowAuxiliaryButton = auxiliaryButtonEnabled && auxiliaryButton.viewModel != nil
        auxiliaryButton.isHidden = !shouldShowAuxiliaryButton
        fiatAmountLabelView.textColor = textColor
        cryptoAmountLabelView.textColor = textColor

        return state
    }

    private func didChangeActiveInput(to newInput: ActiveAmountInput) {
        app.state.set(blockchain.ux.transaction.enter.amount.active.input, to: newInput.tag)
        let to = newInput == .crypto ? cryptoAmountLabelView : fiatAmountLabelView
        let from = to == cryptoAmountLabelView ? fiatAmountLabelView : cryptoAmountLabelView
        UIView.animateKeyframes(
            withDuration: 0.3,
            delay: 0.0,
            options: [.calculationModeCubic, .beginFromCurrentState],
            animations: {
                UIView.addKeyframe(
                    withRelativeStartTime: 0.0,
                    relativeDuration: 0.15,
                    animations: {
                        from.alpha = 0.0
                    }
                )
                UIView.addKeyframe(
                    withRelativeStartTime: 0.10,
                    relativeDuration: 0.2,
                    animations: {
                        to.alpha = 1.0
                    }
                )
            },
            completion: nil
        )
    }
}

extension ActiveAmountInput {

    var tag: Tag {
        switch self {
        case .crypto:
            return blockchain.ux.transaction.enter.amount.active.input.crypto[]
        case .fiat:
            return blockchain.ux.transaction.enter.amount.active.input.fiat[]
        }
    }
}

import MoneyKit

struct QuickPriceView: View {

    @BlockchainApp var app

    @State private var exchangeRate: MoneyValuePair?
    @State private var input: MoneyValue?

    @State private var activeInput: Tag = blockchain.ux.transaction.enter.amount.active.input.fiat[]

    private var price: MoneyValue? {
        guard let input, input.isPositive, let exchangeRate, exchangeRate.base.isPositive else { return nil }
        switch activeInput {
        case blockchain.ux.transaction.enter.amount.active.input.crypto:
            return try? input.isFiat ? input : input.convert(using: exchangeRate)
        case blockchain.ux.transaction.enter.amount.active.input.fiat:
            return try? input.isFiat ? input.convert(using: exchangeRate.inverseExchangeRate) : input
        default:
            return nil
        }
    }

    struct Price: Decodable, Equatable {
        let pair: String
        let amount, result: String
    }

    var body: some View {
        Group {
            if let price {
                Text("~" + price.displayString)
                    .typography(.caption1)
                    .foregroundColor(.semantic.body)
            }
        }
        .padding(.top, 8.pt)
        .task {
            for await value in app.stream(blockchain.ux.transaction.source.target.quote.price, as: Price.self) {
                do {
                    let quote = try value.get()
                    let pair = quote.pair.splitIfNotEmpty(separator: "-")
                    let (source, destination) = try (
                        (pair.first?.string).decode(Either<CryptoCurrency, FiatCurrency>.self),
                        (pair.last?.string).decode(Either<CryptoCurrency, FiatCurrency>.self)
                    )
                    let amount = try MoneyValue.create(minor: quote.amount, currency: source.currencyType).or(throw: "No amount")
                    let result = try MoneyValue.create(minor: quote.result, currency: destination.currencyType).or(throw: "No result")
                    let exchangeRate = try await MoneyValuePair(base: amount, quote: result).toFiat(in: app)
                    withAnimation {
                        input = amount
                        self.exchangeRate = exchangeRate
                    }
                } catch {
                    input = nil
                    exchangeRate = nil
                }
            }
        }
        .binding(
            .subscribe($activeInput, to: blockchain.ux.transaction.enter.amount.active.input)
        )
    }
}

extension Either where A: Currency, B: Currency {
    var currencyType: CurrencyType {
        switch self {
        case .left(let a): return a.currencyType
        case .right(let b): return b.currencyType
        }
    }
}

extension MoneyValuePair {

    func toFiat(in app: AppProtocol) async throws -> MoneyValuePair {
        if quote.isFiat {
            return exchangeRate
        } else if base.isFiat {
            return MoneyValuePair(base: quote, quote: base).exchangeRate
        } else {
            return try await MoneyValuePair(
                base: .one(currency: base.currency),
                exchangeRate: app.get(blockchain.api.nabu.gateway.price.crypto[base.currency.code].fiat.quote.value)
            )
        }
    }
}
