import BlockchainComponentLibrary
import ComposableArchitecture
import Localization
import SwiftUI

public struct BackupRecoveryPhraseFailedView: View {
    typealias Localization = LocalizationConstants.BackupRecoveryPhrase.BackupRecoveryPhraseFailedScreen
    let store: Store<BackupRecoveryPhraseFailedState, BackupRecoveryPhraseFailedAction>
    @ObservedObject var viewStore: ViewStore<BackupRecoveryPhraseFailedState, BackupRecoveryPhraseFailedAction>

    public init(store: Store<BackupRecoveryPhraseFailedState, BackupRecoveryPhraseFailedAction>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    public var body: some View {
        PrimaryNavigationView {
            VStack(spacing: 0) {
                Spacer()
                Image("lock_failed", bundle: Bundle.featureBackupRecoveryPhrase)
                    .frame(width: 72, height: 72)
                    .padding(.bottom, Spacing.padding3)
                Text(Localization.title)
                    .typography(.title3)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, Spacing.padding1)
                Text(Localization.description)
                    .typography(.body1)
                    .multilineTextAlignment(.center)
                Spacer()
                Spacer()
                VStack {
                    MinimalButton(title: Localization.reportABugButton) {
                        viewStore.send(.onReportABugTapped)
                    }

                    PrimaryButton(title: Localization.okButton) {
                        viewStore.send(.onOkTapped)
                    }
                }
            }
            .padding(.horizontal, Spacing.padding3)
        }
    }
}
