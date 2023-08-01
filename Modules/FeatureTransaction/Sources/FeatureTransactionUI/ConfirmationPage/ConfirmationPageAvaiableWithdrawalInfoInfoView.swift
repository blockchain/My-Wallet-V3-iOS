// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary

struct ConfirmationPageAvaiableWithdrawalInfoView: View {

    let title: String
    let description: String
    let readMoreButtonTitle: String
    let readMoreUrl: URL
    let onClose: () -> Void
    @Environment(\.openURL) var openURL

    init(
        title: String,
        description: String,
        readMoreButtonTitle: String,
        readMoreUrl: URL,
        onClose: @escaping () -> Void
    ) {
        self.title = title
        self.description = description
        self.readMoreButtonTitle = readMoreButtonTitle
        self.readMoreUrl = readMoreUrl
        self.onClose = onClose
    }

    var body: some View {
        Spacer(minLength: Spacing.padding1)
        VStack(spacing: Spacing.padding3) {
            HStack {
                Text(title)
                    .fixedSize(horizontal: false, vertical: true)
                    .typography(.body2)
                    .foregroundTexture(.semantic.title)
                Spacer()
                IconButton(icon: .navigationCloseButton()) {
                    onClose()
                }
                .frame(width: 24.pt, height: 24.pt)
            }
            .padding(.horizontal, 4)
            ScrollView {
                Text(description)
                    .fixedSize(horizontal: false, vertical: true)
                    .typography(.body1)
                    .foregroundTexture(.semantic.text)
                Spacer(minLength: 18)
                HStack {
                    SmallMinimalButton(title: readMoreButtonTitle) {
                        openURL(readMoreUrl)
                        onClose()
                    }
                    Spacer()
                }
                .padding(.horizontal, 5)
            }
        }
        .padding([.horizontal, .bottom], Spacing.padding2)
        .padding(.top, Spacing.padding2)
    }
}

struct ConfirmationPageAvaiableWithdrawalInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmationPageDetailsTermsView(
            title: "Title",
            description: "Description",
            doneButtonTitle: "Done",
            onCompletion: {}
        )
    }
}
