// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import SwiftUI

struct SectionHeaderExamplesView: View {
    var body: some View {
        VStack {
            SectionHeader(title: "Regular (wallet)")

            SectionHeader(title: "Large (exchange)", variant: .large)

            SectionHeader(
                title: "Large with Icon (exchange)",
                variant: .large,
                trailing: {
                    IconButton(icon: .qrCode) {}
                }
            )
        }
    }
}

struct SectionHeaderExamplesView_Previews: PreviewProvider {
    static var previews: some View {
        SectionHeaderExamplesView()
    }
}
