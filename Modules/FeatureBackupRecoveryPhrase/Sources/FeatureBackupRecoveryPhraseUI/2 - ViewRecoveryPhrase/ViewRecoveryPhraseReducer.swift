import BlockchainNamespace
import ComposableArchitecture
import UIKit

public enum ViewRecoveryPhraseModule {}

extension ViewRecoveryPhraseModule {
    public static var reducer: Reducer<ViewRecoveryPhraseState, ViewRecoveryPhraseAction, ViewRecoveryPhraseEnvironment> {
        .init { state, action, environment in
            switch action {
            case .onAppear:
                return environment
                    .recoveryPhraseVerifyingService
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
                    environment.onFailed()
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
                            scheduler: environment.mainQueue
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
                environment.cloudBackupService.cloudBackupEnabled = true
                return environment
                    .recoveryPhraseVerifyingService
                    .markBackupVerified()
                    .map { _ in
                        environment.recoveryPhraseRepository.updateMnemonicBackup()
                    }
                    .receive(on: environment.mainQueue)
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
                    environment.onIcloudBackedUp()
                }

            case .onBackupManuallyTap:
                UIPasteboard.general.clear()
                environment.onNext()
                return .none

            case .onBlurViewTouch:
                state.blurEnabled = false
                if state.exposureEmailSent == false {
                    state.exposureEmailSent = true
                    return environment
                        .recoveryPhraseRepository
                        .sendExposureAlertEmail()
                        .fireAndForget()
                }
                return .none

            case .onBlurViewRelease:
                state.blurEnabled = true
                return .none

            case .onDoneTap:
                environment.onDone()
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
