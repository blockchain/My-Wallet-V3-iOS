// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import UIKit

public final class LabelInfoTableViewCell: UITableViewCell {

    private let titleLabel: UILabel = .init()
    private let subtitleLabel: UILabel = .init()
    private let infoButton: UIButton = UIButton()

    public var viewModel: LabelInfoViewCellModel! {
        willSet {}
        didSet {
            guard let viewModel else {
                return
            }
            titleLabel.text = viewModel.title
            subtitleLabel.text = viewModel.subtitle
            infoButton.isHidden = !viewModel.isInfoButtonVisible
        }
    }

    // MARK: - Lifecycle

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override public func prepareForReuse() {
        super.prepareForReuse()
        viewModel = nil
    }

    private func setup() {

        selectionStyle = .none
        infoButton.tintColor = .semantic.dark
        let buttonIcon = UIImage(named: "Icon-Info", in: .platformUIKit, with: nil)?
            .withRenderingMode(.alwaysTemplate)
        infoButton.addTarget(self, action: #selector(showInfoAction(sender:)), for: .touchUpInside)
        infoButton.setImage(
            buttonIcon?
                .imageWith(
                    newSize: .edge(14)
                ),
            for: .normal
        )

        titleLabel.numberOfLines = 0
        subtitleLabel.numberOfLines = 0
        titleLabel.font = .main(.medium, 14)
        titleLabel.textColor = .semantic.body
        subtitleLabel.font = .main(.semibold, 16)
        subtitleLabel.textColor = .semantic.text

        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(infoButton)

        titleLabel.layout(edge: .top, to: .top, of: contentView, offset: 16)
        titleLabel.layout(edge: .leading, to: .leading, of: contentView, offset: 24)
        let titleHeight = titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 24)
        titleHeight.priority = .penultimateHigh
        titleHeight.isActive = true

        infoButton.layout(size: .edge(30), relation: .equal)
        infoButton.layout(
            edge: .leading, to: .trailing, of: titleLabel, offset: -2
        )
        infoButton.layout(
            edge: .trailing,
            to: .trailing,
            of: contentView,
            relation: .lessThanOrEqual,
            offset: -24
        )
        infoButton.layout(edges: .centerY, to: titleLabel, offset: -1)

        subtitleLabel.layout(edge: .top, to: .bottom, of: titleLabel)
        subtitleLabel.layout(edge: .leading, to: .leading, of: contentView, offset: 24)
        subtitleLabel.layout(edge: .trailing, to: .trailing, of: contentView, offset: -24)
        subtitleLabel.layout(edge: .bottom, to: .bottom, of: contentView, offset: -16)
        let subtitleHeight = titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 24)
        subtitleHeight.priority = .penultimateHigh
        subtitleHeight.isActive = true
    }

    @objc func showInfoAction(sender: UIButton) {
        viewModel.tapInfoPublishRelay.accept(())
    }
}

extension UIImage {
    fileprivate func imageWith(newSize: CGSize) -> UIImage {
        let image = UIGraphicsImageRenderer(size: newSize).image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
        return image.withRenderingMode(renderingMode)
    }
}
