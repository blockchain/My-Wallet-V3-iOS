// Copyright © Blockchain Luxembourg S.A. All rights reserved.

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

        titleLabel.layoutToSuperview(.top, offset: Spacing.inner)
        titleLabel.layoutToSuperview(axis: .horizontal, offset: Spacing.inner)

        sectionTitleLabel.layout(edge: .top, to: .bottom, of: titleLabel, offset: Spacing.inner)
        sectionTitleLabel.layoutToSuperview(.leading, offset: Spacing.inner)
        sectionTitleLabel.layoutToSuperview(.bottom, offset: -4)

        // MARK: Separator

        separator.backgroundColor = .mediumBorder
        separator.layout(dimension: .height, to: 1)
        separator.layout(edge: .leading, to: .trailing, of: sectionTitleLabel, offset: Spacing.standard)
        separator.layoutToSuperview(.trailing, offset: Spacing.inner)
        separator.layout(edge: .bottom, to: .lastBaseline, of: sectionTitleLabel)

        // MARK: Setup

        clipsToBounds = true
        titleLabel.numberOfLines = 0
        sectionTitleLabel.numberOfLines = 1
    }
}
