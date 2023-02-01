import BlockchainUI
import ComposableArchitecture
import Localization
import SwiftUI

public struct BackupRecoveryPhraseSuccessView: View {
    typealias Localization = LocalizationConstants.BackupRecoveryPhrase.BackupRecoveryPhraseSuccessScreen
    let store: Store<BackupRecoveryPhraseSuccessState, BackupRecoveryPhraseSuccessAction>
    @ObservedObject var viewStore: ViewStore<BackupRecoveryPhraseSuccessState, BackupRecoveryPhraseSuccessAction>
    @BlockchainApp var app

    public init(store: Store<BackupRecoveryPhraseSuccessState, BackupRecoveryPhraseSuccessAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    public var body: some View {
        VStack(spacing: 0) {
                Spacer()
                Image("lock_success", bundle: Bundle.featureBackupRecoveryPhrase)
                    .frame(width: 72, height: 72)
                    .padding(.bottom, Spacing.padding3)
                Text(Localization.title)
                    .typography(.title3)
                    .padding(.bottom, Spacing.padding1)
            Text(Localization.description)
                    .typography(.body1)
                    .multilineTextAlignment(.center)
                Spacer()
                Spacer()
            PrimaryButton(title: Localization.doneButton) {
                    viewStore.send(.onDoneTapped)
            }
            .padding(.bottom, Spacing.padding2)
        }
        .onAppear {
            app.post(event: blockchain.ux.backup.seed.phrase.flow.backup.success)
        }
            .navigationBarBackButtonHidden()
            .primaryNavigation(trailing: {
                Button {
                    viewStore.send(.onDoneTapped)
                } label: {
                    Icon
                        .closev2
                        .circle(backgroundColor: .WalletSemantic.light)
                        .frame(width: 24, height: 24)
                }
            })
            .padding(.horizontal, Spacing.padding3)
    }
}

struct BackupRecoveryPhraseSuccessView_Previews: PreviewProvider {
    static var previews: some View {
        BackupRecoveryPhraseSuccessView(store: .init(
            initialState: .init(),
            reducer: BackupRecoveryPhraseSuccessModule.reducer,
            environment: .init(onNext: {}
            )
        ))
    }
}
