import BlockchainComponentLibrary
import ComposableArchitecture
import DIKit
import FeatureBackupRecoveryPhraseDomain
import Localization
import SwiftUI

public struct VerifyRecoveryPhraseView: View {
    typealias Localization = LocalizationConstants.BackupRecoveryPhrase.VerifyRecoveryPhraseScreen
    let store: Store<VerifyRecoveryPhraseState, VerifyRecoveryPhraseAction>
    @ObservedObject var viewStore: ViewStore<VerifyRecoveryPhraseState, VerifyRecoveryPhraseAction>

    public init(store: Store<VerifyRecoveryPhraseState, VerifyRecoveryPhraseAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    public var body: some View {
        VStack {
            titleView
                .padding(.bottom, Spacing.padding2)
            subTitleView
                .padding(.bottom, Spacing.padding4)
            selectionView
                .padding()
            if viewStore.backupPhraseStatus == .idle {
                availableWordsView
            } else if viewStore.backupPhraseStatus == .failed {
                failedSection
                    .padding(.top, Spacing.padding3)
            }
            Spacer()
            buttonsSection
        }
        .onAppear {
            viewStore.send(.onAppear)
        }
        .padding(.horizontal, Spacing.padding3)
        .navigationBarBackButtonHidden()
        .navigationBarTitle(Localization.navigationTitle)
    }

    var titleView: some View {
        Text(Localization.title)
            .typography(.title2)
    }

    var subTitleView: some View {
        Text(Localization.description)
            .typography(.paragraph1)
    }

    var selectionView: some View {
        VStack {
            HStack {
                ForEach(
                    Array(viewStore.selectedWords.enumerated()),
                    id: \.offset
                ) { index, word in
                    if (0..<3).contains(index) {
                        selectedWordView(
                            index: index + 1,
                            word: word
                        )
                    }
                }
            }

            HStack {
                ForEach(
                    Array(viewStore.selectedWords.enumerated()),
                    id: \.offset
                ) { index, word in
                    if (3..<6).contains(index) {
                        selectedWordView(
                            index: index + 1,
                            word: word
                        )
                    }
                }
            }

            HStack {
                ForEach(
                    Array(viewStore.selectedWords.enumerated()),
                    id: \.offset
                ) { index, word in
                    if (6..<9).contains(index) {
                        selectedWordView(
                            index: index + 1,
                            word: word
                        )
                    }
                }
            }

            HStack {
                ForEach(
                    Array(viewStore.selectedWords.enumerated()),
                    id: \.offset
                ) { index, word in
                    if (9..<12).contains(index) {
                        selectedWordView(
                            index: index + 1,
                            word: word
                        )
                    }
                }
            }
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .border(
            viewStore.backupPhraseStatus == .failed ? Color.WalletSemantic.error
            : .WalletSemantic.medium,
            width: 1
        )
        .background(Color.WalletSemantic.light)
        .alert(isPresented: viewStore.binding(\.$backupRemoteFailed)) {
            Alert(
                title: Text(Localization.backupFailedAlertTitle),
                message: Text(Localization.backupFailedAlertDescription),
                dismissButton: .default(Text(Localization.backupFailedAlertOkButton))
            )
        }
    }

    @ViewBuilder func selectedWordView(index: Int, word: RecoveryPhraseWord) -> some View {
        Button(action: {
            viewStore.send(.onSelectedWordTap(word))
        }, label: {
            HStack(spacing: Spacing.padding1) {
                Text("\(index)")
                    .foregroundColor(.WalletSemantic.muted)
                Text("\(word.label)")
                    .foregroundColor(Color.WalletSemantic.title)
            }
        })
        .padding(.horizontal, 6)
        .padding(.vertical, 12)
        .typography(.paragraph2)
        .cornerRadius(4)
        .border(Color.WalletSemantic.medium, width: 1)
        .background(Color.semantic.background)
    }

    @ViewBuilder func availableWordView(word: RecoveryPhraseWord) -> some View {
        Button(action: {
                viewStore.send(.onAvailableWordTap(word))
        }, label: {
            Text(word.label)
        })
        .padding(.horizontal, 6)
        .padding(.vertical, 12)
        .typography(.paragraph2)
        .foregroundColor(Color.WalletSemantic.title)
        .cornerRadius(4)
        .border(Color.WalletSemantic.medium, width: 1)
        .opacity(viewStore.selectedWords.contains(word) ? 0 : 1)
        .background(Color.semantic.background)
    }

    var availableWordsView: some View {
        VStack {
            ForEach(
                viewStore
                    .shuffledAvailableWords
                    .chunks(ofCount: 4),
                id: \.self
            ) { words in
                HStack {
                    ForEach(words, id: \.self) { word in
                        availableWordView(word: word)
                    }
                }
            }
        }
    }

    var buttonsSection: some View {
        VStack {
            PrimaryButton(title: Localization.verifyButton, isLoading: viewStore.backupPhraseStatus == .loading) {
                viewStore.send(.onVerifyTap)
            }
            .disabled(viewStore.ctaButtonDisabled)
        }
        .padding(.horizontal, Spacing.padding3)
        .padding(.bottom, Spacing.padding2)
    }

    var failedSection: some View {
        VStack(spacing: Spacing.padding3) {
            Button {
                viewStore.send(.onResetWordsTap)
            } label: {
                Text(Localization.resetWordsButton)
            }
            Text(Localization.errorLabel)
                .multilineTextAlignment(.center)
                .typography(.paragraph1)
                .foregroundColor(.WalletSemantic.error)
        }
    }
}

struct SeedPhraseVerifyView_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryNavigationView {
            VerifyRecoveryPhraseView(store: .init(
                initialState: .init(),
                reducer: VerifyRecoveryPhraseModule.reducer,
                environment: .init(
                    mainQueue: .main,
                    recoveryPhraseRepository: resolve(),
                    recoveryPhraseService: resolve(),
                    onNext: {}
                )
            ))
        }
    }
}
