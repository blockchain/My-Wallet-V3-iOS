// Copyright © Blockchain Luxembourg S.A. All rights reserved.

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
                        font: .main(.semibold, 16.0),
                        color: .titleText,
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
                        font: .main(.medium, 14.0),
                        color: .descriptionText,
                        alignment: .left,
                        accessibility: .id(presenter.descriptionAccessibilitySuffix)
                    )
                }
                .drive(labelStackView.middleLabel.rx.content)
                .disposed(by: disposeBag)

            presenter.pending
                .map {
                    LabelContent(
                        text: $0,
                        font: .main(.medium, 14.0),
                        color: .mutedText,
                        alignment: .left,
                        accessibility: .id(presenter.pendingAccessibilitySuffix)
                    )
                }
                .drive(labelStackView.bottomLabel.rx.content)
                .disposed(by: disposeBag)


            presenter.description
                .map{
                    $0.isEmpty
                }
                .drive(labelStackView.middleLabel.rx.isHidden)
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
        contentView.addSubview(badgeImageView)
        contentView.addSubview(thumbSideImageView)
        contentView.addSubview(labelStackView)
        contentView.addSubview(assetBalanceView)
        contentView.addSubview(multiBadgeView)
        contentView.addSubview(separatorView)

        separatorHeightConstraint = separatorView.layout(dimension: .height, to: 1)
        separatorView.layoutToSuperview(.leading, .trailing, .bottom)

        badgeImageView.layout(size: .edge(32))
        badgeImageView.layoutToSuperview(.leading, offset: 24)
        badgeImageView.layout(to: .centerY, of: labelStackView)

        thumbSideImageView.layout(size: .edge(16))
        thumbSideImageView.layout(to: .trailing, of: badgeImageView, offset: 4)
        thumbSideImageView.layout(to: .bottom, of: badgeImageView, offset: 4)

        labelStackView.layoutToSuperview(.top, offset: 16)
        labelStackViewBottomSuperview = labelStackView.layoutToSuperview(.bottom, offset: -16)
        labelStackView.layout(edge: .leading, to: .trailing, of: badgeImageView, offset: 16)

        assetBalanceView.layout(edge: .leading, to: .trailing, of: labelStackView)
        assetBalanceView.layoutToSuperview(.trailing, offset: -24)
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
        separatorView.backgroundColor = .lightBorder
        layoutIfNeeded()
        assetBalanceView.shimmer(
            estimatedFiatLabelSize: CGSize(width: 90, height: 16),
            estimatedCryptoLabelSize: CGSize(width: 100, height: 14)
        )
    }
}
