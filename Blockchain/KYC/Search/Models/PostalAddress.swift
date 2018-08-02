//
//  PostalAddress.swift
//  Blockchain
//
//  Created by Alex McGregor on 7/27/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

struct PostalAddress {
    let street: String?
    let streetNumber: String?
    let postalCode: String?
    let country: String?
    let countryCode: String?
    let city: String?
    let state: String?
    var unit: String?
}

extension PostalAddress {
    func generateCellModels() -> [CellModel] {
        var cellModels: [CellModel] = []
        guard let number = streetNumber else {
            assert(false, "Expected street number")
            return cellModels
        }
        guard let street = street else {
            assert(false, "Expected street number")
            return cellModels
        }

        let streetAddress = "\(number) \(street)"
        cellModels.append(.plain(streetAddress))

        // TODO: Localize
        let textEntry = TextEntry(
            placeholder: "Address Line 2 (optional)",
            shouldBecomeFirstResponder: false,
            submission: nil
        )
        cellModels.append(.textEntry(textEntry))

        guard let postalCode = postalCode else {
            assert(false, "Expected street number")
            return cellModels
        }
        guard let city = city else {
            assert(false, "Expected street number")
            return cellModels
        }
        guard let country = country else {
            assert(false, "Expected street number")
            return cellModels
        }

        cellModels.append(.plain(postalCode))
        cellModels.append(.plain(city))
        cellModels.append(.plain(country))

        return cellModels
    }
}
