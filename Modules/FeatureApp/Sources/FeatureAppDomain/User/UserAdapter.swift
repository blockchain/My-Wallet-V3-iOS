//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureProductsDomain
import Foundation
import PlatformKit
import ToolKit

/// A protocol to fetch and monitor changes in `UserState`
public protocol UserAdapterAPI {

    /// A publisher that streams `UserState` values on subscription and on change.
    var userState: AnyPublisher<Result<UserState, UserStateError>, Never> { get }
}

private typealias RawUserData = (
    kycStatus: UserState.KYCStatus,
    paymentMethods: [UserState.PaymentMethod],
    hasEverPurchasedCrypto: Bool,
    products: [ProductValue]
)

public final class UserAdapter: UserAdapterAPI {

    public let userState: AnyPublisher<Result<UserState, UserStateError>, Never>

    public init(
        kycTiersService: KYCTiersServiceAPI,
        paymentMethodsService: PaymentMethodTypesServiceAPI,
        productsService: ProductsServiceAPI,
        ordersService: OrdersServiceAPI
    ) {
        let streams = kycTiersService.kycStatusStream
            .combineLatest(
                paymentMethodsService.paymentMethodsStream,
                ordersService.hasPurchasedAnyCryptoStream
            )
            .combineLatest(productsService.productsStream)

        self.userState = streams
            .map { results -> Result<RawUserData, UserStateError> in
                let (r1, r2) = results
                let (kycStatusResult, paymentMethodsResult, hasEverPurchasedCryptoResult) = r1
                let products = r2
                return kycStatusResult.zip(
                    paymentMethodsResult,
                    hasEverPurchasedCryptoResult,
                    products
                )
                .map { $0 } // this makes the compiler happy by making a generic tuple be casted to RawUserData
            }
            .map { zippedResult -> Result<UserState, UserStateError> in
                zippedResult.map { kycStatus, paymentMethods, hasEverPurchasedCrypto, products in
                    UserState(
                        kycStatus: kycStatus,
                        linkedPaymentMethods: paymentMethods,
                        hasEverPurchasedCrypto: hasEverPurchasedCrypto,
                        products: products
                    )
                }
            }
            .removeDuplicates()
            .shareReplay()
    }
}

// MARK: - Helpers

extension UserState.KYCStatus {

    fileprivate init(userTiers: KYC.UserTiers) {
        if userTiers.isVerifiedApproved {
            self = .gold
        } else if userTiers.isVerifiedPending {
            self = .inReview
        } else {
            self = .unverified
        }
    }
}

extension KYCTiersServiceAPI {

    fileprivate var kycStatusStream: AnyPublisher<Result<UserState.KYCStatus, UserStateError>, Never> {
        tiersStream
            .mapError(UserStateError.missingKYCInfo)
            .map(UserState.KYCStatus.init)
            .result()
    }
}

extension PaymentMethodTypesServiceAPI {

    fileprivate var paymentMethodsStream: AnyPublisher<Result<[UserState.PaymentMethod], UserStateError>, Never> {
        paymentMethodTypesValidForBuy
            .mapError(UserStateError.missingPaymentInfo)
            .map { paymentMethods -> [UserState.PaymentMethod] in
                paymentMethods.compactMap { paymentMethodType -> UserState.PaymentMethod? in
                    guard !paymentMethodType.isSuggested else {
                        return nil
                    }
                    return UserState.PaymentMethod(
                        id: paymentMethodType.id,
                        label: paymentMethodType.label
                    )
                }
            }
            .result()
    }
}

extension OrdersServiceAPI {

    fileprivate var hasPurchasedAnyCryptoStream: AnyPublisher<Result<Bool, UserStateError>, Never> {
        hasUserMadeAnyPurchases
            .mapError(UserStateError.missingPurchaseHistory)
            .result()
    }
}

extension ProductsServiceAPI {

    fileprivate var productsStream: AnyPublisher<Result<[ProductValue], UserStateError>, Never> {
        streamProducts().map { result in
            result.mapError(UserStateError.missingProductsInfo)
        }
        .eraseToAnyPublisher()
    }
}
