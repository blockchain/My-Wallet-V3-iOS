import BlockchainNamespace
import Combine
import ComposableArchitecture
import DIKit
import FeatureSettingsUI
import MoneyKit
import ToolKit

public struct AppModeSwitcherState: Equatable {
    let totalAccountBalance: MoneyValue?
    let defiAccountBalance: MoneyValue?
    let brokerageAccountBalance: MoneyValue?
    var currentAppMode: AppMode

    var recoveryPhraseBackedUp: Bool = false
    var recoveryPhraseSkipped: Bool = false
    @BindingState var userHasBeenDefaultedToPKW: Bool = false

    public init(
        totalAccountBalance: MoneyValue?,
        defiAccountBalance: MoneyValue?,
        brokerageAccountBalance: MoneyValue?,
        currentAppMode: AppMode
    ) {
        self.totalAccountBalance = totalAccountBalance
        self.defiAccountBalance = defiAccountBalance
        self.brokerageAccountBalance = brokerageAccountBalance
        self.currentAppMode = currentAppMode
    }
}
