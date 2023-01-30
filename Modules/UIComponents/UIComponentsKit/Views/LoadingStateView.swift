// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Extensions
import SwiftUI

/// A view which represents a loading state
public struct LoadingStateView: View {

    let title: String

    private let layout = Layout()

    public init(title: String) {
        self.title = title
    }

    public var body: some View {
        VStack {
            Text(title)
                .typography(.title3)
                .foregroundColor(.textTitle)
            ProgressView(value: 0.25)
                .progressViewStyle(
                    IndeterminateProgressStyle(lineWidth: layout.lineWidth)
                )
                .frame(width: 28, height: 28)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .background(Color.semantic.light.ignoresSafeArea())
    }
}

extension LoadingStateView {
    struct Layout {
        let lineWidth: Length = 12.5.pmin
        let progressViewWidth: Length = 20.vmin
    }
}

struct LoadingStateView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingStateView(title: "Loading...")
    }
}
