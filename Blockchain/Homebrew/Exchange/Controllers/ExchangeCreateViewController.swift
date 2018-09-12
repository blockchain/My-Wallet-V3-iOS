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

        // Debug code - will be removed in later PR
        let demo = Trade.demo()
        let model = TradingPairView.confirmationModel(for: demo)
        tradingPairView.apply(model: model)
        // End debug code

        [primaryAmountLabel, primaryDecimalLabel, secondaryAmountLabel].forEach {
            $0?.textColor = UIColor.brandPrimary
        }

        [useMaximumButton, useMinimumButton, exchangeRateView].forEach {
            addStyleToView($0)
        }

        exchangeButton.layer.cornerRadius = 4.0

        setAmountLabelFont(label: primaryAmountLabel, size: Constants.FontSizes.Huge)
        setAmountLabelFont(label: primaryDecimalLabel, size: Constants.FontSizes.Small)
        setAmountLabelFont(label: secondaryAmountLabel, size: Constants.FontSizes.MediumLarge)

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

    private func setAmountLabelFont(label: UILabel, size: CGFloat) {
        label.font = UIFont(name: Constants.FontNames.montserratRegular, size: size)
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
