//
//  KYCCountrySelectionController.swift
//  Blockchain
//
//  Created by Maurice A. on 7/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

/// Country selection screen in KYC flow
final class KYCCountrySelectionController: KYCBaseViewController, UITableViewDataSource, UITableViewDelegate {
    typealias Countries = [KYCCountry]

    @IBOutlet private var tableView: UITableView!

    // MARK: - Properties
    var countries: Countries?

    // MARK: Factory

    override class func make(with coordinator: KYCCoordinator) -> KYCCountrySelectionController {
        let storyboard = UIStoryboard(name: "KYCCountrySelection", bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as! KYCCountrySelectionController
        controller.coordinator = coordinator
        controller.pageType = .country
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        KYCNetworkRequest(get: .listOfCountries, taskSuccess: { responseData in
            do {
                self.countries = try JSONDecoder().decode(Countries.self, from: responseData)
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
        performSegue(withIdentifier: "promptForPersonalDetails", sender: self)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // TODO: implement method body
    }
}
