//
//  KYCCountrySelectionController.swift
//  Blockchain
//
//  Created by Maurice A. on 7/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import UIKit

/// Country selection screen in KYC flow
final class KYCCountrySelectionController: KYCBaseViewController, ProgressableView {

    typealias Countries = [KYCCountry]

    // MARK: - ProgressableView

    @IBOutlet var progressView: UIProgressView!
    var barColor: UIColor = .green
    var startingValue: Float = 0.1

    // MARK: - IBOutlets

    @IBOutlet private var searchBar: UISearchBar!
    @IBOutlet private var tableView: UITableView!

    // MARK: - Properties
    private var countries: Countries? {
        didSet {
            countries?.sort(by: { $0.name < $1.name })
        }
    }

    private var selectedCountry: KYCCountry?

    private lazy var presenter: KYCCountrySelectorPresenter = {
        return KYCCountrySelectorPresenter(view: self)
    }()

    // MARK: Factory

    override class func make(with coordinator: KYCCoordinator) -> KYCCountrySelectionController {
        let controller = makeFromStoryboard()
        controller.coordinator = coordinator
        controller.pageType = .country
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupProgressView()
        tableView.dataSource = self
        tableView.delegate = self
        fetchListOfCountries()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // TICKET: IOS-1142 - call coordinator?
    }

    // MARK: - Private Methods

    private func fetchListOfCountries() {
        KYCNetworkRequest(get: .listOfCountries, taskSuccess: { [weak self] responseData in
            do {
                self?.countries = try JSONDecoder().decode(Countries.self, from: responseData)
                self?.tableView.reloadData()
            } catch {
                Logger.shared.error("Failed to parse countries list.")
            }
        }, taskFailure: { error in
            Logger.shared.error(error.debugDescription)
        })
    }
}

extension KYCCountrySelectionController: UITableViewDataSource, UITableViewDelegate {

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let hasCountries = countries {
            return hasCountries.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let countryCell = tableView.dequeueReusableCell(withIdentifier: "CountryCell"),
            let countries = countries else {
                return UITableViewCell()
        }
        countryCell.textLabel?.text = countries[indexPath.row].name
        return countryCell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedCountry = countries?[indexPath.row] else {
            Logger.shared.warning("Could not infer selected country.")
            return
        }
        Logger.shared.info("User selected '\(selectedCountry.name)'")
        presenter.selected(country: selectedCountry)
    }
}

extension KYCCountrySelectionController: KYCCountrySelectorView {
    func continueKycFlow(country: KYCCountry) {
        // TICKET: IOS-1142 - move to coordinator
        performSegue(withIdentifier: "promptForPersonalDetails", sender: self)
    }

    func startPartnerExchangeFlow(country: KYCCountry) {
        ExchangeCoordinator.shared.start()
    }

    func showExchangeNotAvailable(country: KYCCountry) {
        // TICKET: IOS-1150
    }
}
