// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import RxCocoa
import RxSwift

final class LinkedCardTableViewCell: UITableViewCell {

    // MARK: - Properties

    var presenter: LinkedCardCellPresenter! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            guard let presenter else { return }

            accessibility = presenter.accessibility
            linkedCardView.viewModel = presenter.linkedCardViewModel
            cardDigitsLabel.content = presenter.digitsLabelContent
            expirationDateLabel.content = presenter.expirationLabelContent
            expiredBadgeView.viewModel = presenter.badgeViewModel
            button.isEnabled = presenter.acceptsUserInteraction

            cardDigitsLabel.textColor = .semantic.title
            expirationDateLabel.textColor = .semantic.text

            presenter.badgeVisibility
                .map(\.isHidden)
                .drive(expiredBadgeView.rx.isHidden)
                .disposed(by: disposeBag)

            presenter.badgeVisibility
                .map(\.invertedAlpha)
                .drive(cardDigitsLabel.rx.alpha)
                .disposed(by: disposeBag)

            presenter.badgeVisibility
                .map(\.invertedAlpha)
                .drive(expirationDateLabel.rx.alpha)
                .disposed(by: disposeBag)

            button.rx
                .controlEvent(.touchUpInside)
                .bindAndCatch(to: presenter.tapRelay)
                .disposed(by: disposeBag)
        }
    }

    // MARK: - Private IBOutlets

    @IBOutlet private var button: UIButton!
    @IBOutlet private var linkedCardView: LinkedCardView!
    @IBOutlet private var cardDigitsLabel: UILabel!
    @IBOutlet private var expirationDateLabel: UILabel!
    @IBOutlet private var expiredBadgeView: BadgeView!

    // MARK: - Rx

    private var disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.semantic.background
        contentView.backgroundColor = UIColor.semantic.background
    }

    // MARK: - Touches

    @IBAction private func touchDown() {
        backgroundColor = UIColor.semantic.ultraLight
    }

    @IBAction private func touchUp() {
        backgroundColor = UIColor.semantic.background
    }
}
