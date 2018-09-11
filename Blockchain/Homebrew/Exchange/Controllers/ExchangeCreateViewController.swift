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

        primaryAmountLabel.font = UIFont(name: Constants.FontNames.montserratRegular, size: Constants.FontSizes.Gigantic)
        primaryDecimalLabel.font = UIFont(name: Constants.FontNames.montserratRegular, size: Constants.FontSizes.Small)
        secondaryAmountLabel.font = UIFont(name: Constants.FontNames.montserratRegular, size: Constants.FontSizes.Huge)
    }

    fileprivate func dependenciesSetup() {
        // DEBUG - ideally add an .empty state for a blank/loading state for MarketsModel here.
        let interactor = ExchangeCreateInteractor(
            dependencies: dependencies,
            model: MarketsModel(
                pair: TradingPair(from: .bitcoin, to: .ethereum)!,
                fiatCurrency: "USD",
                fix: .base,
                volume: 0)
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

    func updateTradingPairViewValues(left: String, right: String) {

    }

    func updateRateLabels(first: String, second: String, third: String) {

    }
}
