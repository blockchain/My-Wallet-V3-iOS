// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift

final class SelectionItemTableViewCell: UITableViewCell {

    // MARK: - Injected

    var presenter: SelectionItemViewPresenter! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            guard let presenter else { return }

            switch presenter.thumb {
            case .image(let content):
                thumbImageView.set(content)
                thumbLabel.content = .empty
                thumbImageViewWidthConstraint.constant = 40
            case .label(let content):
                thumbLabel.content = content
                thumbImageView.set(.empty)
                thumbImageViewWidthConstraint.constant = 40
            case .none:
                thumbImageViewWidthConstraint.constant = 0.5
            }

            titleLabel.content = presenter.title
            descriptionLabel.content = presenter.description

            presenter.selectionImage
                .bindAndCatch(to: selectionImageView.rx.content)
                .disposed(by: disposeBag)

            button.rx.tap
                .bindAndCatch(to: presenter.tapRelay)
                .disposed(by: disposeBag)

            accessibility = presenter.accessibility
        }
    }

    // MARK: - UI Properties

    private let thumbImageView = UIImageView()
    private let thumbLabel = UILabel()
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let selectionImageView = UIImageView()
    private let button = UIButton()

    private var thumbImageViewWidthConstraint: NSLayoutConstraint!

    // MARK: - Accessors

    private var disposeBag = DisposeBag()

    // MARK: - Setup

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        presenter = nil
    }

    // MARK: - Setup

    private func setup() {
        contentView.addSubview(thumbImageView)
        contentView.addSubview(thumbLabel)
        contentView.addSubview(stackView)
        contentView.addSubview(selectionImageView)
        contentView.addSubview(button)

        button.addTargetForTouchDown(self, selector: #selector(touchDown))
        button.addTargetForTouchUp(self, selector: #selector(touchUp))
        button.fillSuperview()

        thumbImageView.layout(dimension: .height, to: 40)
        thumbImageViewWidthConstraint = thumbImageView.layout(dimension: .width, to: 40)
        thumbImageView.layoutToSuperview(.leading, offset: 24)
        thumbImageView.layoutToSuperview(.centerY)
        thumbImageView.layoutToSuperview(axis: .vertical, offset: 16, priority: .defaultHigh)

        thumbLabel.layout(to: .leading, of: thumbImageView)
        thumbLabel.layout(to: .trailing, of: thumbImageView)
        thumbLabel.layout(to: .top, of: thumbImageView)
        thumbLabel.layout(to: .bottom, of: thumbImageView)

        stackView.layoutToSuperview(axis: .vertical, offset: 24)
        stackView.layout(edge: .leading, to: .trailing, of: thumbImageView, offset: 16)
        stackView.layout(edge: .trailing, to: .leading, of: selectionImageView, offset: -16)
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 4

        stackView.insertArrangedSubview(titleLabel, at: 0)
        stackView.insertArrangedSubview(descriptionLabel, at: 1)
        titleLabel.verticalContentHuggingPriority = .required
        titleLabel.verticalContentCompressionResistancePriority = .required
        descriptionLabel.verticalContentHuggingPriority = .required
        descriptionLabel.verticalContentCompressionResistancePriority = .required

        selectionImageView.layout(size: .init(edge: 20))
        selectionImageView.layoutToSuperview(.trailing, offset: -24)
        selectionImageView.layoutToSuperview(.centerY)

        contentView.backgroundColor = .semantic.background
    }

    @objc
    private func touchDown() {
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: .beginFromCurrentState,
            animations: {
                self.contentView.backgroundColor = .semantic.light
            },
            completion: nil
        )
    }

    @objc
    private func touchUp() {
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: .beginFromCurrentState,
            animations: {
                self.contentView.backgroundColor = .semantic.background
            },
            completion: nil
        )
    }
}
