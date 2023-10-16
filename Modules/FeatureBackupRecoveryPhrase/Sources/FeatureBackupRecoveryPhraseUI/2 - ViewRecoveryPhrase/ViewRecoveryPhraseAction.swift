import ComposableArchitecture
import FeatureBackupRecoveryPhraseDomain

public enum ViewRecoveryPhraseAction: Equatable {
    case onAppear
    case onCopyTap
    case onCopyReturn
    case onBackupToIcloudTap
    case onBackupManuallyTap
    case onBlurViewTouch
    case onBlurViewRelease
    case onDoneTap
    case onBackupToIcloudComplete
    case onRecoveryPhraseComponentsFetchSuccess([RecoveryPhraseWord])
    case onRecoveryPhraseComponentsFetchedFailed
    case none
}
