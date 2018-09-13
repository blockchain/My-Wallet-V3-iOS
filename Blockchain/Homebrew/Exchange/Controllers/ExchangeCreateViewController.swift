//
//  ExchangeCreateViewController.swift
//  Blockchain
//
//  Created by kevinwu on 8/15/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class ExchangeCreateViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet private var tradingPairView: TradingPairView!
    @IBOutlet private var numberKeypadView: NumberKeypadView!

    // Label to be updated when amount is being typed in
    @IBOutlet private var primaryAmountLabel: UILabel!

    // Amount being typed for fiat values to the right of the decimal separator
    @IBOutlet var primaryDecimalLabel: UILabel!
    @IBOutlet var decimalLabelSpacingConstraint: NSLayoutConstraint!

    // Amount being typed in converted to input crypto or input fiat
    @IBOutlet private var secondaryAmountLabel: UILabel!

    @IBOutlet private var useMinimumButton: UIButton!
    @IBOutlet private var useMaximumButton: UIButton!
    @IBOutlet private var exchangeRateView: UIView!
    @IBOutlet private var exchangeRateButton: UIButton!
    @IBOutlet private var exchangeButton: UIButton!
    // MARK: - IBActions

    @IBAction private func displayInputTypeTapped(_ sender: Any) {
        delegate?.onDisplayInputTypeTapped()
    }

    // MARK: Public Properties

    weak var delegate: ExchangeCreateDelegate?

    // MARK: Private Properties

    fileprivate var presenter: ExchangeCreatePresenter!
    fileprivate var dependencies: ExchangeDependencies!

    // MARK: Factory
    
    class func make(with dependencies: ExchangeDependencies) -> ExchangeCreateViewController {
        let controller = ExchangeCreateViewController.makeFromStoryboard()
        controller.dependencies = dependencies
        return controller
    }

    // MARK: Lifecycle

    override func viewDidLoad() {
        dependenciesSetup()
        delegate?.onViewLoaded()

        primaryAmountLabel.textColor = UIColor.brandPrimary
        primaryDecimalLabel.textColor = UIColor.brandPrimary
        secondaryAmountLabel.textColor = UIColor.brandPrimary
        
        useMaximumButton.layer.cornerRadius = 4.0
        useMaximumButton.layer.borderWidth = 1.0
        useMaximumButton.layer.borderColor = UIColor.brandPrimary.cgColor
        
        useMinimumButton.layer.cornerRadius = 4.0
        useMinimumButton.layer.borderWidth = 1.0
        useMinimumButton.layer.borderColor = UIColor.brandPrimary.cgColor
        
        exchangeButton.layer.cornerRadius = 4.0
        exchangeRateView.layer.cornerRadius = 4.0
        exchangeRateView.layer.borderWidth = 1.0
        exchangeRateView.layer.borderColor = UIColor.brandPrimary.cgColor

        primaryAmountLabel.font = UIFont(name: Constants.FontNames.montserratRegular, size: Constants.FontSizes.Huge)
        primaryDecimalLabel.font = UIFont(name: Constants.FontNames.montserratRegular, size: Constants.FontSizes.Small)
        secondaryAmountLabel.font = UIFont(name: Constants.FontNames.montserratRegular, size: Constants.FontSizes.MediumLarge)
        
        if let navController = navigationController as? BCNavigationController {
            navController.applyLightAppearance()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let navController = navigationController as? BCNavigationController {
            navController.applyDarkAppearance()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    fileprivate func dependenciesSetup() {
        // DEBUG - ideally add an .empty state for a blank/loading state for MarketsModel here.
        let interactor = ExchangeCreateInteractor(
            dependencies: dependencies,
            model: MarketsModel(
                pair: TradingPair(from: .bitcoin, to: .ethereum)!,
                fiatCurrency: "USD",
                fix: .base,
                volume: "0")
        )
        numberKeypadView.delegate = self
        presenter = ExchangeCreatePresenter(interactor: interactor)
        presenter.interface = self
        interactor.output = presenter
        delegate = presenter
    }
}

extension ExchangeCreateViewController: NumberKeypadViewDelegate {
    func onAddInputTapped(value: String) {
        delegate?.onAddInputTapped(value: value)
    }

    func onBackspaceTapped() {
        delegate?.onBackspaceTapped()
    }
}

extension ExchangeCreateViewController: ExchangeCreateInterface {

    func ratesViewVisibility(_ visibility: Visibility) {

    }

    func updateInputLabels(primary: String?, primaryDecimal: String?, secondary: String?) {
        primaryAmountLabel.text = primary
        primaryDecimalLabel.text = primaryDecimal
        decimalLabelSpacingConstraint.constant = primaryDecimal == nil ? 0 : 2
        secondaryAmountLabel.text = secondary
    }

    func updateTradingPairView(pair: TradingPair) {
        let fromAsset = pair.from
        let toAsset = pair.to

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
                .leftStatusVisibility(.hidden),
                .rightStatusVisibility(.hidden),
                .swapTintColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)),
                .titleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
            ],
            animation: .none
        )
        let model = TradingPairView.Model(
            transitionUpdate: transitionUpdate,
            presentationUpdate: presentationUpdate
        )
        tradingPairView.apply(model: model)
    }

    func updateTradingPairViewValues(left: String, right: String) {
        let transitionUpdate = TradingPairView.TradingTransitionUpdate(
            transitions: [.titles(left: left, right: right)],
            transition: .none
        )
        tradingPairView.apply(transitionUpdate: transitionUpdate)
    }

    func updateRateLabels(first: String, second: String, third: String) {

    }
}
