//
//  KYCCountrySelectionController.swift
//  Blockchain
//
//  Created by Maurice A. on 7/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

/// Country selection screen in KYC flow
final class KYCCountrySelectionController: UITableViewController {
    typealias Countries = [KYCCountry]

    // MARK: - Properties
    var countries: Countries?
    
    var dataProvider: CountryDataProvider? {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
       // dataProvider?.fetchListOfCountries()
        
        KYCNetworkRequest(get: .listOfCountries, taskSuccess: { responseData in
            do {
                print("decoding in viewDidLoad..", responseData)
                self.countries = try JSONDecoder().decode(Countries.self, from: responseData)
                print("codedCountries", self.countries)
                self.tableView.reloadData()

            } catch {
                // TODO: handle error
        // TODO: Remove debug
            }
        }, taskFailure: { error in
            // TODO: handle error
            Logger.shared.error(error.debugDescription)
        })
        
    }

    // MARK: UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        guard let `countries` = countries else {
//            return 0
//        }
        if let hasCountries = countries {
            return hasCountries.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let countryCell = tableView.dequeueReusableCell(withIdentifier: "CountryCell"),
            let countries = countries else {
                return UITableViewCell()
        }
        countryCell.textLabel?.text = countries[indexPath.row].name
        return countryCell
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "promptForPersonalDetails", sender: self)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // TODO: implement method body
    }
}
