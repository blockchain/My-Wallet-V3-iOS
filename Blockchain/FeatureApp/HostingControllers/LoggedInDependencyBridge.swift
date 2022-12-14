// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureAppUI
import FeatureCardIssuingUI
import FeatureDashboardUI
import FeatureInterestUI
import FeatureSettingsUI
import MoneyKit
import PlatformKit
import PlatformUIKit

protocol LoggedInDependencyBridgeAPI: AnyObject {
    /// Registers the bridge
    func register(bridge: LoggedInBridge)

    /// Provides `BackupFlowStarterAPI` methods
    func resolveBackupFlowStarter() -> BackupFlowStarterAPI

    /// Provides `SettingsStarterAPI` methods
    func resolveSettingsStarter() -> SettingsStarterAPI

    /// Provides `DrawerRouting` methods
    func resolveDrawerRouting() -> DrawerRouting
    /// Provides `TabSwapping` methods
    func resolveTabSwapping() -> TabSwapping
    /// Provides `CashIdentityVerificationAnnouncementRouting` methods
    func resolveCashIdentityVerificationAnnouncementRouting() -> CashIdentityVerificationAnnouncementRouting
    /// Provides `AppCoordinating` methods
    func resolveAppCoordinating() -> AppCoordinating
    /// Provides `WalletOperationsRouting` methods
    func resolveWalletOperationsRouting() -> WalletOperationsRouting
    /// Provides `AuthenticationCoordinating` methods
    func resolveAuthenticationCoordinating() -> AuthenticationCoordinating
    /// Proves `QRCodeScannerRouting` methods
    func resolveQRCodeScannerRouting() -> QRCodeScannerRouting
    /// Provides logout
    func resolveExternalActionsProvider() -> ExternalActionsProviderAPI
    /// Provides support flow for CardIssuing
    func resolveSupportRouterAPI() -> SupportRouterAPI
}

final class LoggedInDependencyBridge: LoggedInDependencyBridgeAPI {

    private weak var hostingControllerBridge: LoggedInBridge?

    init() {}

    func register(bridge: LoggedInBridge) {
        hostingControllerBridge = bridge
    }

    func resolveBackupFlowStarter() -> BackupFlowStarterAPI {
        resolve() as BackupFlowStarterAPI
    }

    func resolveSettingsStarter() -> SettingsStarterAPI {
        resolve() as SettingsStarterAPI
    }

    func resolveDrawerRouting() -> DrawerRouting {
        resolve() as DrawerRouting
    }

    func resolveTabSwapping() -> TabSwapping {
        resolve() as TabSwapping
    }

    func resolveCashIdentityVerificationAnnouncementRouting() -> CashIdentityVerificationAnnouncementRouting {
        resolve() as CashIdentityVerificationAnnouncementRouting
    }

    func resolveAppCoordinating() -> AppCoordinating {
        resolve() as AppCoordinating
    }

    func resolveWalletOperationsRouting() -> WalletOperationsRouting {
        resolve() as WalletOperationsRouting
    }

    func resolveAuthenticationCoordinating() -> AuthenticationCoordinating {
        resolve() as AuthenticationCoordinating
    }

    func resolveQRCodeScannerRouting() -> QRCodeScannerRouting {
        resolve() as QRCodeScannerRouting
    }

    func resolveExternalActionsProvider() -> ExternalActionsProviderAPI {
        resolve() as ExternalActionsProviderAPI
    }

    func resolveSupportRouterAPI() -> SupportRouterAPI {
        resolve() as SupportRouterAPI
    }

    /// Resolves the underlying bridge with a type
    /// - precondition: The bridge should conform to the type
    /// - Returns: The underlying bridge as a specific protocol type
    private func resolve<T>() -> T {
        precondition(hostingControllerBridge != nil, "No bridge detected, please first use register(bridge:) method")
        precondition(hostingControllerBridge is T, "Bridge does not conform to \(T.self) protocol")
        return hostingControllerBridge as! T
    }
}

// swiftlint:disable line_length

class DynamicDependencyBridge: UIViewController, LoggedInBridge {

    private var wrapped: LoggedInBridge = SignedOutDependencyBridge()

    func register(bridge: LoggedInBridge) {
        wrapped = bridge
    }

    func toggleSideMenu() { wrapped.toggleSideMenu() }
    func closeSideMenu() { wrapped.closeSideMenu() }
    func send(from account: BlockchainAccount) { wrapped.send(from: account) }
    func send(from account: BlockchainAccount, target: TransactionTarget) { wrapped.send(from: account, target: target) }
    func sign(from account: BlockchainAccount, target: TransactionTarget) { wrapped.sign(from: account, target: target) }
    func receive(into account: BlockchainAccount) { wrapped.receive(into: account) }
    func withdraw(from account: BlockchainAccount) { wrapped.withdraw(from: account) }
    func deposit(into account: BlockchainAccount) { wrapped.deposit(into: account) }
    func interestTransfer(into account: BlockchainAccount) { wrapped.interestTransfer(into: account) }
    func interestWithdraw(from account: BlockchainAccount) { wrapped.interestWithdraw(from: account) }
    func switchTabToDashboard() { wrapped.switchTabToDashboard() }
    func switchToSend() { wrapped.switchToSend() }
    func switchTabToReceive() { wrapped.switchTabToReceive() }
    func switchToActivity() { wrapped.switchToActivity() }
    func switchToActivity(for currencyType: CurrencyType) { wrapped.switchToActivity() }
    func startBackupFlow() { wrapped.startBackupFlow() }
    func showSettingsView() { wrapped.showSettingsView() }
    func presentKYCIfNeeded() { wrapped.presentKYCIfNeeded() }
    func presentBuyIfNeeded(_ cryptoCurrency: CryptoCurrency) { wrapped.presentBuyIfNeeded(cryptoCurrency) }
    func enableBiometrics() { wrapped.enableBiometrics() }
    func changePin() { wrapped.changePin() }
    func showQRCodeScanner() { wrapped.showQRCodeScanner() }
    func handleSwapCrypto(account: CryptoAccount?) { wrapped.handleSwapCrypto(account: account) }
    func handleSellCrypto(account: CryptoAccount?) { wrapped.handleSellCrypto(account: account) }
    func handleBuyCrypto(account: CryptoAccount?) { wrapped.handleBuyCrypto(account: account) }
    func handleBuyCrypto(currency: CryptoCurrency) { wrapped.handleBuyCrypto(currency: currency) }
    func showCashIdentityVerificationScreen() { wrapped.showCashIdentityVerificationScreen() }
    func showFundTrasferDetails(fiatCurrency: FiatCurrency, isOriginDeposit: Bool) { wrapped.showFundTrasferDetails(fiatCurrency: fiatCurrency, isOriginDeposit: isOriginDeposit) }
    func switchTabToSwap() { wrapped.switchTabToSwap() }
    func logout() { wrapped.logout() }
    func handleSupport() { wrapped.handleSupport() }
    func handleSecureChannel() { wrapped.handleSecureChannel() }
    func logoutAndForgetWallet() { wrapped.logoutAndForgetWallet() }
}

class SignedOutDependencyBridge: UIViewController, LoggedInBridge {
    func toggleSideMenu() {}
    func closeSideMenu() {}
    func send(from account: BlockchainAccount) {}
    func send(from account: BlockchainAccount, target: TransactionTarget) {}
    func sign(from account: BlockchainAccount, target: TransactionTarget) {}
    func receive(into account: BlockchainAccount) {}
    func withdraw(from account: BlockchainAccount) {}
    func deposit(into account: BlockchainAccount) {}
    func interestTransfer(into account: BlockchainAccount) {}
    func interestWithdraw(from account: BlockchainAccount) {}
    func switchTabToDashboard() {}
    func switchToSend() {}
    func switchTabToReceive() {}
    func switchToActivity() {}
    func switchToActivity(for currencyType: CurrencyType) {}
    func startBackupFlow() {}
    func showSettingsView() {}
    func presentKYCIfNeeded() {}
    func presentBuyIfNeeded(_ cryptoCurrency: CryptoCurrency) {}
    func enableBiometrics() {}
    func changePin() {}
    func showQRCodeScanner() {}
    func handleSwapCrypto(account: CryptoAccount?) {}
    func handleSellCrypto(account: CryptoAccount?) {}
    func handleBuyCrypto(account: CryptoAccount?) {}
    func handleBuyCrypto(currency: CryptoCurrency) {}
    func showCashIdentityVerificationScreen() {}
    func showFundTrasferDetails(fiatCurrency: FiatCurrency, isOriginDeposit: Bool) {}
    func switchTabToSwap() {}
    func logout() {}
    func handleSupport() {}
    func handleSecureChannel() {}
    func logoutAndForgetWallet() {}
}
