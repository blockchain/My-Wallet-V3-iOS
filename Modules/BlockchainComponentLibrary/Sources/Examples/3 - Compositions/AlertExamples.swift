// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import SwiftUI

struct AlertExamples: View {

    @State private var showingAlert = false

    var body: some View {
        PrimaryButton(title: "Show Alert", action: toggleModal)
            .padding(Spacing.padding3)
            .modal(isPresented: $showingAlert) {
                alert
            }
    }

    var alert: some View {
        Alert(
            topView: {
                Icon.blockchain
                    .frame(width: 34, height: 34)
            },
            title: "Hello, world!",
            message: "I'm an alert! Play with me!",
            buttons: [
                Alert.Button(
                    title: "Standard Button",
                    style: .standard,
                    action: toggleModal
                ),
                Alert.Button(
                    title: "Primary Button",
                    style: .primary,
                    action: toggleModal
                ),
                Alert.Button(
                    title: "Destructive Button",
                    style: .destructive,
                    action: toggleModal
                )
            ],
            close: toggleModal
        )
    }

    func toggleModal() {
        withAnimation {
            showingAlert.toggle()
        }
    }
}
