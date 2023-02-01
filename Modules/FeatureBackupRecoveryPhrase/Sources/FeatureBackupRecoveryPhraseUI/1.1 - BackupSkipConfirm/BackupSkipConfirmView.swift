import BlockchainUI
import ComposableArchitecture
import Localization
import SwiftUI

public struct BackupSkipConfirmView: View {
    typealias Localization = LocalizationConstants.BackupRecoveryPhrase.SkipConfirmScreen
    let store: Store<BackupSkipConfirmState, BackupSkipConfirmAction>
    @ObservedObject var viewStore: ViewStore<BackupSkipConfirmState, BackupSkipConfirmAction>
    @Environment(\.presentationMode) private var presentationMode
    @BlockchainApp var app

    public init(store: Store<BackupSkipConfirmState, BackupSkipConfirmAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    public var body: some View {
        PrimaryNavigationView {
            VStack(spacing: 0) {
                Spacer()
                Image("lock_warning", bundle: Bundle.featureBackupRecoveryPhrase)
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
                    PrimaryButton(title: Localization.confirmButton) {
                        app.post(event: blockchain.ux.backup.seed.phrase.flow.skip)
                        viewStore.send(.onConfirmTapped)
                    }

                    MinimalButton(title: Localization.backupButton) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .padding(.horizontal, Spacing.padding3)
            .padding(.bottom, Spacing.padding2)
        }
    }
}

struct BackupSkipConfirmView_Previews: PreviewProvider {
    static var previews: some View {
        BackupSkipConfirmView(store: .init(
            initialState: .init(),
            reducer: BackupSkipConfirmModule.reducer,
            environment: .init(
                onConfirm: {}
            )
        ))
    }
}
