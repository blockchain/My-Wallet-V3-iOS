// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import ToolKit

final class DepositPendingTransactionStateProvider: PendingTransactionStateProviding {

    private typealias LocalizationIds = LocalizationConstants.Transaction.Deposit.Completion

    // MARK: - PendingTransactionStateProviding

    func connect(state: Observable<TransactionState>) -> Observable<PendingTransactionPageState> {
        state.compactMap { [weak self] state -> PendingTransactionPageState? in
            guard let self else { return nil }
            switch state.executionStatus {
            case .notStarted, .pending, .inProgress:
                return pending(state: state)
            case .error:
                return nil
            case .completed:
                return success(state: state)
            }
        }
    }

    // MARK: - Private Functions

    private func success(state: TransactionState) -> PendingTransactionPageState {
        let date = Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date()
        let value = DateFormatter.medium.string(from: date)
        let amount = state.amount
        let currency = amount.currency
        return .init(
            title: String(format: LocalizationIds.Success.title, amount.displayString),
            subtitle: String(
                format: LocalizationIds.Success.description,
                amount.displayString,
                amount.displayCode,
                value
            ),
            compositeViewType: .composite(
                .init(
                    baseViewType: .badgeImageViewModel(
                        .primary(
                            image: currency.logoResource,
                            contentColor: .white,
                            backgroundColor: currency.isFiatCurrency ? .fiat : currency.brandUIColor,
                            cornerRadius: .roundedHigh,
                            accessibilityIdSuffix: "PendingTransactionSuccessBadge"
                        )
                    ),
                    sideViewAttributes: .init(
                        type: .image(PendingStateViewModel.Image.success.imageResource),
                        position: .radiusDistanceFromCenter
                    )
                )
            ),
            effect: .complete,
            primaryButtonViewModel: .primary(with: LocalizationConstants.okString),
            action: state.action
        )
    }

    private func pending(state: TransactionState) -> PendingTransactionPageState {
        let amount = state.amount
        let currency = amount.currency
        return .init(
            title: String(
                format: LocalizationIds.Pending.title,
                amount.displayString
            ),
            subtitle: LocalizationIds.Pending.description,
            compositeViewType: .composite(
                .init(
                    baseViewType: .badgeImageViewModel(
                        .primary(
                            image: amount.currency.logoResource,
                            contentColor: .white,
                            backgroundColor: currency.isFiatCurrency ? .fiat : currency.brandUIColor,
                            cornerRadius: .roundedHigh,
                            accessibilityIdSuffix: "PendingTransactionPendingBadge"
                        )
                    ),
                    sideViewAttributes: .init(type: .loader, position: .radiusDistanceFromCenter),
                    cornerRadiusRatio: 0.5
                )
            ),
            action: state.action
        )
    }
}
