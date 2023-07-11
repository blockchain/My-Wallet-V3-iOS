// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift

/// `WalletView` shows the wallet's label, balance (in crypto), and
/// a `BadgeImageView` showing the currency. This is typically used as a
/// subview in a `UITableViewCell` for when the user needs to select
/// a wallet for a specific action (e.g. `send`).
/// `LinkedBankAccount` is different. A `LinkedBankAccount` shows
/// additional information such as the minimum withdraw amount and the
/// fee associated. There is no balance information on a `LinkedBankAccount`
final class WalletView: UIView {

    let badgeImageView = BadgeImageView()
    let thumbSideImageView = BadgeImageView()
    let nameLabel = UILabel()
    let balanceLabel = UILabel()
    let stackView = UIStackView()

    // MARK: - Injected

    var viewModel: WalletViewViewModel! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            guard let viewModel else { return }
            Driver.just(viewModel.badgeImageViewModel)
                .drive(badgeImageView.rx.viewModel)
                .disposed(by: disposeBag)

            Driver.just(viewModel.accountTypeBadge)
                .drive(thumbSideImageView.rx.viewModel)
                .disposed(by: disposeBag)

            Driver.just(viewModel.nameLabelContent)
                .drive(nameLabel.rx.content)
                .disposed(by: disposeBag)

            viewModel
                .descriptionLabelContent
                .drive(balanceLabel.rx.content)
                .disposed(by: disposeBag)
        }
    }

    private var disposeBag = DisposeBag()

    // MARK: - Setup

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    convenience init() {
        self.init(frame: .zero)
    }

    private func setup() {
        addSubview(badgeImageView)
        addSubview(stackView)
        addSubview(thumbSideImageView)
        [nameLabel, balanceLabel].forEach { [stackView] label in
            stackView.addArrangedSubview(label)
        }

        stackView.axis = .vertical
        stackView.spacing = 4.0
        stackView.distribution = .fill

        thumbSideImageView.layout(size: .edge(12))
        thumbSideImageView.layout(to: .trailing, of: badgeImageView, offset: 4)
        thumbSideImageView.layout(to: .bottom, of: badgeImageView, offset: 4)

        badgeImageView.layout(size: .edge(24.0))
        badgeImageView.layout(to: .centerY, of: self)
        badgeImageView.layoutToSuperview(.leading)
        badgeImageView.layout(edge: .trailing, to: .leading, of: stackView, offset: -16.0)
        stackView.layout(to: .centerY, of: self)
    }
}

// MARK: - Rx

extension Reactive where Base: WalletView {
    var rx_viewModel: Binder<WalletViewViewModel> {
        Binder(base) { view, viewModel in
            view.viewModel = viewModel
        }
    }
}
