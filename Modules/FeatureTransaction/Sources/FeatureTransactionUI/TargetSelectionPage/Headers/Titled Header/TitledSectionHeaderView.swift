// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import PlatformUIKit
import UIKit

final class TitledSectionHeaderView: UIView {
    private let titleLabel = UILabel()
    private let sectionTitleLabel = UILabel()
    private let separator = UIView()

    var model: TitledSectionHeaderModel! {
        didSet {
            titleLabel.content = model?.titleLabel ?? .empty
            sectionTitleLabel.content = model?.sectionTitleLabel ?? .empty
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
        addSubview(sectionTitleLabel)

        // MARK: Labels

        titleLabel.layoutToSuperview(.top, offset: Spacing.padding2)
        titleLabel.layoutToSuperview(axis: .horizontal, offset: Spacing.padding2)

        sectionTitleLabel.layout(edge: .top, to: .bottom, of: titleLabel, offset: Spacing.padding2)
        sectionTitleLabel.layoutToSuperview(.leading, offset: Spacing.padding2)
        sectionTitleLabel.layoutToSuperview(.bottom, offset: -4)

        // MARK: Separator

        separator.backgroundColor = .semantic.medium
        separator.layout(dimension: .height, to: 1)
        separator.layout(edge: .leading, to: .trailing, of: sectionTitleLabel, offset: Spacing.padding1)
        separator.layoutToSuperview(.trailing, offset: Spacing.padding2)
        separator.layout(edge: .bottom, to: .lastBaseline, of: sectionTitleLabel)

        // MARK: Setup

        clipsToBounds = true
        titleLabel.numberOfLines = 0
        sectionTitleLabel.numberOfLines = 1
    }
}
