// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import UIKit

final class TargetSelectionHeaderView: UIView {
    private let titleLabel = UILabel()

    var model: String? {
        didSet {
            titleLabel.content = model.flatMap { value in
                LabelContent(
                    text: value,
                    font: .main(.semibold, 16),
                    color: UIColor.titleText
                )
            } ?? .empty
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        addSubview(titleLabel)

        // MARK: Subtitle Label

        titleLabel.layout(edges: .leading, .top, to: self)

        // MARK: Setup

        clipsToBounds = true
        titleLabel.numberOfLines = 1
    }
}
