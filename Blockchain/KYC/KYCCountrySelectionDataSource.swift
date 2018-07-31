//
//  KYCCountrySelectionDataSource.swift
//  Blockchain
//
//  Created by Maurice A. on 7/27/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

final class KYCCountrySelectionDataSource: NSObject, UIPickerViewDataSource {

    typealias Countries = [KYCCountry]

    // MARK: - Properties

    var countries: Countries?

    static let dataSource = KYCCountrySelectionDataSource()

    // MARK: - Initialization

    override private init() {
        super.init()
    }

    func fetchListOfCountries() {
        let request = KYCNetworkRequest(get: .listOfCountries)
        request.send(taskSuccess: { responseData in
            do {
                self.countries = try JSONDecoder().decode(Countries.self, from: responseData)
            } catch {
                // TODO: handle error
            }
        }, taskFailure: { error in
            // TODO: handle error
            Logger.shared.error(error.debugDescription)
        })
    }

    // MARK: - UIPickerViewDataSource

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let count = countries?.count else { return 0 }
        return count
    }
}
