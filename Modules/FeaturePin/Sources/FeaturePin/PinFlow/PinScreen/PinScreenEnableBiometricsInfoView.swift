// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import SwiftUI

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
        ZStack(alignment: .top) {
            VStack(spacing: .zero) {
                VStack(spacing: Spacing.padding1) {
                    Text(viewModel.title)
                        .typography(.body2)
                        .foregroundColor(.semantic.title)
                        .padding(.horizontal, 26)
                        .padding(.top, 21)
                    Text(viewModel.subtitle)
                        .typography(.caption1)
                        .foregroundColor(.semantic.title)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 26)
                    Rectangle()
                        .fill(Color.semantic.light)
                        .frame(width: 270, height: 1)
                        .padding(.top, Spacing.padding1)
                }
                HStack(spacing: .zero) {
                    Button {
                        viewModel.cancelButton.actionClosure()
                        completion()
                    } label: {
                        Text(viewModel.cancelButton.title)
                            .typography(.body2)
                            .foregroundColor(.semantic.primary)
                    }
                    .frame(width: 135)
                    Rectangle()
                        .fill(Color.semantic.light)
                        .frame(width: 1, height: 48)
                    ZStack {
                        Button {
                            viewModel.acceptButton.actionClosure()
                            completion()
                        } label: {
                            Text(viewModel.acceptButton.title)
                                .typography(.body2)
                                .foregroundColor(.semantic.primary)
                        }
                        .frame(width: 135)
                        Circle()
                            .strokeBorder(Color.semantic.primary, lineWidth: 1)
                            .frame(width: 64)
                            .scaleEffect(1.4)
                            .allowsHitTesting(false)
                    }
                    .frame(height: 48)
                }
            }
            .frame(width: 270)
            .background(
                RoundedRectangle(
                    cornerRadius: Spacing.padding2
                )
                .fill(Color.semantic.background)
            )
            viewModel.icon
                .color(.semantic.primary)
                .frame(width: 42, height: 42)
                .offset(y: -30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.semantic.light.ignoresSafeArea())
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
