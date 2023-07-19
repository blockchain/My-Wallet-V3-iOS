// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ToolKit

public struct ThumbnailViewModel {

    // MARK: - Exposed Properties

    // MARK: - Private Properties

    let imageViewContent: ImageViewContent
    let backgroundColor: UIColor

    // MARK: - Setup

    public init(
        imageViewContent: ImageViewContent,
        backgroundColor: UIColor
    ) {
        self.imageViewContent = imageViewContent
        self.backgroundColor = backgroundColor
    }
}
