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
    func onUseMinimumTapped()
    func onUseMaximumTapped()
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

    @IBAction func useMinimumButtonTapped(_ sender: Any) {
        delegate?.onUseMinimumTapped()
    }

    @IBAction func useMaximumButtonTapped(_ sender: Any) {
        delegate?.onUseMaximumTapped()
    }

    // MARK: Action enum
    enum Action {
        case createPayment
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
                pair: TradingPair(from: fromAccount.address.assetType, to: toAccount.address.assetType)!,
                fiatCurrency: "USD",
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
    
    func wigglePrimaryLabel() {
        primaryAmountLabel.wiggle()
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
    
    func updateAttributedPrimary(_ primary: NSAttributedString?, secondary: String?) {
        primaryAmountLabel.attributedText = primary
        secondaryAmountLabel.text = secondary
    }
    
    func ratesViewVisibility(_ visibility: Visibility, animated: Bool) {
        conversionRatesView.updateVisibility(visibility, animated: animated)
    }
    
    func keypadViewVisibility(_ visibility: Visibility, animated: Bool) {
        numberKeypadView.updateKeypadVisibility(visibility, animated: animated) { [weak self] in
            guard let this = self else { return }
            this.delegate?.onKeypadVisibilityUpdated(visibility, animated: animated)
        }
    }
    
    func exchangeButtonVisibility(_ visibility: Visibility, animated: Bool) {
        if animated == false {
            exchangeButton.alpha = visibility.defaultAlpha
            return
        }
        
        UIView.animate(
            withDuration: 0.2,
            delay: 0.0,
            options: .curveEaseIn,
            animations: {
                self.exchangeButton.alpha = visibility.defaultAlpha
        }, completion: nil)
    }
    
    func ratesChevronButtonVisibility(_ visibility: Visibility, animated: Bool) {
        if animated == false {
            hideRatesButton.alpha = visibility.defaultAlpha
            return
        }
        
        UIView.animate(
            withDuration: 0.2,
            delay: 0.0,
            options: .curveEaseIn,
            animations: {
                self.hideRatesButton.alpha = visibility.defaultAlpha
        }, completion: nil)
    }
    
    func conversionViewVisibility(_ visibility: Visibility, animated: Bool) {
        if animated == false {
            conversionView.alpha = visibility.defaultAlpha
            return
        }
        
        UIView.animate(
            withDuration: 0.2,
            delay: 0.0,
            options: .curveEaseIn,
            animations: {
                self.conversionView.alpha = visibility.defaultAlpha
        }, completion: nil)
    }

    func updateInputLabels(primary: String?, primaryDecimal: String?, secondary: String?) {
        primaryAmountLabel.text = primary
        secondaryAmountLabel.text = secondary
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
            transition: .none
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

    func updateRateLabels(first: String, second: String, third: String) {
        conversionRatesView.apply(
            baseToCounter: first,
            baseToFiat: second,
            counterToFiat: third
        )
    }

    func loadingVisibility(_ visibility: Visibility, action: ExchangeCreateViewController.Action) {
        if visibility == .visible {
            var loadingText: String?
            switch action {
            case .createPayment: loadingText = LocalizationConstants.Exchange.confirming
            }

            guard let text = loadingText else {
                Logger.shared.error("unknown ExchangeCreateViewController action")
                return
            }
            LoadingViewPresenter.shared.showBusyView(withLoadingText: text)
        } else {
            LoadingViewPresenter.shared.hideBusyView()
        }
    }

    func showSummary(orderTransaction: OrderTransaction, conversion: Conversion) {
        ExchangeCoordinator.shared.handle(event: .confirmExchange(orderTransaction: orderTransaction, conversion: conversion))
    }
}

// MARK: - TradingPairViewDelegate

extension ExchangeCreateViewController: TradingPairViewDelegate {
    func onLeftButtonTapped(_ view: TradingPairView, title: String) {
        assetAccountListPresenter.presentPicker(excludingAssetType: toAccount.address.assetType, for: .exchanging)
    }

    func onRightButtonTapped(_ view: TradingPairView, title: String) {
        assetAccountListPresenter.presentPicker(excludingAssetType: fromAccount.address.assetType, for: .receiving)
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
                switch action {
                case .exchanging:
                    self.fromAccount = account
                case .receiving:
                    self.toAccount = account
                }
                self.onTradingPairChanged()
            })
            actionSheetController.addAction(alertAction)
        }
        actionSheetController.addAction(
            UIAlertAction(title: LocalizationConstants.cancel, style: .cancel)
        )

        // Present picker
        present(actionSheetController, animated: true)
    }

    private func onTradingPairChanged() {
        guard let tradingPair = TradingPair(
            from: fromAccount.address.assetType,
            to: toAccount.address.assetType
        ) else {
            return
        }
        presenter.changeTradingPair(tradingPair: tradingPair)
    }
}
