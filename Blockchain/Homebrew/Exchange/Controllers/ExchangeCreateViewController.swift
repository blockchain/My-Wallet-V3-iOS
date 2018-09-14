//
//  ExchangeCreateViewController.swift
//  Blockchain
//
//  Created by kevinwu on 8/15/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class ExchangeCreateViewController: UIViewController {
    
    // MARK: Private Static Properties
    
    static let primaryFontName: String = Constants.FontNames.montserratRegular
    static let primaryFontSize: CGFloat = Constants.FontSizes.Huge
    static let secondaryFontName: String = Constants.FontNames.montserratRegular
    static let secondaryFontSize: CGFloat = Constants.FontSizes.SmallMedium

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
        
        [primaryAmountLabel, secondaryAmountLabel].forEach {
            $0?.textColor = UIColor.brandPrimary
        }

        [useMaximumButton, useMinimumButton, exchangeRateView].forEach {
            addStyleToView($0)
        }
        
        exchangeButton.layer.cornerRadius = 4.0

        primaryAmountLabel.font = UIFont(name: Constants.FontNames.montserratRegular, size: Constants.FontSizes.Huge)
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
    
    func ratesViewVisibility(_ visibility: Visibility) {

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
