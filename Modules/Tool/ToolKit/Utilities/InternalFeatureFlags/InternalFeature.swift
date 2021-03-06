// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Defines an internal feature as part of a FeatureFlag
public enum InternalFeature: String, CaseIterable {

    /// Enable secure channel
    case secureChannel

    /// Enable receiving to trading account
    case tradingAccountReceive

    /// Enables deposit and withdraw for US users
    case withdrawAndDepositACH

    /// Enable the new Pin/OnBoarding which uses ComposableArchitecture
    case newOnboarding

    /// Enabled console logging of network requests for debug builds
    case requestConsoleLogging

    // MARK: - Email Verification

    /// Shows Email Verification insted of Simple Buy at Login
    case showOnboardingAfterSignUp

    /// Shows Email Verification in Onboarding, otherwise just show the buy flow
    case showEmailVerificationInOnboarding

    /// Shows Email Verification, if needed, when a user tries to make a purchase
    case showEmailVerificationInBuyFlow

    /// Uses the Transactions Flow implementation of Buy when enabled
    case useTransactionsFlowToBuyCrypto

    /// Enables SDD checks. If `false`, all checks immediately fail
    case sddEnabled
}

extension InternalFeature {

    internal var defaultsKey: String {
        "internal-flag-\(rawValue)-key"
    }
}
