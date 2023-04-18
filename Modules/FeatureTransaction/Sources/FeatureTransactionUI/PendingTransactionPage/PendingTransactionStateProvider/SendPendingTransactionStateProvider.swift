// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import MoneyKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import ToolKit

final class SendPendingTransactionStateProvider: PendingTransactionStateProviding {

    private typealias LocalizationIds = LocalizationConstants.Transaction.Send.Completion

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
        let sent = state.amount
        let title = sent.isZero || state.destination is RawStaticTransactionTarget
            ? String(
                format: LocalizationIds.Success.title,
                sent.displayCode
            )
            : String(
                format: LocalizationIds.Success.title,
                sent.displayString
            )
        return .init(
            title: title,
            subtitle: String(
                format: LocalizationIds.Success.description,
                sent.currency.name
            ),
            compositeViewType: .composite(
                .init(
                    baseViewType: .image(sent.currency.logoResource),
                    sideViewAttributes: .init(
                        type: .image(PendingStateViewModel.Image.success.imageResource),
                        position: .radiusDistanceFromCenter
                    ),
                    cornerRadiusRatio: 0.5
                )
            ),
            effect: .complete,
            primaryButtonViewModel: .primary(with: LocalizationConstants.okString),
            action: state.action
        )
    }

    private static func pending(state: TransactionState) -> PendingTransactionPageState {
        let sent = state.amount
        let title = sent.isZero || state.destination is RawStaticTransactionTarget
            ? String(
                format: LocalizationIds.Pending.title,
                sent.displayCode
            )
            : String(
                format: LocalizationIds.Pending.title,
                sent.displayString
            )

        return .init(
            title: title,
            subtitle: LocalizationIds.Pending.description,
            compositeViewType: .composite(
                .init(
                    baseViewType: .image(sent.currency.logoResource),
                    sideViewAttributes: .init(type: .loader, position: .radiusDistanceFromCenter),
                    cornerRadiusRatio: 0.5
                )
            ),
            action: state.action
        )
    }
}
