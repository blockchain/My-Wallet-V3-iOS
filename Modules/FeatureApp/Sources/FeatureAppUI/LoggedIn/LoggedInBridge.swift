// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureDashboardUI
import FeatureInterestUI
import FeatureSettingsUI
import MoneyKit
import PlatformKit
import PlatformUIKit

// These protocols are added here for simplicity,
// these are adopted both by `LoggedInHostingController` and `AppCoordinator`
// The methods and properties provided by these protocol where used by accessing the `.shared` property of AppCoordinator

/// Provides the ability to start a backup flow
public protocol BackupFlowStarterAPI: AnyObject {
    func startBackupFlow()
}

/// Provides the ability to show settings
public protocol SettingsStarterAPI: AnyObject {
    func showSettingsView()
}

/// This protocol conforms to a set of certain protocols that were used as part of the
/// older `AppCoordinator` class which was passed around using it's `shared` property
/// This attempts to bridge the two worlds of the `LoggedInHostingController` and any
/// class that uses the extended protocols.
public protocol LoggedInBridge: DrawerRouting,
    TabSwapping,
    CashIdentityVerificationAnnouncementRouting,
    AppCoordinating,
    WalletOperationsRouting,
    BackupFlowStarterAPI,
    SettingsStarterAPI,
    InterestAccountListHostingControllerDelegate,
    AuthenticationCoordinating,
    QRCodeScannerRouting,
    ExternalActionsProviderAPI {}
