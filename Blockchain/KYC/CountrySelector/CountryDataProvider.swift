//
//  CountryDataProvider.swift
//  Blockchain
//
//  Created by Maurice A. on 7/27/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

final class CountryDataProvider {

    typealias Countries = [KYCCountry]

    // MARK: - Properties

    var countries: Countries?
    init() {
        fetchListOfCountries()
    }
    
    func fetchListOfCountries() {
        KYCNetworkRequest(get: .listOfCountries, taskSuccess: { responseData in
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
}
