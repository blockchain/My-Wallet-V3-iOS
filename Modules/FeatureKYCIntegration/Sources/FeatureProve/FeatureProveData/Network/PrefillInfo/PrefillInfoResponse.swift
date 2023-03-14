// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureProveDomain
import Foundation

public struct PrefillInfoResponse: Decodable {

    let firstName: String?
    let lastName: String?
    let addresses: [Address]
    let dateOfBirth: Date?
    let phone: String?

    enum CodingKeys: String, CodingKey {
        case firstName
        case lastName
        case addresses
        case birthday = "dob"
        case phone
    }

    public init(
        firstName: String,
        lastName: String,
        addresses: [Address],
        phone: String,
        dateOfBirth: Date
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.addresses = addresses
        self.phone = phone
        self.dateOfBirth = dateOfBirth
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.firstName = try values.decodeIfPresent(String.self, forKey: .firstName)
        self.lastName = try values.decodeIfPresent(String.self, forKey: .lastName)
        self.addresses = try values.decode([Address].self, forKey: .addresses)
        self.dateOfBirth = try (values.decodeIfPresent(String.self, forKey: .birthday))
            .flatMap { DateFormatter.birthday.date(from: $0) }
        self.phone = try values.decodeIfPresent(String.self, forKey: .phone)
    }
}
