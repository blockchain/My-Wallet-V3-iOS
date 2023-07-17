// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import PlatformKit
import RxCocoa
import RxSwift

public final class CurrentBalanceTableViewCell: UITableViewCell {

    public var presenter: CurrentBalanceCellPresenting! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            guard let presenter else {
                assetBalanceView.presenter = nil
                badgeImageView.viewModel = nil
                thumbSideImageView.viewModel = nil
                labelStackView.clear()
                multiBadgeView.model = nil
                return
            }

            accessibility = .id(presenter.viewAccessibilitySuffix)

            assetBalanceView.presenter = presenter.assetBalanceViewPresenter
            multiBadgeView.model = presenter.multiBadgeViewModel

            presenter.multiBadgeViewModel
                .visibility
                .drive(weak: self) { (self, visibility) in
                    self.displayBadges(visibility: visibility)
                }
                .disposed(by: disposeBag)

            presenter.badgeImageViewModel
                .drive(badgeImageView.rx.viewModel)
                .disposed(by: disposeBag)

            presenter.iconImageViewContent
                .drive(thumbSideImageView.rx.viewModel)
                .disposed(by: disposeBag)

            presenter.title
                .map {
                    LabelContent(
                        text: $0,
                        font: .main(.semibold, 14.0),
                        color: .semantic.title,
                        alignment: .left,
                        accessibility: .id(presenter.titleAccessibilitySuffix)
                    )
                }
                .drive(labelStackView.topLabel.rx.content)
                .disposed(by: disposeBag)

            presenter.description
                .map {
                    LabelContent(
                        text: $0,
                        font: .main(.medium, 12.0),
                        color: .semantic.body,
                        alignment: .left,
                        accessibility: .id(presenter.descriptionAccessibilitySuffix)
                    )
                }
                .drive(labelStackView.middleLabel.rx.content)
                .disposed(by: disposeBag)

            presenter.networkTitle
                .compactMap { $0 }
                .drive(networkView.rx.text)
                .disposed(by: disposeBag)

            presenter.networkTitle
                .map { $0 == nil }
                .drive(networkView.rx.isHidden)
                .disposed(by: disposeBag)

            presenter.pending
                .map {
                    LabelContent(
                        text: $0,
                        font: .main(.medium, 14.0),
                        color: .semantic.muted,
                        alignment: .left,
                        accessibility: .id(presenter.pendingAccessibilitySuffix)
                    )
                }
                .drive(labelStackView.bottomLabel.rx.content)
                .disposed(by: disposeBag)

            presenter.description
                .map(\.isEmpty)
                .drive(labelStackView.middleLabel.rx.isHidden)
                .disposed(by: disposeBag)

            Driver.zip(presenter.networkTitle, presenter.description)
                .map { $0 == nil && $1.isEmpty }
                .drive(labelStackView.middleStackView.rx.isHidden)
                .disposed(by: disposeBag)

            presenter.pendingLabelVisibility
                .map(\.isHidden)
                .drive(labelStackView.bottomLabel.rx.isHidden)
                .disposed(by: disposeBag)

            presenter.separatorVisibility
                .map(\.defaultAlpha)
                .drive(separatorView.rx.alpha)
                .disposed(by: disposeBag)

            presenter.separatorVisibility
                .map { $0.isHidden ? 0 : 1 }
                .drive(separatorHeightConstraint.rx.constant)
                .disposed(by: disposeBag)
        }
    }

    // MARK: - Private Properties

    private var disposeBag = DisposeBag()
    private var separatorHeightConstraint: NSLayoutConstraint!
    private var labelStackViewBottomSuperview: NSLayoutConstraint!
    private var labelStackViewBottomMultiBadgeView: NSLayoutConstraint!

    private let badgeImageView = BadgeImageView()
    private let thumbSideImageView = BadgeImageView()
    private let labelStackView = ThreeLabelStackView()
    private let assetBalanceView = AssetBalanceView()
    private let separatorView = UIView()
    private let multiBadgeView = MultiBadgeView()

    private let networkView = PaddingLabel(.init(horizontal: 4, vertical: 2))

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
        presenter = nil
    }

    private func displayBadges(visibility: Visibility) {
        multiBadgeView.isHidden = visibility.isHidden
        labelStackViewBottomSuperview.isActive = visibility.isHidden
        labelStackViewBottomMultiBadgeView.isActive = !visibility.isHidden
    }

    func setup() {
        backgroundColor = .semantic.background
        contentView.backgroundColor = .semantic.background
        contentView.addSubview(badgeImageView)
        contentView.addSubview(thumbSideImageView)
        contentView.addSubview(labelStackView)
        contentView.addSubview(assetBalanceView)
        contentView.addSubview(multiBadgeView)
        contentView.addSubview(separatorView)

        networkView.font = .main(.semibold, 12)
        networkView.textColor = .semantic.body
        networkView.layer.masksToBounds = true
        networkView.layer.borderColor = UIColor.semantic.light.cgColor
        networkView.layer.borderWidth = 1.0
        networkView.layer.cornerRadius = 2
        networkView.backgroundColor = .clear
        labelStackView.middleStackView.addArrangedSubview(networkView)

        separatorHeightConstraint = separatorView.layout(dimension: .height, to: 1)
        separatorView.layoutToSuperview(.leading, .trailing, .bottom)

        badgeImageView.layout(size: .edge(24))
        badgeImageView.layoutToSuperview(.leading, offset: 16)
        badgeImageView.layout(to: .centerY, of: labelStackView)

        thumbSideImageView.layout(size: .edge(12))
        thumbSideImageView.layout(to: .trailing, of: badgeImageView, offset: 4)
        thumbSideImageView.layout(to: .bottom, of: badgeImageView, offset: 4)

        labelStackView.layoutToSuperview(.top, offset: 16)
        labelStackViewBottomSuperview = labelStackView.layoutToSuperview(.bottom, offset: -16)
        labelStackView.layout(edge: .leading, to: .trailing, of: badgeImageView, offset: 16)

        assetBalanceView.layout(edge: .leading, to: .trailing, of: labelStackView)
        assetBalanceView.layoutToSuperview(.trailing, offset: -16)
        assetBalanceView.layout(to: .centerY, of: labelStackView)

        multiBadgeView.layoutToSuperview(.leading, .trailing, .bottom)
        labelStackViewBottomMultiBadgeView = labelStackView.layout(
            edge: .bottom,
            to: .top,
            of: multiBadgeView,
            offset: 0,
            priority: .penultimateHigh,
            activate: false
        )
        separatorView.backgroundColor = .semantic.border
        layoutIfNeeded()
        assetBalanceView.shimmer(
            estimatedFiatLabelSize: CGSize(width: 90, height: 16),
            estimatedCryptoLabelSize: CGSize(width: 100, height: 14)
        )
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        networkView.layer.borderColor = UIColor.semantic.light.cgColor
    }
}

/// dear lord
final class PaddingLabel: UILabel {

    var insets: UIEdgeInsets

    required init(_ insets: UIEdgeInsets) {
        self.insets = insets
        super.init(frame: CGRect.zero)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.height += insets.top + insets.bottom
        contentSize.width += insets.left + insets.right
        return contentSize
    }
}
