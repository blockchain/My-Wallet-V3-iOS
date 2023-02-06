import BlockchainUI
import ComposableArchitecture
import DIKit
import Localization
import SwiftUI

public struct ViewIntroBackupView: View {
    typealias Localization = LocalizationConstants.BackupRecoveryPhrase.ViewIntroScreen
    let store: Store<ViewIntroBackupState, ViewIntroBackupAction>
    @ObservedObject var viewStore: ViewStore<ViewIntroBackupState, ViewIntroBackupAction>
    @State var isOn: Bool = false
    @BlockchainApp var app

    public init(store: Store<ViewIntroBackupState, ViewIntroBackupAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    public var body: some View {
        VStack {
            badgeImage
            Spacer()
            titleSections
                .padding(.bottom, Spacing.padding3)
            consentRowsSection
            Spacer()
            ctaButtonsView
        }
        .padding(.horizontal, Spacing.padding3)
        .onAppear {
            viewStore.send(.onAppear)
        }
        .navigationBarTitle(Text(Localization.navigationTitle))
    }

    var titleSections: some View {
        VStack(spacing: Spacing.padding3) {
            Icon.lockClosed
                .frame(
                    width: 30,
                    height: 30
                )
            Text(Localization.title)
                .typography(.title2)
                .multilineTextAlignment(.center)
                .frame(width: .vw(80))
            Text(Localization.description)
                .typography(.paragraph1)
                .foregroundColor(.WalletSemantic.title)
                .multilineTextAlignment(.center)
                .frame(width: .vw(80))
        }
    }

    var consentRowsSection: some View {
        VStack(alignment: .leading, content: {
            selectionRow(text: Localization.rowText1, isOn: viewStore.binding(\.$checkBox1IsOn))

            selectionRow(text: Localization.rowText2, isOn: viewStore.binding(\.$checkBox2IsOn))

            selectionRow(text: Localization.rowText3, isOn: viewStore.binding(\.$checkBox3IsOn))
        })
    }

    var ctaButtonsView: some View {
        VStack(spacing: Spacing.padding1) {
            PrimaryButton(title: Localization.backupButton) {
                app.post(event: blockchain.ux.backup.seed.phrase.flow.skip)
                viewStore.send(.onBackupNow)
            }
            .disabled(!viewStore.backupButtonEnabled)

            MinimalButton(title: Localization.skipButton) {
                viewStore.send(.onSkipTap)
            }
        }
        .padding(.bottom, Spacing.padding2)
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

    @ViewBuilder func selectionRow(text: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(text)
                .typography(.caption1)
                .frame(width: .vw(80), alignment: .leading)
                .multilineTextAlignment(.leading)
            Spacer()
            Checkbox(isOn: isOn)
        }
        .padding(Spacing.padding2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.WalletSemantic.light, lineWidth: 1)
        )
    }
}

struct ViewIntroBackupView_Previews: PreviewProvider {
    static var previews: some View {
        ViewIntroBackupView(store: .init(
            initialState: .init(recoveryPhraseBackedUp: false),
            reducer: ViewIntroBackupModule.reducer,
            environment: .init(
                onSkip: {},
                onNext: {}
            )
        ))
    }
}
