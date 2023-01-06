// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Localization
import PlatformKit
import PlatformUIKit
import ToolKit

struct DisplayBundle {

    let title: String
    let amountDisplayBundle: AmountTranslationPresenter.DisplayBundle

    init(
        title: String,
        amountDisplayBundle: AmountTranslationPresenter.DisplayBundle
    ) {
        self.title = title
        self.amountDisplayBundle = amountDisplayBundle
    }

    static func bundle(for action: AssetAction, sourceAccount: SingleAccount, destinationAccount: TransactionTarget) -> DisplayBundle {
        switch action {
        case .swap:
            return .swap(sourceAccount: sourceAccount)
        case .send:
            return .send(sourceAccount: sourceAccount)
        case .withdraw:
            return .withdraw(sourceAccount: sourceAccount)
        case .interestWithdraw:
            return .interestWithdraw(sourceAccount: sourceAccount)
        case .interestTransfer:
            return .interestTransfer(sourceAccount: sourceAccount)
        case .stakingDeposit:
            return .stakingDeposit(sourceAccount: sourceAccount)
        case .deposit:
            return .deposit(sourceAccount: sourceAccount)
        case .buy:
            guard let account = destinationAccount as? CryptoAccount else {
                impossible("You can only buy crypto assets.")
            }
            return .buy(sourceAccount: sourceAccount, destinationAccount: account)
        case .sell:
            return .sell(sourceAccount: sourceAccount)
        case .sign,
             .receive,
             .viewActivity:
            unimplemented()
        }
    }
}
