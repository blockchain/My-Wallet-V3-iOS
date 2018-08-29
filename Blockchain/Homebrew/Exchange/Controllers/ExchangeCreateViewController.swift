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

    // Label to be updated when amount is being typed in
    @IBOutlet var primaryAmountLabel: UILabel!
    // Amount being typed in converted to input crypto or input fiat
    @IBOutlet var secondaryAmountLabel: UILabel!
    @IBOutlet var useMinimumButton: UIButton!
    @IBOutlet var useMaximumButton: UIButton!
    @IBOutlet var exchangeRateButton: UIButton!
    @IBOutlet var exchangeButton: UIButton!
    // MARK: - IBActions

    @IBAction func fiatToggleTapped(_ sender: Any) {
        delegate?.onFiatToggleTapped()
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
    }

    fileprivate func dependenciesSetup() {
        let interactor = ExchangeCreateInteractor(dependencies: dependencies)
        presenter = ExchangeCreatePresenter(interactor: interactor)
        presenter.interface = self
        interactor.output = presenter
        delegate = presenter
    }
}

extension ExchangeCreateViewController: ExchangeCreateInterface {
    func expandRatesView() {
        
    }

    func updateInputLabels(primary: String, secondary: String) {

    }

    func updateRates(first: String, second: String, third: String) {

    }
}
