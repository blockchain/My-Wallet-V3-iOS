//
//  KYCCountrySelectionController.swift
//  Blockchain
//
//  Created by Maurice A. on 7/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

typealias Countries = [KYCCountry]

private class CountriesMap {
    private var allCountries: Countries?
    private var backingMap = [String: Countries]()

    init() {
    }

    var searchText: String? {
        didSet {
            guard let countries = allCountries else {
                return
            }
            guard let searchText = searchText?.lowercased() else {
                updateMap(with: countries)
                return
            }
            let filteredCountries = countries.filter { $0.name.lowercased().starts(with: searchText) }
            updateMap(with: filteredCountries)
        }
    }

    var firstLetters: [String] {
        return Array(backingMap.keys).sorted(by: { $0 < $1 })
    }

    var keys: Dictionary<String, Countries>.Keys {
        return backingMap.keys
    }

    func countries(firstLetter: String) -> Countries? {
        return backingMap[firstLetter]
    }

    func setAllCountries(_ countries: Countries) {
        allCountries = countries
        allCountries?.sort(by: { $0.name < $1.name })
        updateMap(with: countries)
    }

    func country(at indexPath: IndexPath) -> KYCCountry? {
        let firstLetter = firstLetters[indexPath.section]
        guard let countriesInSection = backingMap[firstLetter] else {
            return nil
        }
        return countriesInSection[indexPath.row]
    }

    private func updateMap(with countries: Countries) {
        backingMap.removeAll()

        let countrySectionHeaders = countries.compactMap({ country -> String? in
            guard let firstChar = country.name.first else {
                return nil
            }
            return String(firstChar).uppercased()
        }).unique

        countrySectionHeaders.forEach { firstLetter in
            backingMap[firstLetter] = countries.filter {
                guard let firstChar = $0.name.first else { return false }
                return String(firstChar).uppercased() == firstLetter
            }
        }
    }
}

/// Country selection screen in KYC flow
final class KYCCountrySelectionController: KYCBaseViewController, ProgressableView {

    // MARK: - ProgressableView

    @IBOutlet var progressView: UIProgressView!
    var barColor: UIColor = .green
    var startingValue: Float = 0.1

    // MARK: - IBOutlets

    @IBOutlet private var searchBar: UISearchBar!
    @IBOutlet private var tableView: UITableView!

    // MARK: - Private Properties

    private var countriesMap = CountriesMap()

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
                let allCountries = try JSONDecoder().decode(Countries.self, from: responseData)
                self?.countriesMap.setAllCountries(allCountries)
                self?.tableView.reloadData()
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
        countriesMap.searchText = searchText
        tableView.reloadData()
    }
}

extension KYCCountrySelectionController: UITableViewDataSource, UITableViewDelegate {

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let firstLetter = countriesMap.firstLetters[section]
        return countriesMap.countries(firstLetter: firstLetter)?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let countryCell = tableView.dequeueReusableCell(withIdentifier: "CountryCell") else {
            return UITableViewCell()
        }

        guard let country = countriesMap.country(at: indexPath) else {
            return UITableViewCell()
        }

        countryCell.textLabel?.text = country.name

        return countryCell
    }

    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        guard countriesMap.searchText?.isEmpty ?? true else {
            return nil
        }
        return countriesMap.firstLetters
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return countriesMap.keys.count
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedCountry = countriesMap.country(at: indexPath) else {
            Logger.shared.warning("Could not infer selected country.")
            return
        }
        Logger.shared.info("User selected '\(selectedCountry.name)'")
        presenter.selected(country: selectedCountry)
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
