//
//  ExchangeCreateViewController.swift
//  Blockchain
//
//  Created by kevinwu on 8/15/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol ExchangeCreateDelegate: NumberKeypadViewDelegate {
    func onViewLoaded()
    func onDisplayRatesTapped()
    func onHideRatesTapped()
    func onKeypadVisibilityUpdated(_ visibility: Visibility, animated: Bool)
    func onUseMinimumTapped(assetAccount: AssetAccount)
    func onUseMaximumTapped(assetAccount: AssetAccount)
    func onDisplayInputTypeTapped()
    func onExchangeButtonTapped()
}

class ExchangeCreateViewController: UIViewController {
    
    // MARK: Private Static Properties
    
    static let primaryFontName: String = Constants.FontNames.montserratMedium
    static let primaryFontSize: CGFloat = Constants.FontSizes.Huge
    static let secondaryFontName: String = Constants.FontNames.montserratMedium
    static let secondaryFontSize: CGFloat = Constants.FontSizes.MediumLarge

    // MARK: - IBOutlets

    @IBOutlet private var tradingPairView: TradingPairView!
    @IBOutlet private var numberKeypadView: NumberKeypadView!

    // Label to be updated when amount is being typed in
    @IBOutlet private var primaryAmountLabel: UILabel!

    // Amount being typed in converted to input crypto or input fiat
    @IBOutlet private var secondaryAmountLabel: UILabel!

    @IBOutlet private var hideRatesButton: UIButton!
    @IBOutlet private var conversionRatesView: ConversionRatesView!
    @IBOutlet private var useMinimumButton: UIButton!
    @IBOutlet private var useMaximumButton: UIButton!
    @IBOutlet private var conversionView: UIView!
    @IBOutlet private var exchangeButton: UIButton!
    
    enum PresentationUpdate {
        case wiggleInputLabels
        case wigglePrimaryLabel
        case updatePrimaryLabel(NSAttributedString?)
        case updateSecondaryLabel(String?)
        case updateRateLabels(first: String, second: String, third: String)
        case keypadVisibility(Visibility, animated: Bool)
        case conversionRatesView(Visibility, animated: Bool)
        case loadingIndicator(Visibility)
    }
    
    enum ViewUpdate: Update, CompletionEvent {
        case conversionView(Visibility)
        case exchangeButton(Visibility)
        case ratesChevron(Visibility)
    }
    
    enum TransitionUpdate: Transition, CompletionEvent {
        case secondaryLabel(String)
        case primaryLabelTextColor(UIColor)
        case secondaryLabelTextColor(UIColor)
    }

    // MARK: Public Properties

    weak var delegate: ExchangeCreateDelegate?

    // MARK: Private Properties

    fileprivate var presenter: ExchangeCreatePresenter!
    fileprivate var dependencies: ExchangeDependencies!
    fileprivate var assetAccountListPresenter: ExchangeAssetAccountListPresenter!
    fileprivate var fromAccount: AssetAccount!
    fileprivate var toAccount: AssetAccount!

    // MARK: Factory
    
    class func make(with dependencies: ExchangeDependencies) -> ExchangeCreateViewController {
        let controller = ExchangeCreateViewController.makeFromStoryboard()
        controller.dependencies = dependencies
        return controller
    }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        dependenciesSetup()
        viewsSetup()
        delegate?.onViewLoaded()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let navController = navigationController as? BCNavigationController {
            navController.applyLightAppearance()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        if let navController = navigationController as? BCNavigationController {
            navController.applyDarkAppearance()
        }
        super.viewWillDisappear(animated)
    }

    // MARK: Private

    private func viewsSetup() {
        [primaryAmountLabel, secondaryAmountLabel].forEach {
            $0?.textColor = UIColor.brandPrimary
        }

        useMinimumButton.setTitle(LocalizationConstants.Exchange.useMin, for: .normal)
        useMaximumButton.setTitle(LocalizationConstants.Exchange.useMax, for: .normal)
        [useMaximumButton, useMinimumButton, conversionView, hideRatesButton].forEach {
            addStyleToView($0)
        }

        tradingPairView.delegate = self
        exchangeButton.layer.cornerRadius = Constants.Measurements.buttonCornerRadius
    }

    fileprivate func dependenciesSetup() {
        fromAccount = dependencies.assetAccountRepository.defaultAccount(for: .bitcoin)
        toAccount = dependencies.assetAccountRepository.defaultAccount(for: .ethereum)

        // DEBUG - ideally add an .empty state for a blank/loading state for MarketsModel here.
        let interactor = ExchangeCreateInteractor(
            dependencies: dependencies,
            model: MarketsModel(
                marketPair: MarketPair(fromAccount: fromAccount, toAccount: toAccount),
                fiatCurrencyCode: BlockchainSettings.sharedAppInstance().fiatCurrencyCode ?? "USD",
                fiatCurrencySymbol: BlockchainSettings.sharedAppInstance().fiatCurrencySymbol ?? "$",
                fix: .base,
                volume: "0"
            )
        )
        assetAccountListPresenter = ExchangeAssetAccountListPresenter(view: self)
        numberKeypadView.delegate = self
        presenter = ExchangeCreatePresenter(interactor: interactor)
        presenter.interface = self
        interactor.output = presenter
        delegate = presenter
    }
    
    // MARK: - IBActions
    
    @IBAction func useMinimumButtonTapped(_ sender: Any) {
        delegate?.onUseMinimumTapped(assetAccount: fromAccount)
    }
    
    @IBAction func useMaximumButtonTapped(_ sender: Any) {
        delegate?.onUseMaximumTapped(assetAccount: fromAccount)
    }

    @IBAction private func ratesViewTapped(_ sender: UITapGestureRecognizer) {
        delegate?.onDisplayRatesTapped()
    }
    
    @IBAction private func rateButtonTapped(_ sender: UIButton) {
        delegate?.onDisplayRatesTapped()
    }
    
    @IBAction private func hideRatesButtonTapped(_ sender: UIButton) {
        delegate?.onHideRatesTapped()
    }
    
    @IBAction private func displayInputTypeTapped(_ sender: Any) {
        delegate?.onDisplayInputTypeTapped()
    }
    
    @IBAction private func exchangeButtonTapped(_ sender: Any) {
        delegate?.onExchangeButtonTapped()
    }
}

// MARK: - Styling
extension ExchangeCreateViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    private func addStyleToView(_ viewToEdit: UIView) {
        viewToEdit.layer.cornerRadius = 4.0
        viewToEdit.layer.borderWidth = 1.0
        viewToEdit.layer.borderColor = UIColor.brandPrimary.cgColor
    }
}

extension ExchangeCreateViewController: NumberKeypadViewDelegate {
    func onDelimiterTapped(value: String) {
        delegate?.onDelimiterTapped(value: value)
    }
    
    func onAddInputTapped(value: String) {
        delegate?.onAddInputTapped(value: value)
    }

    func onBackspaceTapped() {
        delegate?.onBackspaceTapped()
    }
}

extension ExchangeCreateViewController: ExchangeCreateInterface {
    
    func apply(presentationUpdates: [ExchangeCreateInterface.PresentationUpdate]) {
        presentationUpdates.forEach({ apply(presentationUpdate: $0) })
    }
    
    func apply(animatedUpdate: ExchangeCreateInterface.AnimatedUpdate) {
        animatedUpdate.animationType.perform { [weak self] in
            guard let this = self else { return }
            animatedUpdate.animations.forEach({ this.apply(update: $0) })
        }
    }
    
    func apply(viewUpdates: [ExchangeCreateInterface.ViewUpdate]) {
        viewUpdates.forEach({ apply(update: $0) })
    }
    
    func apply(transitionUpdates: [ExchangeCreateInterface.TransitionUpdate]) {
        transitionUpdates.forEach({ apply(transition: $0) })
    }
    
    func apply(transition: TransitionUpdate, completion: ((Bool) -> Void)? = nil) {
        switch transition {
        case .secondaryLabel(let value):
            secondaryAmountLabel.text = value
        case .secondaryLabelTextColor(let color):
            secondaryAmountLabel.textColor = color
        case .primaryLabelTextColor(let color):
            primaryAmountLabel.textColor = color
        }
    }
    
    func apply(update: ViewUpdate, completion: ((Bool) -> Void)? = nil) {
        switch update {
        case .conversionView(let visibility):
            conversionView.alpha = visibility.defaultAlpha
        case .exchangeButton(let visibility):
            exchangeButton.alpha = visibility.defaultAlpha
        case .ratesChevron(let visibility):
            hideRatesButton.alpha = visibility.defaultAlpha
        }
    }
    
    func apply(presentationUpdate: PresentationUpdate) {
        switch presentationUpdate {
        case .loadingIndicator(let visibility):
            switch visibility {
            case .visible:
                LoadingViewPresenter.shared.showBusyView(
                    withLoadingText: LocalizationConstants.Exchange.confirming
                )
            case .hidden:
                LoadingViewPresenter.shared.hideBusyView()
            }
        case .conversionRatesView(let visibility, animated: let animated):
            conversionRatesView.updateVisibility(visibility, animated: animated)
        case .keypadVisibility(let visibility, animated: let animated):
            numberKeypadView.updateKeypadVisibility(visibility, animated: animated) { [weak self] in
                guard let this = self else { return }
                this.delegate?.onKeypadVisibilityUpdated(visibility, animated: animated)
            }
        case .updatePrimaryLabel(let value):
            primaryAmountLabel.attributedText = value
        case .updateSecondaryLabel(let value):
            secondaryAmountLabel.text = value
        case .wiggleInputLabels:
            primaryAmountLabel.wiggle()
            secondaryAmountLabel.wiggle()
        case .wigglePrimaryLabel:
            primaryAmountLabel.wiggle()
        case .updateRateLabels(first: let first, second: let second, third: let third):
            conversionRatesView.apply(baseToCounter: first, baseToFiat: second, counterToFiat: third)
        }
    }

    func showError(type: ExchangeInputError, gestureReceiver: UIView) {
        let fromText = secondaryAmountLabel.text?.copy() as? String ?? ""
        var errorText: String?
        switch type {
        case .aboveTradingLimit: errorText = LocalizationConstants.Exchange.aboveTradingLimit
        case .belowTradingLimit: errorText = LocalizationConstants.Exchange.belowTradingLimit
        case .insufficientFunds: errorText = LocalizationConstants.Exchange.insufficientFunds
        }
        guard let intermediateText = errorText else { return }
        secondaryAmountLabel.animate(fromText: fromText, toIntermediateText: intermediateText, speed: 1, gestureReceiver: gestureReceiver)
    }
    
    func styleTemplate() -> ExchangeStyleTemplate {
        
        let primary = UIFont(
            name: ExchangeCreateViewController.primaryFontName,
            size: ExchangeCreateViewController.primaryFontSize
        ) ?? UIFont.systemFont(ofSize: 17.0)
        
        let secondary = UIFont(
            name: ExchangeCreateViewController.secondaryFontName,
            size: ExchangeCreateViewController.secondaryFontSize
        ) ?? UIFont.systemFont(ofSize: 17.0)
        
        return ExchangeStyleTemplate(
            primaryFont: primary,
            secondaryFont: secondary,
            textColor: .brandPrimary,
            pendingColor: UIColor.brandPrimary.withAlphaComponent(0.5)
        )
    }

    func updateTradingPairView(pair: TradingPair, fix: Fix) {
        let fromAsset = pair.from
        let toAsset = pair.to

        let isUsingBase = fix == .base || fix == .baseInFiat
        let leftVisibility: TradingPairView.ViewUpdate = .leftStatusVisibility(isUsingBase ? .visible : .hidden)
        let rightVisibility: TradingPairView.ViewUpdate = .rightStatusVisibility(isUsingBase ? .hidden : .visible)

        let transitionUpdate = TradingPairView.TradingTransitionUpdate(
            transitions: [
                .images(left: fromAsset.brandImage, right: toAsset.brandImage),
                .titles(left: "", right: "")
            ],
            transition: .crossFade(duration: 0.2)
        )

        let presentationUpdate = TradingPairView.TradingPresentationUpdate(
            animations: [
                .backgroundColors(left: fromAsset.brandColor, right: toAsset.brandColor),
                leftVisibility,
                rightVisibility,
                .statusTintColor(#colorLiteral(red: 0.01176470588, green: 0.662745098, blue: 0.4470588235, alpha: 1)),
                .swapTintColor(#colorLiteral(red: 0, green: 0.2901960784, blue: 0.4862745098, alpha: 1)),
                .titleColor(#colorLiteral(red: 0, green: 0.2901960784, blue: 0.4862745098, alpha: 1))
            ],
            animation: .none
        )
        let model = TradingPairView.Model(
            transitionUpdate: transitionUpdate,
            presentationUpdate: presentationUpdate
        )
        tradingPairView.apply(model: model)

        let exchangeButtonTitle = String(
            format: LocalizationConstants.Exchange.exchangeXForY,
            pair.from.symbol,
            pair.to.symbol
        )
        exchangeButton.setTitle(exchangeButtonTitle, for: .normal)
    }

    func updateTradingPairViewValues(left: String, right: String) {
        let transitionUpdate = TradingPairView.TradingTransitionUpdate(
            transitions: [.titles(left: left, right: right)],
            transition: .none
        )
        tradingPairView.apply(transitionUpdate: transitionUpdate)
    }
    
    func showSummary(orderTransaction: OrderTransaction, conversion: Conversion) {
        ExchangeCoordinator.shared.handle(event: .confirmExchange(orderTransaction: orderTransaction, conversion: conversion))
    }
}

// MARK: - TradingPairViewDelegate

extension ExchangeCreateViewController: TradingPairViewDelegate {
    func onLeftButtonTapped(_ view: TradingPairView, title: String) {
        assetAccountListPresenter.presentPicker(excludingAccount: fromAccount, for: .exchanging)
    }

    func onRightButtonTapped(_ view: TradingPairView, title: String) {
        assetAccountListPresenter.presentPicker(excludingAccount: toAccount, for: .receiving)
    }

    func onSwapButtonTapped(_ view: TradingPairView) {
        presenter.onToggleFixTapped()
    }
}

// MARK: - ExchangeAssetAccountListView

extension ExchangeCreateViewController: ExchangeAssetAccountListView {
    func showPicker(for assetAccounts: [AssetAccount], action: ExchangeAction) {
        let actionSheetController = UIAlertController(title: action.title, message: nil, preferredStyle: .actionSheet)

        // Insert actions
        assetAccounts.forEach { account in
            let alertAction = UIAlertAction(title: account.name, style: .default, handler: { [unowned self] _ in
                Logger.shared.debug("Selected account titled: '\(account.name)' of type: '\(account.address.assetType.symbol)'")
                
                /// Note: Users should not be able to exchange between
                /// accounts with the same assetType.
                switch action {
                case .exchanging:
                    if account.address.assetType == self.toAccount.address.assetType {
                        self.toAccount = self.fromAccount
                    }
                    
                    self.fromAccount = account
                case .receiving:
                    if account.address.assetType == self.fromAccount.address.assetType {
                        self.fromAccount = self.toAccount
                    }
                    self.toAccount = account
                }
                self.onTradingPairChanged()
            })
            actionSheetController.addAction(alertAction)
        }
        actionSheetController.addAction(
            UIAlertAction(title: LocalizationConstants.cancel, style: .cancel)
        )
        
        present(actionSheetController, animated: true)
    }

    private func onTradingPairChanged() {
        presenter.changeMarketPair(
            marketPair: MarketPair(
                fromAccount: fromAccount,
                toAccount: toAccount
            )
        )
    }
}
