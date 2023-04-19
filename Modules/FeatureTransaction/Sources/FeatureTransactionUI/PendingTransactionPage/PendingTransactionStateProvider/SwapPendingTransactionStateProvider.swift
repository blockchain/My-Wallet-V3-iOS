// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import MoneyKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import ToolKit

final class SwapPendingTransactionStateProvider: PendingTransactionStateProviding {

    private typealias LocalizationIds = LocalizationConstants.Transaction.Swap.Completion

    // MARK: - PendingTransactionStateProviding

    func connect(state: Observable<TransactionState>) -> Observable<PendingTransactionPageState> {
        state.compactMap { state -> PendingTransactionPageState? in
            switch state.executionStatus {
            case .inProgress, .pending, .notStarted:
                return Self.pending(state: state)
            case .completed:
                if state.source is NonCustodialAccount {
                    return Self.successNonCustodial(state: state)
                } else {
                    return Self.success(state: state)
                }
            case .error:
                return nil
            }
        }
    }

    // MARK: - Private Functions

    private static func successNonCustodial(state: TransactionState) -> PendingTransactionPageState {
        PendingTransactionPageState(
            title: String(
                format: LocalizationIds.Pending.title,
                state.source?.currencyType.code ?? "",
                state.destination?.currencyType.code ?? ""
            ),
            subtitle: LocalizationIds.Pending.description,
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

    private static func success(state: TransactionState) -> PendingTransactionPageState {
        .init(
            title: String(
                format: LocalizationIds.Success.title,
                state.amount.displayString
            ),
            subtitle: String(
                format: LocalizationIds.Success.description,
                state.destination?.currencyType.cryptoCurrency?.name ?? ""
            ),
            compositeViewType: .composite(
                .init(
                    baseViewType: .templateImage(name: "swap-icon", bundle: .platformUIKit, templateColor: .white),
                    sideViewAttributes: .init(
                        type: .image(PendingStateViewModel.Image.success.imageResource),
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

    private static func pending(state: TransactionState) -> PendingTransactionPageState {
        let sent = state.amount
        let received: MoneyValue
        switch state.moneyValueFromDestination() {
        case .success(let value):
            received = value
        case .failure:
            switch state.destination {
            case nil:
                fatalError("Expected a Destination: \(state)")
            case let account as SingleAccount:
                received = .zero(currency: account.currencyType)
            case let cryptoTarget as CryptoTarget:
                received = .zero(currency: cryptoTarget.asset)
            default:
                fatalError("Unsupported state.destination: \(String(reflecting: state.destination))")
            }
        }
        let title: String
        if !received.isZero, !sent.isZero {
            // If we have both sent and receive values:
            title = String(
                format: LocalizationIds.Pending.title,
                sent.displayString,
                received.displayString
            )
        } else {
            // If we have invalid inputs but we should continue.
            title = String(
                format: LocalizationIds.Pending.title,
                sent.displayCode,
                received.displayCode
            )
        }
        return .init(
            title: title,
            subtitle: LocalizationIds.Pending.description,
            compositeViewType: .composite(
                .init(
                    baseViewType: .templateImage(name: "swap-icon", bundle: .platformUIKit, templateColor: .white),
                    sideViewAttributes: .init(type: .loader, position: .radiusDistanceFromCenter),
                    backgroundColor: .primaryButton,
                    cornerRadiusRatio: 0.5
                )
            ),
            action: state.action
        )
    }
}
