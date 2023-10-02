// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary

struct ConfirmationPageDetailsTermsView: View {

    let title: String
    let description: String
    let doneButtonTitle: String
    let onCompletion: () -> Void

    init(
        title: String,
        description: String,
        doneButtonTitle: String,
        onCompletion: @escaping () -> Void
    ) {
        self.title = title
        self.description = description
        self.doneButtonTitle = doneButtonTitle
        self.onCompletion = onCompletion
    }

    var body: some View {
        PrimaryNavigationView {
            VStack {
                ScrollView {
                    Text(description)
                        .fixedSize(horizontal: false, vertical: true)
                        .typography(.body1)
                        .foregroundTexture(.semantic.text)
                }
                PrimaryButton(title: doneButtonTitle) {
                    onCompletion()
                }
                .frame(alignment: .bottom)
            }
            .primaryNavigation(
                title: title,
                trailing: {
                    IconButton(icon: .navigationCloseButton()) {
                        onCompletion()
                    }
                    .frame(width: 24.pt, height: 24.pt)
                }
            )
            .padding([.horizontal, .bottom], Spacing.padding3)
            .padding(.top, Spacing.padding1)
        }
    }
}

struct DetailsInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmationPageDetailsTermsView(
            title: "Title",
            description: "Description",
            doneButtonTitle: "Done",
            onCompletion: {}
        )
    }
}
