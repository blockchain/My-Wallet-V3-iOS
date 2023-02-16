import BlockchainNamespace
import Combine
import ComposableArchitecture
import DIKit
import FeatureSettingsUI
import MoneyKit
import ToolKit

public struct AppModeSwitcherState: Equatable {
    @BindableState var isDefiIntroPresented = false
    var defiWalletState: DefiWalletIntro.State
    let totalAccountBalance: MoneyValue?
    let defiAccountBalance: MoneyValue?
    let brokerageAccountBalance: MoneyValue?
    var currentAppMode: AppMode
    var shouldShowDefiModeIntro: Bool { !(recoveryPhraseBackedUp || recoveryPhraseSkipped) && !userHasBeenDefaultedToPKW }
    var shouldShowRecoveryFlow: Bool { !(recoveryPhraseBackedUp || recoveryPhraseSkipped) && userHasBeenDefaultedToPKW }

    var recoveryPhraseBackedUp: Bool = false
    var recoveryPhraseSkipped: Bool = false
    @BindableState var userHasBeenDefaultedToPKW: Bool = false

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

        self.defiWalletState = .init()
    }
}
