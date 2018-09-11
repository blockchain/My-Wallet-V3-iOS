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
        
        
        let demo = Trade.demo()
        let model = TradingPairView.confirmationModel(for: demo)
        tradingPairView.apply(model: model)
        

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
                pair: TradingPair(from: .ethereum,to: .bitcoinCash)!,
                fiatCurrency: "USD",
                fix: .base,
                volume: 0),
            inputsState: InputsState()
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

    func updateRateLabels(first: String, second: String, third: String) {

    }
}
