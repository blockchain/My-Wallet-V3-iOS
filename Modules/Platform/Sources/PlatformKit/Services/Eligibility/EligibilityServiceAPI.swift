// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import RxSwift

/// Eligible is true when:
///
/// 1. user is eligible for `SIMPLEBUY` product
/// 2. user is eligible for at least 1 payment method
/// 3. the user has less than `maxPendingDepositSimpleBuyTrades` simple transactions in `PENDING_DEPOSIT` and
/// 4. user has less than `maxPendingConfirmationSimpleBuyTrades` simple transactions in `PENDING_CONFIRMATION`
///
/// `simpleBuyTradingEligible` is true when user is eligible for `SIMPLEBUY` product
/// `simpleBuyPendingTradesEligible` is `true` when `pendingDepositSimpleBuyTrades < maxPendingDepositSimpleBuyTrades`
/// `&& pendingConfirmationSimpleBuyTrades < maxPendingConfirmationSimpleBuyTrades`
public struct Eligibility: Decodable, Hashable {

    public init(
        eligible: Bool,
        simpleBuyTradingEligible: Bool,
        simpleBuyPendingTradesEligible: Bool,
        pendingDepositSimpleBuyTrades: Int,
        pendingConfirmationSimpleBuyTrades: Int,
        maxPendingDepositSimpleBuyTrades: Int,
        maxPendingConfirmationSimpleBuyTrades: Int
    ) {
        self.eligible = eligible
        self.simpleBuyTradingEligible = simpleBuyTradingEligible
        self.simpleBuyPendingTradesEligible = simpleBuyPendingTradesEligible
        self.pendingDepositSimpleBuyTrades = pendingDepositSimpleBuyTrades
        self.pendingConfirmationSimpleBuyTrades = pendingConfirmationSimpleBuyTrades
        self.maxPendingDepositSimpleBuyTrades = maxPendingDepositSimpleBuyTrades
        self.maxPendingConfirmationSimpleBuyTrades = maxPendingConfirmationSimpleBuyTrades
    }

    public let eligible: Bool
    public let simpleBuyTradingEligible: Bool
    public let simpleBuyPendingTradesEligible: Bool
    public let pendingDepositSimpleBuyTrades: Int
    public let pendingConfirmationSimpleBuyTrades: Int
    public let maxPendingDepositSimpleBuyTrades: Int
    public let maxPendingConfirmationSimpleBuyTrades: Int
}

/// Brokerage (Simple Buy/Sell/Swap) Eligibility Service
public protocol EligibilityServiceAPI: AnyObject {

    /// Feature is enabled and EligibilityClientAPI returns eligible for current fiat currency.
    var isEligible: Single<Bool> { get }

    var isEligiblePublisher: AnyPublisher<Bool, Never> { get }

    func fetch() -> Single<Bool>

    func eligibility() -> AnyPublisher<Eligibility, Error>
}
