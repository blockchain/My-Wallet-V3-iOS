// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureTransactionDomain
import Foundation
import Localization
import PlatformKit
import RxSwift

final class InterestTransferTransactionStateProvider: PendingTransactionStateProviding {

    private typealias LocalizationIds = LocalizationConstants.Transaction.Transfer.Completion

    // MARK: - PendingTransactionStateProviding

    func connect(state: Observable<TransactionState>) -> Observable<PendingTransactionPageState> {
        state.compactMap { state -> PendingTransactionPageState? in
            switch state.executionStatus {
            case .inProgress, .pending, .notStarted:
                return Self.pending(state: state)
            case .completed:
                return Self.success(state: state)
            case .error:
                return nil
            }
        }
    }

    // MARK: - Private Functions

    private static func success(state: TransactionState) -> PendingTransactionPageState {
        PendingTransactionPageState(
            title: String(
                format: LocalizationIds.Success.title,
                state.amount.displayString
            ),
            subtitle: String(
                format: LocalizationIds.Success.description,
                state.destination?.currencyType.code ?? ""
            ),
            compositeViewType: .composite(
                .init(
                    baseViewType: .image(state.asset.logoResource),
                    sideViewAttributes: .init(
                        type: .image(.local(name: "v-success-icon", bundle: .platformUIKit)),
                        position: .radiusDistanceFromCenter
                    ),
                    cornerRadiusRatio: 0.5
                )
            ),
            effect: .complete,
            primaryButtonViewModel: .primary(with: LocalizationIds.Success.action),
            action: state.action
        )
    }

    private static func pending(state: TransactionState) -> PendingTransactionPageState {
        .init(
            title: String(format: LocalizationIds.Pending.title, state.amount.code),
            subtitle: LocalizationIds.Pending.description,
            compositeViewType: .composite(
                .init(
                    baseViewType: .image(state.asset.logoResource),
                    sideViewAttributes: .init(type: .loader, position: .radiusDistanceFromCenter),
                    cornerRadiusRatio: 0.5
                )
            ),
            action: state.action
        )
    }
}

final class StakingDepositTransactionStateProvider: PendingTransactionStateProviding {

    private typealias LocalizationIds = LocalizationConstants.Transaction.Staking.Completion

    // MARK: - PendingTransactionStateProviding

    func connect(state: Observable<TransactionState>) -> Observable<PendingTransactionPageState> {
        state.compactMap { state -> PendingTransactionPageState? in
            switch state.executionStatus {
            case .inProgress, .pending, .notStarted:
                return Self.pending(state: state)
            case .completed:
                return Self.success(state: state)
            case .error:
                return nil
            }
        }
    }

    // MARK: - Private Functions

    private static func success(state: TransactionState) -> PendingTransactionPageState {
        .init(
            title: String(
                format: LocalizationIds.Pending.title, state.amount.code
            ),
            subtitle: String(
                format: LocalizationIds.Pending.description, state.amount.code
            ),
            compositeViewType: .composite(
                .init(
                    baseViewType: .image(state.asset.logoResource),
                    sideViewAttributes: .init(
                        type: .image(.local(name: "clock-error-icon", bundle: .platformUIKit)),
                        position: .radiusDistanceFromCenter
                    ),
                    cornerRadiusRatio: 0.5
                )
            ),
            effect: .complete,
            primaryButtonViewModel: .primary(with: LocalizationIds.Success.action),
            action: state.action
        )
    }

    private static func pending(state: TransactionState) -> PendingTransactionPageState {
        .init(
            title: String(
                format: LocalizationIds.Pending.title, state.amount.code
            ),
            subtitle: String(
                format: LocalizationIds.Pending.description, state.amount.code
            ),
            compositeViewType: .composite(
                .init(
                    baseViewType: .image(state.asset.logoResource),
                    sideViewAttributes: .init(type: .loader, position: .radiusDistanceFromCenter),
                    cornerRadiusRatio: 0.5
                )
            ),
            action: state.action
        )
    }
}

final class ActiveRewardsDepositTransactionStateProvider: PendingTransactionStateProviding {

    private typealias LocalizationIds = LocalizationConstants.Transaction.ActiveRewardsDeposit.Completion

    // MARK: - PendingTransactionStateProviding

    func connect(state: Observable<TransactionState>) -> Observable<PendingTransactionPageState> {
        state.compactMap { state -> PendingTransactionPageState? in
            switch state.executionStatus {
            case .inProgress, .pending, .notStarted:
                return Self.pending(state: state)
            case .completed:
                return Self.success(state: state)
            case .error:
                return nil
            }
        }
    }

    // MARK: - Private Functions

    private static func success(state: TransactionState) -> PendingTransactionPageState {
        .init(
            title: String(
                format: LocalizationIds.Pending.title, state.amount.code
            ),
            subtitle: String(
                format: LocalizationIds.Pending.description, state.amount.code
            ),
            compositeViewType: .composite(
                .init(
                    baseViewType: .image(state.asset.logoResource),
                    sideViewAttributes: .init(
                        type: .image(.local(name: "clock-error-icon", bundle: .platformUIKit)),
                        position: .radiusDistanceFromCenter
                    ),
                    cornerRadiusRatio: 0.5
                )
            ),
            effect: .complete,
            primaryButtonViewModel: .primary(with: LocalizationIds.Success.action),
            action: state.action
        )
    }

    private static func pending(state: TransactionState) -> PendingTransactionPageState {
        .init(
            title: String(
                format: LocalizationIds.Pending.title, state.amount.code
            ),
            subtitle: String(
                format: LocalizationIds.Pending.description, state.amount.code
            ),
            compositeViewType: .composite(
                .init(
                    baseViewType: .image(state.asset.logoResource),
                    sideViewAttributes: .init(type: .loader, position: .radiusDistanceFromCenter),
                    cornerRadiusRatio: 0.5
                )
            ),
            action: state.action
        )
    }
}

final class ActiveRewardsWithdrawTransactionStateProvider: PendingTransactionStateProviding {

    private typealias LocalizationIds = LocalizationConstants.Transaction.ActiveRewardsWithdraw.Completion

    // MARK: - PendingTransactionStateProviding

    func connect(state: Observable<TransactionState>) -> Observable<PendingTransactionPageState> {
        state.compactMap { state -> PendingTransactionPageState? in
            switch state.executionStatus {
            case .inProgress, .pending, .notStarted:
                return Self.pending(state: state)
            case .completed:
                return Self.success(state: state)
            case .error:
                return nil
            }
        }
    }

    // MARK: - Private Functions

    private static func success(state: TransactionState) -> PendingTransactionPageState {
        .init(
            title: String(
                format: LocalizationIds.Pending.title, state.amount.code
            ),
            subtitle: String(
                format: LocalizationIds.Pending.description, state.amount.code
            ),
            compositeViewType: .composite(
                .init(
                    baseViewType: .image(state.asset.logoResource),
                    sideViewAttributes: .init(
                        type: .image(.local(name: "clock-error-icon", bundle: .platformUIKit)),
                        position: .radiusDistanceFromCenter
                    ),
                    cornerRadiusRatio: 0.5
                )
            ),
            effect: .complete,
            primaryButtonViewModel: .primary(with: LocalizationIds.Success.action),
            action: state.action
        )
    }

    private static func pending(state: TransactionState) -> PendingTransactionPageState {
        .init(
            title: LocalizationIds.Pending.title,
            subtitle: LocalizationIds.Pending.description,
            compositeViewType: .composite(
                .init(
                    baseViewType: .image(state.asset.logoResource),
                    sideViewAttributes: .init(type: .loader, position: .radiusDistanceFromCenter),
                    cornerRadiusRatio: 0.5
                )
            ),
            action: state.action
        )
    }
}
