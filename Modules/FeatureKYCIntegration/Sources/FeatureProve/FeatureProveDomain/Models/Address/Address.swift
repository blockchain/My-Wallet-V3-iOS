// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct Address: Hashable, Decodable {

    public enum Constants {
        public static let usIsoCode = "US"
        public static let usPrefix = "US-"
    }

    public let line1: String?
    public let line2: String?
    public let city: String?
    public let postCode: String?
    public var state: String?
    public let country: String?

    public init(
        line1: String? = nil,
        line2: String? = nil,
        city: String? = nil,
        postCode: String? = nil,
        state: String? = nil,
        country: String?
    ) {
        self.line1 = line1
        self.line2 = line2
        self.city = city
        self.postCode = postCode
        self.country = country
        self.state = state
        self.state = correctedState
    }
}

extension Address {

    public var correctedState: String? {
        if let state, country == Constants.usIsoCode, !state.hasPrefix(Constants.usPrefix) {
            return Constants.usPrefix + state
        } else {
            return state
        }
    }
}
