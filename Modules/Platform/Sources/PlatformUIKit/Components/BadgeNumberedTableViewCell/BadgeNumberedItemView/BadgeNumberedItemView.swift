// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary

public final class BadgeNumberedItemView: UIView {

    // MARK: - Injected

    public var viewModel: BadgeNumberedItemViewModel! {
        didSet {
            guard let viewModel else { return }
            badgeView.viewModel = viewModel.badgeViewModel
            titleLabel.content = viewModel.titleLabelContent
            descriptionLabel.content = viewModel.descriptionLabelContent
        }
    }

    // MARK: - Private Properties

    fileprivate let badgeView = BadgeView()
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        addSubview(badgeView)
        addSubview(stackView)

        badgeView.layout(size: .init(edge: Spacing.padding4))
        badgeView.layoutToSuperview(.leading, .top)

        stackView.axis = .vertical
        stackView.spacing = 4.0
        stackView.layout(edge: .leading, to: .trailing, of: badgeView, offset: Spacing.padding2)
        stackView.layoutToSuperview(.top, .bottom, .trailing)
        titleLabel.numberOfLines = 0
        descriptionLabel.numberOfLines = 0
        for view in [titleLabel, descriptionLabel] {
            stackView.addArrangedSubview(view)
        }
    }
}
