// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import RxCocoa
import RxSwift

public final class ExplainedActionView: UIView {

    // MARK: - Injected

    public var viewModel: ExplainedActionViewModel! {
        didSet {
            guard let viewModel else { return }
            thumbBadgeImageView.viewModel = viewModel.thumbBadgeImageViewModel
            titleLabel.content = viewModel.titleLabelContent
            contentStackView.removeSubviews()

            if viewModel.isEnabled {
                button.rx.tap
                    .bindAndCatch(to: viewModel.tapRelay)
                    .disposed(by: disposeBag)
            } else {
                alpha = 0.5
                isUserInteractionEnabled = false
            }

            let descriptionLabels: [UILabel] = viewModel.descriptionLabelContents
                .map { content in
                    let label = UILabel()
                    label.verticalContentHuggingPriority = .required
                    label.verticalContentCompressionResistancePriority = .required
                    label.numberOfLines = 0
                    label.content = content
                    return label
                }
            for label in descriptionLabels {
                contentStackView.addArrangedSubview(label)
            }
            if let badgeViewModel = viewModel.badgeViewModel {
                badgeView = BadgeView()
                badgeView.viewModel = badgeViewModel
                contentStackView.addArrangedSubview(badgeView)
            } else if let badgeView {
                contentStackView.removeArrangedSubview(badgeView)
                self.badgeView = nil
            }
        }
    }

    // MARK: - UI Properties

    private let thumbBadgeImageView = BadgeImageView()
    private let titleLabel = UILabel()
    private let contentStackView = UIStackView()
    private var badgeView: BadgeView!
    private let disclosureImageView = UIImageView()
    private let button = UIButton()

    private var extendedLayoutConstraints: [NSLayoutConstraint] = []
    private var narrowedLayoutConstraints: [NSLayoutConstraint] = []

    private let disposeBag = DisposeBag()

    // MARK: - Setup

    override public init(frame: CGRect) {
        super.init(frame: frame)

        // Add subviews
        backgroundColor = UIColor.semantic.light

        addSubview(thumbBadgeImageView)
        addSubview(titleLabel)
        addSubview(contentStackView)
        addSubview(disclosureImageView)
        addSubview(button)

        // Add constraints

        button.fillSuperview()
        button.addTargetForTouchDown(self, selector: #selector(touchDown))
        button.addTargetForTouchUp(self, selector: #selector(touchUp))

        disclosureImageView.layoutToSuperview(.trailing, offset: -24)
        disclosureImageView.layout(to: .centerY, of: thumbBadgeImageView)
        disclosureImageView.layout(size: .init(edge: 12))

        thumbBadgeImageView.layoutToSuperview(.leading, offset: 24)
        thumbBadgeImageView.layoutToSuperview(.top, offset: 24)
        thumbBadgeImageView.layout(size: .init(edge: 32))

        titleLabel.layout(to: .top, of: thumbBadgeImageView)
        titleLabel.layout(edge: .leading, to: .trailing, of: thumbBadgeImageView, offset: 16)
        titleLabel.layout(edge: .trailing, to: .leading, of: disclosureImageView, offset: -16)
        titleLabel.verticalContentHuggingPriority = .penultimateHigh

        contentStackView.layout(edge: .top, to: .bottom, of: titleLabel, offset: 8)
        contentStackView.layout(to: .leading, of: titleLabel)
        contentStackView.layout(to: .trailing, of: titleLabel)
        contentStackView.layoutToSuperview(.bottom, offset: -24, priority: .penultimateHigh)

        // Configure subviews

        contentStackView.alignment = .leading
        contentStackView.distribution = .fillProportionally
        contentStackView.axis = .vertical
        contentStackView.spacing = 8

        disclosureImageView.contentMode = .scaleAspectFit
        disclosureImageView.image = UIImage(named: "icon-disclosure-small", in: .module, compatibleWith: .none)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func touchDown() {
        backgroundColor = UIColor.semantic.ultraLight
    }

    @objc
    private func touchUp() {
        backgroundColor = UIColor.semantic.light
    }
}
