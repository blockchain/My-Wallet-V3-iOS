// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import SwiftUI

/// A view which represents an error state
public struct ErrorStateView: View {

    let title: String
    let button: (String, () -> Void)?

    private let layout = Layout()

    public init(title: String, button: (String, () -> Void)? = nil) {
        self.title = title
        self.button = button
    }

    public var body: some View {
        VStack(spacing: Spacing.padding2) {
            Text(title)
                .typography(.title3)
                .foregroundColor(.semantic.title)

            if let (title, action) = button {
                PrimaryButton(title: title, action: action)
            }
        }
        .padding([.leading, .trailing], 24)
    }
}

extension ErrorStateView {
    struct Layout {}
}

struct ErrorStateView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ErrorStateView(title: "An error has occurred.")
            ErrorStateView(
                title: "An error has occurred.",
                button: ("Retry", {})
            )
        }
    }
}
