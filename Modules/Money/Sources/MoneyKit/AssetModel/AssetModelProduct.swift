// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// A product of an `AssetModel`.
public enum AssetModelProduct: String, Hashable, CaseIterable {

    case privateKey = "PrivateKey"

    case mercuryDeposits = "MercuryDeposits"

    case mercuryWithdrawals = "MercuryWithdrawals"

    case interestBalance = "InterestBalance"

    case custodialWalletBalance = "CustodialWalletBalance"

    case staking = "Staking"

    case activeRewardsBalance = "EarnCC1W"
}
