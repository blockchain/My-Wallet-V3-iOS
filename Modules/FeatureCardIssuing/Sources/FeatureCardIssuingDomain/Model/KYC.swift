// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct KYC: Decodable, Equatable {

    public enum Status: String, Decodable, Equatable {
        case success = "SUCCESS"
        case unverified = "UNVERIFIED"
        case pending = "PENDING"
        case failure = "FAILURE"
    }

    public enum Field: String, Decodable, Equatable, Identifiable {

        public var id: String {
            rawValue
        }

        case ssn = "SSN"
        case residentialAddress = "RESIDENTIAL_ADDRESS"
    }

    public let status: Status
    public let errorFields: [Field]?

    public init(status: Status, errorFields: [Field]?) {
        self.status = status
        self.errorFields = errorFields
    }
}
