// Copyright © Blockchain Luxembourg S.A. All rights reserved.

// swiftlint:disable all

import Foundation

// MARK: Groups

extension LocalizationConstants {
    public enum BackupRecoveryPhrase {
        public enum ViewIntroScreen {}
        public enum SkipConfirmScreen {}
        public enum BackupRecoveryPhraseFailedScreen {}
        public enum ViewRecoveryPhraseScreen {}
        public enum ManualBackupRecoveryPhraseScreen {}
        public enum VerifyRecoveryPhraseScreen {}
        public enum BackupRecoveryPhraseSuccessScreen {}
    }
}

// MARK: BackupFundsScreen

extension LocalizationConstants.BackupRecoveryPhrase {
    public static let skipButton = NSLocalizedString("Skip", comment: "Skip")
    public static let doneButton = NSLocalizedString("Done", comment: "Done")
}

extension LocalizationConstants.BackupRecoveryPhrase.ViewIntroScreen {
    public static let navigationTitle = NSLocalizedString("Back-up your DeFi Wallet", comment: "Navbar title.")
    public static let title = NSLocalizedString("Let’s back up your wallet", comment: "Screen title.")
    public static let description = NSLocalizedString("Your recovery phrase will allow you to access your wallet if you ever get locked out", comment: "Description")
    public static let rowText1 = NSLocalizedString("If I lose my recovery phrase, I will not be able to access my funds", comment: "Row Text 1")
    public static let rowText2 = NSLocalizedString("If I expose or share my recovery phrase with anyone, my funds are at risk", comment: "Row Text 2")
    public static let rowText3 = NSLocalizedString("It is my responsibility to write down my recovery phrase and keep it secure", comment: "Row Text 3")
    public static let backupButton = NSLocalizedString("Back-up Now", comment: "Back-up Now")
    public static let skipButton = NSLocalizedString("Skip", comment: "Skip")
    public static let tagBackedUp = NSLocalizedString("Backed up", comment: "Backed up")
    public static let tagNotBackedUp = NSLocalizedString("Not backed up", comment: "Not Backed up")
}

extension LocalizationConstants.BackupRecoveryPhrase.SkipConfirmScreen {
    public static let title = NSLocalizedString("Are you sure you want to skip your DeFi Wallet backup?", comment: "Question")
    public static let description = NSLocalizedString("If you don’t create a backup and lose your password, you risk losing access to your funds permanently.", comment: "Description")
    public static let confirmButton = NSLocalizedString("Yes, Skip Backup", comment: "Yes, Skip Backup")
    public static let backupButton = NSLocalizedString("Back Up(Recommended)", comment: "Back Up(Recommended)")
}

extension LocalizationConstants.BackupRecoveryPhrase.ViewRecoveryPhraseScreen {
    public static let navigationTitle = NSLocalizedString("Secure Your %@", comment: "Note: Placeholder is replaced by DeFi Wallet")
    public static let title = NSLocalizedString("Your Recovery Phrase", comment: "Title")
    public static let caption = NSLocalizedString("These 12 words give you access to your DeFi Wallet. Please back them up to the cloud or write them down manually.", comment: "These 12 words give you access to your DeFi Wallet. Please back them up to the cloud or write them down manually.")
    public static let doneButton = NSLocalizedString("Done", comment: "Done")
    public static let backupToIcloudButton = NSLocalizedString("Backup to iCloud", comment: "Backup to iCloud")
    public static let backupManuallyButton = NSLocalizedString("Backup Manually", comment: "Backup Manually")
    public static let copyButton = NSLocalizedString("Copy", comment: "Copy")
    public static let copiedButton = NSLocalizedString("Copied for 2 Minutes", comment: "Copied for 2 Minutes")
    public static let tagBackedUp = NSLocalizedString("Backed Up", comment: "Backed Up")
    public static let tagNotBackedUp = NSLocalizedString("Not Backed Up", comment: "Not Backed Up")
}

extension LocalizationConstants.BackupRecoveryPhrase.ManualBackupRecoveryPhraseScreen {
    public static let navigationTitle = NSLocalizedString("Step 1 of 2", comment: "Step 1 of 2")
    public static let title = NSLocalizedString("Manual Back Up", comment: "Manual Back Up")
    public static let caption = NSLocalizedString("Copy them to a password manager or write them down. Make sure to keep it handy, the next step is to verify your phrase.", comment: "Copy them to a password manager or write them down. Make sure to keep it handy, the next step is to verify your phrase.")
    public static let nextButton = NSLocalizedString("Next", comment: "Next")
    public static let copyButton = NSLocalizedString("Copy", comment: "Copy")
    public static let copiedButton = NSLocalizedString("Copied for 2 Minutes", comment: "Copied for 2 Minutes")
}

extension LocalizationConstants.BackupRecoveryPhrase.VerifyRecoveryPhraseScreen {
    public static let navigationTitle = NSLocalizedString("Step 2 of 2", comment: "Step 2 of 2")
    public static let title = NSLocalizedString("Verify your Phrase", comment: "Verify your Phrase")
    public static let description = NSLocalizedString("Tap the words to put them in the correct order.", comment: "Tap the words to put them in the correct order.")
    public static let verifyButton = NSLocalizedString("Verify", comment: "Verify")
    public static let resetWordsButton = NSLocalizedString("Reset Words", comment: "Reset Words")
    public static let errorLabel = NSLocalizedString("Incorrect order. Reset or tap individual words to remove.", comment: "Incorrect order. Reset or tap individual words to remove.")
    public static let backupFailedAlertTitle = NSLocalizedString("Failed to record backup", comment: "Failed to record backup")
    public static let backupFailedAlertDescription = NSLocalizedString("We couldn’t record that you backed up your phrase. Try again later.", comment: "We couldn’t record that you backed up your phrase. Try again later.")
    public static let backupFailedAlertOkButton = NSLocalizedString("OK", comment: "OK")
}

extension LocalizationConstants.BackupRecoveryPhrase.BackupRecoveryPhraseFailedScreen {
    public static let title = NSLocalizedString("We couldn’t decrypt your seed phrase", comment: "Failed title")
    public static let description = NSLocalizedString("Please restart the app and try again. If it doesn't work, our team may need to investigate further.", comment: "Failed description")
    public static let reportABugButton = NSLocalizedString("Report Bug", comment: "Report Bug")
    public static let okButton = NSLocalizedString("OK", comment: "OK")
}

extension LocalizationConstants.BackupRecoveryPhrase.BackupRecoveryPhraseSuccessScreen {
    public static let title = NSLocalizedString("DeFi Wallet back up successful!", comment: "DeFi Wallet back up successful!")
    public static let description = NSLocalizedString("Remember to keep your recovery phrase stored in a safe location and to never share it with anyone.", comment: "Remember to keep your recovery phrase stored in a safe location and to never share it with anyone.")
    public static let doneButton = NSLocalizedString("Done", comment: "Done")
}
