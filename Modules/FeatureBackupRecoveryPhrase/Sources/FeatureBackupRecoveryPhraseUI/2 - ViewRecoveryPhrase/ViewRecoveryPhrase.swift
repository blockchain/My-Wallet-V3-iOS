import BlockchainNamespace
import ComposableArchitecture
import FeatureBackupRecoveryPhraseDomain
import PlatformKit
import UIKit

public struct ViewRecoveryPhrase: ReducerProtocol {

    public typealias State = ViewRecoveryPhraseState
    public typealias Action = ViewRecoveryPhraseAction

    public let mainQueue: AnySchedulerOf<DispatchQueue>
    public let onNext: () -> Void
    public let onDone: () -> Void
    public let onFailed: () -> Void
    public let onIcloudBackedUp: () -> Void
    public let recoveryPhraseVerifyingService: RecoveryPhraseVerifyingServiceAPI
    public let recoveryPhraseRepository: RecoveryPhraseRepositoryAPI
    public let cloudBackupService: CloudBackupConfiguring

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        recoveryPhraseRepository: RecoveryPhraseRepositoryAPI,
        recoveryPhraseService: RecoveryPhraseVerifyingServiceAPI,
        cloudBackupService: CloudBackupConfiguring,
        onNext: @escaping () -> Void,
        onDone: @escaping () -> Void,
        onFailed: @escaping () -> Void,
        onIcloudBackedUp: @escaping () -> Void
    ) {
        self.mainQueue = mainQueue
        self.cloudBackupService = cloudBackupService
        self.recoveryPhraseVerifyingService = recoveryPhraseService
        self.recoveryPhraseRepository = recoveryPhraseRepository
        self.onNext = onNext
        self.onDone = onDone
        self.onFailed = onFailed
        self.onIcloudBackedUp = onIcloudBackedUp
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return recoveryPhraseVerifyingService
                    .recoveryPhraseComponents()
                    .catchToEffect()
                    .map { result in
                        switch result {
                        case .success(let words):
                            return .onRecoveryPhraseComponentsFetchSuccess(words)
                        case .failure:
                            return .onRecoveryPhraseComponentsFetchedFailed
                        }
                    }

            case .onRecoveryPhraseComponentsFetchSuccess(let words):
                state.availableWords = words
                return .none

            case .onRecoveryPhraseComponentsFetchedFailed:
                return .fireAndForget {
                    onFailed()
                }

            case .onCopyTap:
                state.recoveryPhraseCopied = true

                return .merge(
                    .fireAndForget { [availableWords = state.availableWords] in
                        UIPasteboard.general.string = availableWords.recoveryPhrase
                    },
                    EffectTask(value: .onCopyReturn)
                        .delay(
                            for: 20,
                            scheduler: mainQueue
                        )
                        .eraseToEffect()
                )
            case .onCopyReturn:
                state.recoveryPhraseCopied = false
                return .fireAndForget {
                    UIPasteboard.general.clear()
                }

            case .onBackupToIcloudTap:
                state.backupLoading = true
                cloudBackupService.cloudBackupEnabled = true
                return recoveryPhraseVerifyingService
                    .markBackupVerified()
                    .map { _ in
                        recoveryPhraseRepository.updateMnemonicBackup()
                    }
                    .receive(on: mainQueue)
                    .catchToEffect()
                    .map { result in
                        switch result {
                        case .success:
                            return .onBackupToIcloudComplete
                        case .failure:
                            return .onBackupToIcloudComplete
                        }
                    }

            case .onBackupToIcloudComplete:
                state.backupLoading = false
                return .fireAndForget {
                    onIcloudBackedUp()
                }

            case .onBackupManuallyTap:
                UIPasteboard.general.clear()
                onNext()
                return .none

            case .onBlurViewTouch:
                state.blurEnabled = false
                if state.exposureEmailSent == false {
                    state.exposureEmailSent = true
                    return recoveryPhraseRepository
                        .sendExposureAlertEmail()
                        .fireAndForget()
                }
                return .none

            case .onBlurViewRelease:
                state.blurEnabled = true
                return .none

            case .onDoneTap:
                onDone()
                return .none
            }
        }
    }
}

extension UIPasteboard {

    func clear() {
        UIPasteboard.general.items = []
    }
}
