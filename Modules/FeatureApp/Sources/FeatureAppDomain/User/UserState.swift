//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import FeatureProductsDomain

public enum UserStateError: Error {
    case missingBalance(Error)
    case missingKYCInfo(Error)
    case missingPaymentInfo(Error)
    case missingProductsInfo(Error)
    case missingPurchaseHistory(Error)
}

extension UserStateError: Equatable {

    public static func == (lhs: UserStateError, rhs: UserStateError) -> Bool {
        String(describing: lhs) == String(describing: rhs)
    }
}

/// A data structure that represents the state of the user
public struct UserState: Equatable {

    /// A data structure that represents the KYC status of the user
    public enum KYCStatus: Equatable {
        case unverified
        case inReview
        case gold

        public var canPurchaseCrypto: Bool {
            switch self {
            case .unverified:
                return false
            case .gold, .inReview:
                return true
            }
        }
    }

    /// A data structure that represents a payment method the user has linked to their Blockchain.com account
    public struct PaymentMethod: Identifiable, Equatable {
        public let id: String
        public let label: String
    }

    public let kycStatus: KYCStatus
    public let linkedPaymentMethods: [PaymentMethod]
    public let hasEverPurchasedCrypto: Bool
    public let products: Set<ProductValue>
}

extension UserState {

    public func requiredTierToUse(_ productId: ProductIdentifier?) -> Int? {
        guard let product = product(id: productId) else {
            return nil
        }
        return product.suggestedUpgrade?.requiredTier
    }

    public func product(id: ProductIdentifier?) -> ProductValue? {
        guard let id, let product = products.first(where: { $0.id == id }) else {
            return nil
        }
        return product
    }
}
