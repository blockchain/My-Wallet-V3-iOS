import ComposableArchitecture
import FeatureBackupRecoveryPhraseDomain
import SwiftUI

public struct VerifyRecoveryPhraseState: Equatable {
    public enum BackupPhraseStatus: Equatable {
        case idle
        case readyToVerify
        case failed
        case success
        case loading
    }

    var selectedWords: [RecoveryPhraseWord] = []
    var availableWords: [RecoveryPhraseWord]
    var shuffledAvailableWords: [RecoveryPhraseWord] = []
    var backupPhraseStatus: BackupPhraseStatus = .idle
    var ctaButtonDisabled: Bool {
        backupPhraseStatus != .readyToVerify
    }

    @BindingState var backupRemoteFailed: Bool = false

    public init(
        selectedWords: [RecoveryPhraseWord] = [],
        availableWords: [RecoveryPhraseWord] = [],
        shuffledWords: [RecoveryPhraseWord] = [],
        backupPhraseStatus: VerifyRecoveryPhraseState.BackupPhraseStatus = .idle,
        backupRemoteFailed: Bool = false
    ) {
        self.selectedWords = selectedWords
        self.availableWords = availableWords
        self.shuffledAvailableWords = shuffledWords
        self.backupPhraseStatus = backupPhraseStatus
        self.backupRemoteFailed = backupRemoteFailed
    }
}
