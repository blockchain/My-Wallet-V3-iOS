//
//  KYCCountrySelectionController.swift
//  Blockchain
//
//  Created by Maurice A. on 7/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

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

    // MARK: - Private Properties

    private var countriesMap = [String: Countries]()

    private var allCountries: Countries? {
        didSet {
            allCountries?.sort(by: { $0.name < $1.name })
            countries = allCountries
        }
    }

    private var countries: Countries? {
        didSet {
            countriesMap.removeAll()

            guard let countries = countries else {
                return
            }

            let countrySectionHeaders = countries.compactMap({ country -> String? in
                guard let firstChar = country.name.first else {
                    return nil
                }
                return String(firstChar).uppercased()
            }).unique

            for firstLetter in countrySectionHeaders {
                let countriesInHeader = countries.filter {
                    guard let firstChar = $0.name.first else { return false }
                    return String(firstChar).uppercased() == firstLetter
                }
                countriesMap[firstLetter] = countriesInHeader
            }

            tableView.reloadData()
        }
    }

    private var countrySectionHeaders: [String] {
        return Array(countriesMap.keys).sorted(by: { $0 < $1 })
    }

    private var searchText: String? {
        didSet {
            guard let allCountries = allCountries else {
                return
            }
            guard let searchText = searchText?.lowercased() else {
                self.countries = allCountries
                return
            }
            self.countries = allCountries.filter { $0.name.lowercased().starts(with: searchText) }
        }
    }

    private var selectedCountry: KYCCountry?

    private lazy var presenter: KYCCountrySelectionPresenter = {
        return KYCCountrySelectionPresenter(view: self)
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
        searchBar.delegate = self
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
                self?.allCountries = try JSONDecoder().decode(Countries.self, from: responseData)
            } catch {
                Logger.shared.error("Failed to parse countries list.")
            }
        }, taskFailure: { error in
            Logger.shared.error(error.debugDescription)
        })
    }
}

extension KYCCountrySelectionController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
    }
}

extension KYCCountrySelectionController: UITableViewDataSource, UITableViewDelegate {

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let firstLetter = countrySectionHeaders[section]
        return countriesMap[firstLetter]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let countryCell = tableView.dequeueReusableCell(withIdentifier: "CountryCell") else {
            return UITableViewCell()
        }

        guard let country = country(at: indexPath) else {
            return UITableViewCell()
        }

        countryCell.textLabel?.text = country.name

        return countryCell
    }

    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        guard searchText?.isEmpty ?? true else {
            return nil
        }
        return countrySectionHeaders
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return countriesMap.keys.count
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedCountry = country(at: indexPath) else {
            Logger.shared.warning("Could not infer selected country.")
            return
        }
        Logger.shared.info("User selected '\(selectedCountry.name)'")
        presenter.selected(country: selectedCountry)
    }

    private func country(at indexPath: IndexPath) -> KYCCountry? {
        let firstLetter = countrySectionHeaders[indexPath.section]
        guard let countriesInSection = countriesMap[firstLetter] else {
            return nil
        }
        return countriesInSection[indexPath.row]
    }
}

extension KYCCountrySelectionController: KYCCountrySelectionView {
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
