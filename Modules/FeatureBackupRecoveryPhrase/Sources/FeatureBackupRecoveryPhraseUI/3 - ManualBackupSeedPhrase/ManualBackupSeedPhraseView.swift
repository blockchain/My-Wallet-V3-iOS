import BlockchainComponentLibrary
import ComposableArchitecture
import DIKit
import FeatureBackupRecoveryPhraseDomain
import Localization
import SwiftUI

public struct ManualBackupSeedPhraseView: View {
    typealias Localization = LocalizationConstants.BackupRecoveryPhrase.ManualBackupRecoveryPhraseScreen
    let store: Store<ManualBackupSeedPhraseState, ManualBackupSeedPhraseAction>
    @ObservedObject var viewStore: ViewStore<ManualBackupSeedPhraseState, ManualBackupSeedPhraseAction>

    public init(store: Store<ManualBackupSeedPhraseState, ManualBackupSeedPhraseAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    public var body: some View {
        VStack {
            Text(Localization.title)
                .typography(.title2)
            wordsSection
            copyButton
            captionSection
            Spacer()
            buttonsSection
        }
        .onAppear {
            viewStore.send(.onAppear)
        }
        .navigationBarBackButtonHidden()
        .navigationBarTitle(Localization.navigationTitle)
    }
}

extension ManualBackupSeedPhraseView {
    var wordsSection: some View {
        VStack {
            ForEach(viewStore.availableWords.chunks(ofCount: 3), id: \.self) { words in
                if words.isNotEmpty {
                    HStack {
                        ForEach(Array(words.indexed()), id: \.element) { index, word in
                            wordView(
                                index: index + 1,
                                word: word
                            )
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .border(Color.WalletSemantic.medium, width: 1)
        .padding(.horizontal, Spacing.padding3)
        .padding(.top, Spacing.padding2)
    }

    var captionSection: some View {
        Text(Localization.caption.interpolating(NonLocalizedConstants.defiWalletTitle))
            .typography(.paragraph1)
            .multilineTextAlignment(.center)
            .padding(.top, Spacing.padding3)
            .padding(.horizontal, Spacing.padding3)
    }

    @ViewBuilder func wordView(index: Int, word: RecoveryPhraseWord) -> some View {
        HStack(spacing: Spacing.padding1) {
            Text("\(index)")
                .foregroundColor(.WalletSemantic.muted)
        Text("\(word.label)")
             .foregroundColor(Color.WalletSemantic.title)
        }
            .typography(.paragraph2)
            .fixedSize()
            .lineLimit(1)
            .padding(.vertical, Spacing.padding1)
            .frame(maxWidth: .infinity)
            .background(Color.semantic.background)
    }

    var copyButton: some View {
        Button {
            viewStore.send(.onCopyTap)
        } label: {
            Text(viewStore.recoveryPhraseCopied ? Localization.copiedButton : Localization.copyButton)
                .foregroundColor(viewStore.recoveryPhraseCopied ? Color.WalletSemantic.success : Color.WalletSemantic.primary)
        }
        .padding(.top, Spacing.padding2)
    }

    var buttonsSection: some View {
        VStack {
            PrimaryButton(title: Localization.nextButton) {
                viewStore.send(.onNextTap)
            }
        }
        .padding(.horizontal, Spacing.padding3)
        .padding(.bottom, Spacing.padding3)
    }
}

struct ManualBackupSeedPhraseView_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryNavigationView {
            ManualBackupSeedPhraseView(store: .init(
                initialState: .init(),
                reducer: ManualBackupSeedPhraseModule.reducer,
                environment: .init(
                    onNext: {},
                    recoveryPhraseVerifyingService: resolve()
                )
            ))
        }
    }
}
