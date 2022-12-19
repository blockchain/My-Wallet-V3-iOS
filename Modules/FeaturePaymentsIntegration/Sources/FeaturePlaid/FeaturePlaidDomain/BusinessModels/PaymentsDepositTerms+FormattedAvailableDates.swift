// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import ToolKit

private let loc = LocalizationConstants.Transaction.Confirmation.DepositTermsAvailableDisplayMode.self

extension PaymentsDepositTerms {

    public var formattedAvailableToTrade: String? {
        formattedDepositTerms(
            displayMode: availableToTradeDisplayMode,
            min: availableToTradeMinutesMin,
            max: availableToTradeMinutesMax
        )
    }

    public var formattedAvailableToWithdraw: String? {
        formattedDepositTerms(
            displayMode: availableToWithdrawDisplayMode,
            min: availableToWithdrawMinutesMin,
            max: availableToWithdrawMinutesMax
        )
    }

    private func formattedDepositTerms(
        displayMode: DisplayMode,
        min: Int,
        max: Int
    ) -> String? {
        let minDate = Date().addingTimeInterval(TimeInterval(min * 60))
        let maxDate = Date().addingTimeInterval(TimeInterval(max * 60))

        switch displayMode {
        case .immediately:
            return loc.immediately
        case .maxMinute:
            let minutes = {
                let formatter = DateComponentsFormatter()
                formatter.allowedUnits = [.minute]
                formatter.unitsStyle = .full
                return formatter.string(from: TimeInterval(max * 60)) ?? ""
            }()
            return String(format: loc.maxMinute, "\(minutes)")
        case .maxDay:
            return DateFormatter.mediumWithoutYear.string(from: maxDate)
        case .minuteRange:
            return String(format: loc.minuteRange, "\(min)", "\(max)")
        case .dayRange:
            return String(
                format: loc.dayRange,
                DateFormatter.mediumWithoutYear.string(from: minDate),
                DateFormatter.mediumWithoutYear.string(from: maxDate)
            )
        case .none:
            return nil
        default:
            return nil
        }
    }

    public var formattedWithdrawalLockDays: String? {
        guard let days = withdrawalLockDays else { return nil }
        return "\(days) " + (days == 1 ? loc.dayUnitSingular : loc.dayUnitPlural)
    }
}
