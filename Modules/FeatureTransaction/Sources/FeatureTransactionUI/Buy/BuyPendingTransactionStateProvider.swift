// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureTransactionDomain
import Localization
import MoneyKit
import PlatformKit
import PlatformUIKit
import RxSwift
import ToolKit

final class BuyPendingTransactionStateProvider: PendingTransactionStateProviding {

    private typealias LocalizationIds = LocalizationConstants.Transaction.Buy.Completion

    private static let coreBuyIcon: CompositeStatusViewType.Composite.BaseViewType = .templateImage(
        name: "plus-icon",
        bundle: .platformUIKit,
        templateColor: .white
    )

    // MARK: - PendingTransactionStateProviding

    func connect(state: Observable<TransactionState>) -> Observable<PendingTransactionPageState> {
        state.compactMap { state -> PendingTransactionPageState? in
            switch state.executionStatus {
            case .inProgress,
                 .notStarted:
                return Self.inProgress(state: state)
            case .pending:
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
        guard let destinationCurrency = state.destination?.currencyType else {
            impossible("Expected a destination to there for a transaction that has succeeded")
        }
        var subtitle = String(
            format: LocalizationIds.Success.description,
            destinationCurrency.name
        )
        if let frequency = state.pendingTransaction?.recurringBuyFrequency, frequency.isValidRecurringBuyFrequency {
            subtitle = String(
                format: LocalizationIds.Success.recurringBuyDescription,
                state.amount.displayString,
                (state.destination as? CryptoAccount)?.currencyType.code ?? "",
                frequency.description
            )
        }
        return .init(
            title: LocalizationIds.Success.title,
            subtitle: subtitle,
            compositeViewType: .composite(
                .init(
                    baseViewType: coreBuyIcon,
                    sideViewAttributes: .init(
                        type: .image(.local(name: "v-success-icon", bundle: .platformUIKit)),
                        position: .radiusDistanceFromCenter
                    ),
                    backgroundColor: .primaryButton,
                    cornerRadiusRatio: 0.5
                )
            ),
            effect: .complete,
            primaryButtonViewModel: .primary(with: LocalizationIds.Success.action),
            action: state.action
        )
    }

    private static func inProgress(state: TransactionState) -> PendingTransactionPageState {
        let fiat = state.amount
        let title = String(
            format: LocalizationIds.InProgress.title,
            fiat.displayString,
            (state.destination as? CryptoAccount)?.currencyType.name ?? ""
        )

        var subtitle = String(
            format: LocalizationIds.InProgress.description,
            (state.destination as? CryptoAccount)?.currencyType.name ?? ""
        )
        if let frequency = state.pendingTransaction?.recurringBuyFrequency, frequency.isValidRecurringBuyFrequency {
            subtitle = String(
                format: LocalizationIds.InProgress.recurringBuyDescription,
                fiat.displayString,
                (state.destination as? CryptoAccount)?.currencyType.code ?? "",
                frequency.description.lowercased(),
                fiat.displayString,
                (state.destination as? CryptoAccount)?.currencyType.code ?? ""
            )
        }
        return .init(
            title: title,
            subtitle: subtitle,
            compositeViewType: .composite(
                .init(
                    baseViewType: coreBuyIcon,
                    sideViewAttributes: .init(type: .loader, position: .radiusDistanceFromCenter),
                    backgroundColor: .primaryButton,
                    cornerRadiusRatio: 0.5
                )
            ),
            action: state.action
        )
    }

    private static func pending(state: TransactionState) -> PendingTransactionPageState {
        PendingTransactionPageState(
            title: LocalizationIds.Pending.title,
            subtitle: LocalizationIds.Pending.description,
            compositeViewType: .composite(
                .init(
                    baseViewType: coreBuyIcon,
                    sideViewAttributes: .init(
                        type: .image(.local(name: "clock-error-icon", bundle: .platformUIKit)),
                        position: .radiusDistanceFromCenter
                    ),
                    backgroundColor: .primaryButton,
                    cornerRadiusRatio: 0.5
                )
            ),
            effect: .complete,
            primaryButtonViewModel: .primary(with: LocalizationConstants.okString),
            action: state.action
        )
    }
}
