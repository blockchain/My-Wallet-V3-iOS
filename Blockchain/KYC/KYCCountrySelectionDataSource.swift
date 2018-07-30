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

    weak var delegate: HTTPRequestErrorDelegate?

    static let dataSource = KYCCountrySelectionDataSource()

    // MARK: - Initialization

    override private init() {
        super.init()
    }

    func fetchListOfCountries() {
        let url = URL(string: "https://api.dev.blockchain.info/nabu-app/countries?filter=eea")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                self.delegate?.handleClientError(error); return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                self.delegate?.handleServerError(.badResponse); return
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                self.delegate?.handleServerError(.badStatusCode(code: httpResponse.statusCode)); return
            }
            if let mimeType = httpResponse.mimeType {
                guard mimeType == "application/json" else {
                    self.delegate?.handlePayloadError(.invalidMimeType(type: mimeType)); return
                }
            }
            guard let responseData = data else {
                self.delegate?.handlePayloadError(HTTPRequestPayloadError.emptyData); return
            }
            self.decode(json: responseData)
        }
        task.resume()
    }

    // MARK: - Private Methods

    private func decode(json: Data) {
        do {
            countries = try JSONDecoder().decode(Countries.self, from: json)
        } catch {
            delegate?.handlePayloadError(.badData)
        }
    }

    // MARK: - UIPickerViewDataSource

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let count = countries?.count else { return 1 }
        return count
    }
}
