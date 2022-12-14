// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary

struct PinScreenEnableBiometricsInfoViewModel {
    struct Button {
        let title: String
        let actionClosure: () -> Void
    }

    let icon: Icon
    let title: String
    let subtitle: String
    let acceptButton: Button
    let cancelButton: Button
}

struct PinScreenEnableBiometricsInfoView: View {

    let viewModel: PinScreenEnableBiometricsInfoViewModel
    let completion: () -> Void

    init(
        viewModel: PinScreenEnableBiometricsInfoViewModel,
        completion: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.completion = completion
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: Spacing.padding3) {
                Spacer(minLength: 30)
                viewModel.icon
                    .color(Color.semantic.primary)
                    .frame(width: 40, height: 40)
                Text(viewModel.title)
                    .fixedSize(horizontal: false, vertical: true)
                    .typography(.title3)
                    .foregroundTexture(.semantic.title)
                Text(viewModel.subtitle)
                    .fixedSize(horizontal: false, vertical: true)
                    .typography(.paragraph1)
                    .foregroundTexture(.semantic.text)
                VStack(spacing: Spacing.padding2) {
                    PrimaryButton(title: viewModel.acceptButton.title) {
                        viewModel.acceptButton.actionClosure()
                        completion()
                    }
                    MinimalButton(title: viewModel.cancelButton.title) {
                        viewModel.cancelButton.actionClosure()
                        completion()
                    }
                }
            }
        }
        .padding(.horizontal, Spacing.padding2)
        .padding(.bottom, Spacing.padding3)
        .frame(alignment: .bottom)
    }
}

struct PinScreenEnableBiometricsInfoView_Previews: PreviewProvider {
    static var previews: some View {
        PinScreenEnableBiometricsInfoView(
            viewModel: .init(
                icon: .faceID,
                title: "Title",
                subtitle: "Subtitle",
                acceptButton: .init(
                    title: "Accept",
                    actionClosure: {}
                ),
                cancelButton: .init(
                    title: "Cancel",
                    actionClosure: {}
                )
            ),
            completion: {}
        )
    }
}
