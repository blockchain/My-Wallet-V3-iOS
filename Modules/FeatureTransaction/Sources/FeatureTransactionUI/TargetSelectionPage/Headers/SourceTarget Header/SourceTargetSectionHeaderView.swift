// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import UIKit

final class SourceTargetSectionHeaderView: UIView {
    static let defaultHeight: CGFloat = 64
    private let titleLabel = UILabel()
    private let separator = UIView()

    var model: SourceTargetSectionHeaderModel! {
        didSet {
            titleLabel.content = model?.sectionTitleLabel ?? .empty
            separator.isHidden = model?.showSeparator == false
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
        addSubview(separator)

        // MARK: Subtitle Label

        titleLabel.layout(edges: .leading, .centerY, to: self)

        // MARK: Separator

        separator.backgroundColor = .semantic.medium
        separator.layout(dimension: .height, to: 1)
        separator.layout(edge: .leading, to: .trailing, of: titleLabel, offset: 8)
        separator.layout(edge: .bottom, to: .lastBaseline, of: titleLabel)
        separator.layoutToSuperview(.trailing, offset: 16)

        // MARK: Setup

        clipsToBounds = true
        titleLabel.numberOfLines = 1
    }
}
