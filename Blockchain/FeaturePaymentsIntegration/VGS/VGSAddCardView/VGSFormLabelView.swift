// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import SwiftUI

struct VGSFormLabelView: View {
    var title: String = ""

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title)
            .typography(.paragraph2)
            .foregroundColor(.semantic.title)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 32)
    }
}
