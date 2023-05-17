import BlockchainUI
import ComposableArchitecture
import DIKit
import FeatureBackupRecoveryPhraseDomain
import Localization
import SwiftUI

public struct ViewRecoveryPhraseView: View {
    typealias Localization = LocalizationConstants.BackupRecoveryPhrase.ViewRecoveryPhraseScreen
    let store: Store<ViewRecoveryPhraseState, ViewRecoveryPhraseAction>
    @ObservedObject var viewStore: ViewStore<ViewRecoveryPhraseState, ViewRecoveryPhraseAction>
    @BlockchainApp var app

    public init(store: Store<ViewRecoveryPhraseState, ViewRecoveryPhraseAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    public var body: some View {
        VStack {
            Text(Localization.title)
                .typography(.title2)
            badgeImage
            wordsSection
            if viewStore.recoveryPhraseBackedUp {
                copyButton
                    .padding(.top, Spacing.padding3)
            }
            captionSection
                .padding(.top, Spacing.padding2)
            Spacer()
            buttonsSection
        }
        .onAppear {
            viewStore.send(.onAppear)
        }
        .navigationBarBackButtonHidden()
        .navigationBarTitle(Localization.navigationTitle.interpolating(NonLocalizedConstants.defiWalletTitle))
    }
}

extension ViewRecoveryPhraseView {
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
        .blur(radius: viewStore.shouldBlurBackupPhrase ? 7 : 0)
        .border(Color.WalletSemantic.medium, width: 1)
        .padding(.horizontal, Spacing.padding3)
        .padding(.top, Spacing.padding2)
        .gesture(DragGesture(minimumDistance: 0)
            .onChanged { _ in
                viewStore.send(.onBlurViewTouch)
            }
            .onEnded { _ in
                viewStore.send(.onBlurViewRelease)
            }
        )
        .overlay(visibilityOverlay())
    }

    @ViewBuilder func visibilityOverlay() -> some View {
        if viewStore.shouldBlurBackupPhrase {
            Icon
            .visibilityOff
            .foregroundColor(.WalletSemantic.primaryMuted)
            .frame(width: 24, height: 24)
        } else {
            EmptyView()
        }
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

    var buttonsSection: some View {
        VStack {
            PrimaryButton(
                title: viewStore.recoveryPhraseBackedUp ? Localization.doneButton : Localization.backupToIcloudButton,
                isLoading: viewStore.backupLoading
            ) {
                if viewStore.recoveryPhraseBackedUp {
                    viewStore.send(.onDoneTap)
                } else {
                    app.post(event: blockchain.ux.backup.seed.phrase.flow.backup.to.icloud)
                    viewStore.send(.onBackupToIcloudTap)
                }
            }
            SecondaryButton(title: Localization.backupManuallyButton) {
                app.post(event: blockchain.ux.backup.seed.phrase.flow.backup.manually)
                viewStore.send(.onBackupManuallyTap)
            }
        }
        .padding(.horizontal, Spacing.padding3)
        .padding(.bottom, Spacing.padding3)
    }

    var copyButton: some View {
        Button {
            viewStore.send(.onCopyTap)
        } label: {
            Text(viewStore.recoveryPhraseCopied ? Localization.copiedButton : Localization.copyButton)
                .foregroundColor(viewStore.recoveryPhraseCopied ? Color.WalletSemantic.success : Color.WalletSemantic.primary)
        }
    }

    var badgeImage: some View {
        let text = viewStore.recoveryPhraseBackedUp ? Localization.tagBackedUp : Localization.tagNotBackedUp
       return TagView(
           text: text,
           icon: Icon.alert,
           variant: viewStore.recoveryPhraseBackedUp ? .success : .warning,
           size: .large
       )
        .padding(.top, Spacing.padding3)
    }
}

struct ViewRecoveryPhraseView_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryNavigationView {
            ViewRecoveryPhraseView(store: .init(
                initialState: .init(recoveryPhraseBackedUp: false),
                reducer: ViewRecoveryPhraseModule.reducer,
                environment: .init(
                    recoveryPhraseRepository: resolve(),
                    recoveryPhraseService: resolve(),
                    cloudBackupService: resolve(),
                    onNext: {},
                    onDone: {},
                    onFailed: {},
                    onIcloudBackedUp: {}
                )
            ))
        }
    }
}
