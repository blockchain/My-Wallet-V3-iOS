// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct PersonalDetails: Decodable, Equatable {
    public let identifier: String?
    public let firstName: String?
    public let lastName: String?
    public let birthday: Date?

    /// Indicates that PersonalDetails is completly filled.
    ///
    /// True if all conditions apply:
    /// 1. FirstName exists and is not empty
    /// 2. LastName exists and is not empty
    /// 3. Birthday exists
    public var isComplete: Bool {
        firstName?.isEmpty == false
            && lastName?.isEmpty == false
            && birthday != nil
    }

    /// Full name is composed of firstName and lastName
    public var fullName: String {
        [firstName, lastName]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case firstName
        case lastName
        case birthday = "dob"
    }

    public init(id: String?, first: String?, last: String?, birthday: Date?) {
        self.identifier = id
        self.firstName = first
        self.lastName = last
        self.birthday = birthday
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try values.decodeIfPresent(String.self, forKey: .identifier)
        self.firstName = try values.decodeIfPresent(String.self, forKey: .firstName)
        self.lastName = try values.decodeIfPresent(String.self, forKey: .lastName)
        self.birthday = try (values.decodeIfPresent(String.self, forKey: .birthday))
            .flatMap { DateFormatter.birthday.date(from: $0) }
    }
}
