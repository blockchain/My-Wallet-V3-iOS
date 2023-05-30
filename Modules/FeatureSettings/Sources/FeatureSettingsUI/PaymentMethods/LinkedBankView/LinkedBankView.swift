// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import RxSwift

final class LinkedBankView: UIView {

    var viewModel: LinkedBankViewModelAPI! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            nameLabel.content = viewModel?.nameLabelContent ?? .empty
            limitsLabel.content = viewModel?.limitLabelContent ?? .empty
            accountLabel.content = viewModel?.accountLabelContent ?? .empty
            badgeImageView.viewModel = viewModel?.badgeImageViewModel

            button.isEnabled = viewModel?.isCustomButtonEnabled ?? false
            if let tapRelay = viewModel?.tapRelay, button.isEnabled {
                button.rx.tap
                    .bindAndCatch(to: tapRelay)
                    .disposed(by: disposeBag)

                button.rx
                    .controlEvent(.touchDown)
                    .map { _ in UIColor.hightlightedBackground }
                    .bindAndCatch(to: rx.backgroundColor)
                    .disposed(by: disposeBag)

                button.rx
                    .controlEvent(.touchCancel)
                    .map { _ in UIColor.white }
                    .bindAndCatch(to: rx.backgroundColor)
                    .disposed(by: disposeBag)
            }
        }
    }

    // MARK: - Private

    private var disposeBag = DisposeBag()

    private let stackView = UIStackView()
    private let nameLabel = UILabel()
    private let limitsLabel = UILabel()
    private let accountLabel = UILabel()
    private let badgeImageView = BadgeImageView()

    private let button = UIButton()

    // MARK: - Setup

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .semantic.background

        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.spacing = Spacing.interItem

        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(limitsLabel)

        addSubview(stackView)
        addSubview(badgeImageView)
        addSubview(accountLabel)
        addSubview(button)

        badgeImageView.layoutToSuperview(.centerY)
        badgeImageView.layout(size: CGSize(width: 28, height: 28))
        badgeImageView.layoutToSuperview(.leading, offset: Spacing.inner)

        accountLabel.layoutToSuperview(.centerY)
        accountLabel.layout(edge: .leading, to: .trailing, of: stackView, offset: Spacing.inner)
        accountLabel.layoutToSuperview(.trailing, offset: -Spacing.inner)
        accountLabel.horizontalContentHuggingPriority = .required
        accountLabel.horizontalContentCompressionResistancePriority = .required

        stackView.layout(edge: .leading, to: .trailing, of: badgeImageView, offset: Spacing.inner)
        stackView.layoutToSuperview(.centerY)
        stackView.layoutToSuperview(axis: .vertical, offset: 16, priority: .defaultHigh)

        button.layoutToSuperview(axis: .vertical)
        button.layoutToSuperview(axis: .horizontal)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }
}
