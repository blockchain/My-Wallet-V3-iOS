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
            ScrollView {
                VStack(spacing: Spacing.padding4) {
                    badgeImage
                    titleSections
                        .padding(.bottom, Spacing.padding3)
                    consentRowsSection
                    Spacer()
                }
                .padding(.horizontal, Spacing.padding2)
            }
            ctaButtonsView
        }
        .onAppear {
            viewStore.send(.onAppear)
        }
        .background(Color.semantic.light.ignoresSafeArea())
        .navigationBarTitle(Text(Localization.navigationTitle))
    }

    var titleSections: some View {
        VStack(spacing: Spacing.padding3) {
            Text(Localization.title)
                .typography(.title3)
                .foregroundColor(.semantic.title)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(width: .vw(80))
            Text(Localization.description)
                .typography(.body1)
                .foregroundColor(.semantic.body)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(width: .vw(80))
        }
    }

    var consentRowsSection: some View {
        VStack(alignment: .leading) {
            selectionRow(text: Localization.rowText1, isOn: viewStore.binding(\.$checkBox1IsOn))

            selectionRow(text: Localization.rowText2, isOn: viewStore.binding(\.$checkBox2IsOn))

            selectionRow(text: Localization.rowText3, isOn: viewStore.binding(\.$checkBox3IsOn))
        }
    }

    var ctaButtonsView: some View {
        VStack(spacing: Spacing.padding1) {
            PrimaryButton(title: Localization.backupButton) {
                app.post(event: blockchain.ux.backup.seed.phrase.flow.skip)
                viewStore.send(.onBackupNow)
            }
            .disabled(!viewStore.backupButtonEnabled)

            PrimaryWhiteButton(title: Localization.skipButton) {
                viewStore.send(.onSkipTap)
            }
        }
        .padding(.horizontal, Spacing.padding2)
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
            Checkbox(isOn: isOn)
            Text(text)
                .typography(.paragraph2)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
        .padding(Spacing.padding2)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.semantic.background)
        )
    }
}

struct ViewIntroBackupView_Previews: PreviewProvider {
    static var previews: some View {
        ViewIntroBackupView(store: .init(
            initialState: .init(recoveryPhraseBackedUp: false),
            reducer: ViewIntroBackup(onSkip: {}, onNext: {})
        ))
    }
}
