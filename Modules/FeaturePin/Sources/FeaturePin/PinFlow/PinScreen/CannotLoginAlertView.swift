// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Localization
import SwiftUI
import UIComponentsKit
import UIKit

class CannotLoginAlertViewController: UIViewController {

    private let contentView = UIHostingController(rootView: CannotLoginAlertView())

    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(contentView)
        view.addSubview(contentView.view)
        contentView.didMove(toParent: self)
        setupConstraints()
    }

    private func setupConstraints() {
        contentView.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.view.heightAnchor.constraint(equalToConstant: 400).isActive = true
        contentView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        contentView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        contentView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
}

private struct CannotLoginAlertView: View {

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(LocalizationConstants.Pin.CannotLoginTitle)
                    .typography(.title3)
                    .foregroundColor(.semantic.title)
                Text(LocalizationConstants.Pin.CannotLoginMessage)
                    .typography(.paragraph1)
                    .foregroundColor(.semantic.body)
                InstructionList(instructions: createInstructions())
                    .padding(.top, Spacing.padding3)
                Text(LocalizationConstants.Pin.CannotLoginRemarkMessage)
                    .typography(.caption1)
                    .foregroundColor(.semantic.muted)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, Spacing.padding2)
            .padding(.bottom, Spacing.padding3)
            Spacer()
            PrimaryButton(
                title: LocalizationConstants.Pin.Button.toWebLogin,
                action: {
                    UIApplication.shared.open(URL(string: "https://login.blockchain.com")!)
                }
            )
        }
        .padding([.leading, .trailing], Spacing.padding3)
    }

    private struct Instruction: Identifiable {
        let id: Int
        let iconName: String
        let title: String
        let detailedMessage: String
    }

    private struct InstructionList: View {

        let instructions: [Instruction]

        var body: some View {
            VStack(alignment: .leading) {
                ForEach(instructions) {
                    InstructionRow(instruction: $0)
                        .padding(.top, 5)
                        .padding(.bottom, 5)
                }
            }
        }
    }

    private struct InstructionRow: View {

        let instruction: Instruction

        var body: some View {
            HStack(alignment: .top) {
                Image(instruction.iconName)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(.trailing, 5)
                VStack(alignment: .leading) {
                    Text(instruction.title)
                        .typography(.body2)
                        .foregroundColor(.semantic.title)
                    Text(instruction.detailedMessage)
                        .typography(.paragraph1)
                        .foregroundColor(.semantic.body)
                }
            }
        }
    }

    private func createInstructions() -> [Instruction] {
        [
            Instruction(
                id: 1,
                iconName: "number-one",
                title: LocalizationConstants.Pin.WebLoginInstructions.Title.walletIdOrEmail,
                detailedMessage: LocalizationConstants.Pin.WebLoginInstructions.Details.walletIdOrEmail
            ),
            Instruction(
                id: 2,
                iconName: "number-two",
                title: LocalizationConstants.Pin.WebLoginInstructions.Title.password,
                detailedMessage: LocalizationConstants.Pin.WebLoginInstructions.Details.password
            )
        ]
    }
}

private struct CannotLoginAlertView_Previews: PreviewProvider {
    static var previews: some View {
        CannotLoginAlertView()
    }
}
