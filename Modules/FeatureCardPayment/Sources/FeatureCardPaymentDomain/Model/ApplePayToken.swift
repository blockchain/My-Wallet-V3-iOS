// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PassKit

public struct ApplePayToken: Codable, Equatable {

    public struct BillingPaymentContact: Codable, Equatable {
        public let line1: String?
        public let line2: String?
        public let city: String?
        public let state: String?
        public let country: String?
        public let postCode: String?
        public let name: String?
        public let firstname: String?
        public let middleName: String?
        public let lastname: String?
        public let phone: String?
        public let email: String?
    }

    public let paymentData: ApplePayTokenData
    public let paymentMethod: ApplePayPaymentMethod
    public let transactionIdentifier: String
    public var billingPaymentContact: BillingPaymentContact?
}

extension ApplePayToken {
    init?(token: PKPaymentToken, billingContact: PKContact?) {
        guard let paymentData = try? JSONDecoder().decode(ApplePayTokenData.self, from: token.paymentData),
              let paymentMethod = ApplePayPaymentMethod(paymentMethod: token.paymentMethod)
        else {
            return nil
        }

        var billingPaymentContact: BillingPaymentContact? {
            guard let billingAddress = billingContact else { return nil }
            let address = billingContact?.postalAddress
            return BillingPaymentContact(
                line1: address?.street,
                line2: address?.subLocality,
                city: address?.city,
                state: address?.state,
                country: address?.country,
                postCode: address?.postalCode,
                name: billingAddress.name?.fullName,
                firstname: billingAddress.name?.givenName,
                middleName: billingAddress.name?.middleName,
                lastname: billingAddress.name?.familyName,
                phone: billingAddress.phoneNumber?.stringValue,
                email: billingContact?.emailAddress
            )
        }
        self.init(
            paymentData: paymentData,
            paymentMethod: paymentMethod,
            transactionIdentifier: token.transactionIdentifier,
            billingPaymentContact: billingPaymentContact
        )
    }
}

extension PersonNameComponents {
    fileprivate var fullName: String {
        let formatter = PersonNameComponentsFormatter()
        formatter.locale = .Posix
        formatter.style = .long
        return formatter.string(from: self)
    }
}
