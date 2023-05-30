// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

/// A view which represents the lack of content
public struct EmptyStateView: View {

    let title: String
    let subHeading: String
    let image: Image

    private let layout = Layout()

    public init(title: String, subHeading: String, image: Image) {
        self.title = title
        self.subHeading = subHeading
        self.image = image
    }

    public var body: some View {
        VStack {
            Text(title)
                .textStyle(.title)
                .foregroundColor(.semantic.title)

            Spacer()
                .frame(height: layout.textSpacing)

            Text(subHeading)
                .textStyle(.subheading)
                .foregroundColor(.semantic.text)

            Spacer()
                .frame(height: layout.imageSpacing)

            image
        }
    }
}

extension EmptyStateView {
    struct Layout {
        let textSpacing: CGFloat = 8
        let imageSpacing: CGFloat = 24
    }
}

struct EmptyStateView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyStateView(
            title: "You Have No Activity",
            subHeading: "All your transactions will show up here.",
            image: ImageAsset.emptyActivity.image
        )
    }
}
