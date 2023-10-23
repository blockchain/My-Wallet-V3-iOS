import BlockchainNamespace
import Combine
import ComposableArchitecture
import FeatureBackupRecoveryPhraseDomain
import PlatformKit
import UIKit

public struct ViewRecoveryPhrase: Reducer {

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

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    do {
                        let words = try await recoveryPhraseVerifyingService
                            .recoveryPhraseComponents()
                            .await()
                        await send(.onRecoveryPhraseComponentsFetchSuccess(words))
                    } catch {
                        await send(.onRecoveryPhraseComponentsFetchedFailed)
                    }
                }

            case .onRecoveryPhraseComponentsFetchSuccess(let words):
                state.availableWords = words
                return .none

            case .onRecoveryPhraseComponentsFetchedFailed:
                onFailed()
                return .none

            case .onCopyTap:
                state.recoveryPhraseCopied = true
                UIPasteboard.general.string = state.availableWords.recoveryPhrase

                return .run { send in
                    try await Task.sleep(nanoseconds: NSEC_PER_SEC * 20)
                    await send(.onCopyReturn)
                }
            case .onCopyReturn:
                state.recoveryPhraseCopied = false
                UIPasteboard.general.clear()
                return .none

            case .onBackupToIcloudTap:
                state.backupLoading = true
                cloudBackupService.cloudBackupEnabled = true
                return .run { send in
                    do {
                        try await recoveryPhraseVerifyingService
                            .markBackupVerified()
                            .map { _ in
                                recoveryPhraseRepository.updateMnemonicBackup()
                            }
                            .await()
                        await send(.onBackupToIcloudComplete)
                    } catch {
                        await send(.onBackupToIcloudComplete)
                    }
                }

            case .onBackupToIcloudComplete:
                state.backupLoading = false
                onIcloudBackedUp()
                return .none

            case .onBackupManuallyTap:
                UIPasteboard.general.clear()
                onNext()
                return .none

            case .onBlurViewTouch:
                state.blurEnabled = false
                if state.exposureEmailSent == false {
                    state.exposureEmailSent = true
                    return .publisher {
                        recoveryPhraseRepository
                            .sendExposureAlertEmail()
                            .catch { _ in Just(()) }
                            .map { .none }
                            .receive(on: mainQueue)
                    }
                }
                return .none

            case .onBlurViewRelease:
                state.blurEnabled = true
                return .none

            case .onDoneTap:
                onDone()
                return .none
            case .none:
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
