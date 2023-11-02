// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import PlatformKit
import ToolKit

/// Represents all types of transactions the user can perform
public enum TransactionFlowAction {

    // Restores an existing order.
    case order(OrderDetails)
    /// Performs a buy. If `CryptoAccount` is `nil`, the users will be presented with a crypto currency selector.
    case buy(CryptoAccount?)
    /// Performs a sell. If `CryptoCurrency` is `nil`, the users will be presented with a crypto currency selector.
    case sell(CryptoAccount?)
    /// Performs a swap. If `CryptoCurrency` is `nil`, the users will be presented with a crypto currency selector.
    case swap(source: CryptoAccount?, target: CryptoAccount?)
    /// Performs a send. If `BlockchainAccount` is `nil`, the users will be presented with a crypto account selector.
    case send(BlockchainAccount?, TransactionTarget?)
    /// Performs a receive. If `CryptoAccount` is `nil`, the users will be presented with a crypto account selector.
    case receive(CryptoAccount?)
    /// Performs an interest transfer.
    case interestTransfer(CryptoInterestAccount)
    /// Performs an interest withdraw.
    case interestWithdraw(CryptoInterestAccount, CryptoTradingAccount)
    /// Performs a staking deposit.
    case stakingDeposit(CryptoStakingAccount)
    /// Performs a staking withdraw.
    case stakingWithdraw(CryptoStakingAccount, CryptoTradingAccount)
    /// Performs an active rewards deposit.
    case activeRewardsDeposit(CryptoActiveRewardsAccount)
    /// Performs an active rewards withdraw.
    case activeRewardsWithdraw(CryptoActiveRewardsAccount, CryptoActiveRewardsWithdrawTarget)
    /// Performs a withdraw.
    case withdraw(FiatAccount)
    /// Performs a deposit.
    case deposit(FiatAccount)
    /// Signs a transaction
    case sign(sourceAccount: BlockchainAccount, destination: TransactionTarget)
}

extension TransactionFlowAction: Equatable {
    public static func == (lhs: TransactionFlowAction, rhs: TransactionFlowAction) -> Bool {
        switch (lhs, rhs) {
        case (.swap(let lhsSourceAccount, let lhsTargetAccount), .swap(let rhsSourceAccount, let rhsTargetAccount)):
            lhsSourceAccount?.identifier == rhsSourceAccount?.identifier && lhsTargetAccount?.identifier == rhsTargetAccount?.identifier
        case (.buy(let lhsAccount), .buy(let rhsAccount)),
            (.sell(let lhsAccount), .sell(let rhsAccount)):
            lhsAccount?.identifier == rhsAccount?.identifier
        case (.interestTransfer(let lhsAccount), .interestTransfer(let rhsAccount)):
            lhsAccount.identifier == rhsAccount.identifier
        case (.interestWithdraw(let lhsFromAccount, let lhsToAccount), .interestWithdraw(let rhsFromAccount, let rhsToAccount)):
            lhsFromAccount.identifier == rhsFromAccount.identifier && lhsToAccount.identifier == rhsToAccount.identifier
        case (.stakingDeposit(let lhsAccount), .stakingDeposit(let rhsAccount)):
            lhsAccount.identifier == rhsAccount.identifier
        case (.activeRewardsDeposit(let lhsAccount), .activeRewardsDeposit(let rhsAccount)):
            lhsAccount.identifier == rhsAccount.identifier
        case (.activeRewardsWithdraw(let lhsAccount, let lhsTarget), .activeRewardsWithdraw(let rhsAccount, let rhsTarget)):
            lhsAccount.identifier == rhsAccount.identifier
                && lhsTarget.label == rhsTarget.label
        case (.withdraw(let lhsAccount), .withdraw(let rhsAccount)),
             (.deposit(let lhsAccount), .deposit(let rhsAccount)):
            lhsAccount.identifier == rhsAccount.identifier
        case (.order(let lhsOrder), .order(let rhsOrder)):
            lhsOrder.identifier == rhsOrder.identifier
        case (.sign(let lhsAccount, let lhsDestination), .sign(let rhsAccount, let rhsDestination)):
            lhsAccount.identifier == rhsAccount.identifier
                && lhsDestination.label == rhsDestination.label
        case (.send(let lhsFromAccount, let lhsDestination), .send(let rhsFromAccount, let rhsDestination)):
            lhsFromAccount?.identifier == rhsFromAccount?.identifier
                && lhsDestination?.label == rhsDestination?.label
        default:
            false
        }
    }
}

extension TransactionFlowAction {

    var isCustodial: Bool {
        switch self {
        case .buy,
             .sell,
             .swap:
            true
        case .send(let account, _),
             .sign(let account as BlockchainAccount?, _),
             .receive(let account as BlockchainAccount?):
            account?.accountType.isCustodial ?? false
        case .order,
             .interestTransfer,
             .interestWithdraw,
             .stakingDeposit,
             .stakingWithdraw,
             .withdraw,
             .deposit,
             .activeRewardsWithdraw,
             .activeRewardsDeposit:
            true
        }
    }
}

extension TransactionFlowAction {

    var asset: AssetAction {
        switch self {
        case .buy:
            .buy
        case .sell:
            .sell
        case .swap:
            .swap
        case .send:
            .send
        case .receive:
            .receive
        case .order:
            .buy
        case .deposit:
            .deposit
        case .withdraw:
            .withdraw
        case .interestTransfer:
            .interestTransfer
        case .interestWithdraw:
            .interestWithdraw
        case .stakingDeposit:
            .stakingDeposit
        case .sign:
            .sign
        case .activeRewardsDeposit:
            .activeRewardsDeposit
        case .activeRewardsWithdraw:
            .activeRewardsWithdraw
        case .stakingWithdraw:
            .stakingWithdraw
        }
    }
}

extension TransactionFlowAction {
    var currencyCode: String? {
        switch self {
        case .swap(let sourceAccount, _):
            sourceAccount?.currencyType.code
        case .buy(let account),
             .sell(let account),
             .receive(let account):
            account?.currencyType.code
        case .interestTransfer(let account):
            account.currencyType.code
        case .interestWithdraw(_, let account):
            account.currencyType.code
        case .stakingWithdraw(_, let account):
            account.currencyType.code
        case .stakingDeposit(let account):
            account.currencyType.code
        case .activeRewardsDeposit(let account):
            account.currencyType.code
        case .activeRewardsWithdraw(let account, _):
            account.currencyType.code
        case .withdraw(let account),
             .deposit(let account):
            account.currencyType.code
        case .order(let account):
            account.price?.code
        case .sign(_, let account):
            account.currencyType.code
        case .send(_, let account):
            account?.currencyType.code
        }
    }
}
