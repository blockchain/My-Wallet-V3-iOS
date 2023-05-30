// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import PlatformUIKit
import UIComponentsKit

struct CommonCellViewModel {
    let title: String
    let subtitle: String?
    let icon: UIImage?
    let showsIndicator: Bool
    let overrideTintColor: UIColor?
    let accessibilityID: String
    let titleAccessibilityID: String
    let presenter: CommonCellPresenting?

    init(
        title: String,
        subtitle: String?,
        presenter: CommonCellPresenting?,
        icon: UIImage?,
        showsIndicator: Bool,
        overrideTintColor: UIColor?,
        accessibilityID: String,
        titleAccessibilityID: String
    ) {
        self.title = title
        self.subtitle = subtitle
        self.presenter = presenter
        self.icon = icon
        self.showsIndicator = showsIndicator
        self.overrideTintColor = overrideTintColor
        self.accessibilityID = accessibilityID
        self.titleAccessibilityID = titleAccessibilityID
    }
}

final class CommonTableViewCell: UITableViewCell {

    // MARK: - Model

    var viewModel: CommonCellViewModel! {
        didSet {
            cancellables = []
            titleLabel.text = viewModel.title
            titleLabel.accessibility = .id(viewModel.titleAccessibilityID)
            accessibility = .id(viewModel.accessibilityID)
            if let icon = viewModel.icon {
                iconImageView.image = viewModel.overrideTintColor != nil
                    ? icon.withRenderingMode(.alwaysTemplate)
                    : icon
                iconImageView.sizeToFit()
                if iconImageView.superview == nil {
                    hStack.insertArrangedSubview(iconImageView, at: 0)
                }
            } else {
                iconImageView.removeFromSuperview()
            }
            accessoryType = viewModel.showsIndicator ? .disclosureIndicator : .none
            iconImageView.tintColor = viewModel.overrideTintColor
            titleLabel.font = UIFont.main(.medium, 16)
            titleLabel.textColor = viewModel.overrideTintColor ?? .semantic.title
            subtitleLabel.font = UIFont.main(.medium, 16)
            subtitleLabel.text = viewModel.subtitle
            subtitleLabel.textColor = .semantic.text
            subtitleLabel.numberOfLines = 1
            subtitleLabel.minimumScaleFactor = 0.5
            subtitleLabel.adjustsFontSizeToFitWidth = true

            if let presenter = viewModel.presenter {
                presenter.subtitle
                    .handleEvents(receiveOutput: { [weak self] loadingState in
                        switch loadingState {
                        case .loading:
                            self?.subtitleLabel.text = "  "
                        case .loaded(next: let subtitle):
                            self?.subtitleLabel.text = subtitle
                        }
                    })
                    .subscribe()
                    .store(in: &cancellables)
            }
        }
    }

    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Private IBOutlets

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var iconImageView: UIImageView!
    @IBOutlet private var hStack: UIStackView!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .semantic.background
        contentView.backgroundColor = .semantic.background
    }
}
