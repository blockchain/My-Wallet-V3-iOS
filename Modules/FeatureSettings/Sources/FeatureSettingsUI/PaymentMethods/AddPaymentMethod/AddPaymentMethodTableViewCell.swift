// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitectureExtensions
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift

final class AddPaymentMethodTableViewCell: UITableViewCell {

    // MARK: - Properties

    var presenter: AddPaymentMethodCellPresenter! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            guard let presenter else { return }

            presenter.badgeImagePresenter.state
                .compactMap { $0 }
                .bindAndCatch(to: rx.viewModel)
                .disposed(by: disposeBag)

            presenter.labelContentPresenter.state
                .compactMap { $0 }
                .bindAndCatch(to: rx.content)
                .disposed(by: disposeBag)

            presenter.addIconImageVisibility
                .map(\.defaultAlpha)
                .drive(iconAddImageView.rx.alpha)
                .disposed(by: disposeBag)
        }
    }

    // MARK: - Private IBOutlets

    @IBOutlet fileprivate var iconAddImageView: UIImageView!
    @IBOutlet fileprivate var badgeImageView: BadgeImageView!
    @IBOutlet fileprivate var titleLabel: UILabel!

    // MARK: - Private Properties

    private var disposeBag = DisposeBag()
    fileprivate var titleShimmeringView: ShimmeringView!

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        shimmer()
        contentView.backgroundColor = .semantic.background
        titleLabel.textColor = .semantic.title
    }

    /// Should be called once when the parent view loads
    private func shimmer() {
        titleShimmeringView = ShimmeringView(
            in: self,
            anchorView: titleLabel,
            size: .init(width: 150, height: 24)
        )
    }
}

// MARK: - Rx

extension Reactive where Base: AddPaymentMethodTableViewCell {
    var viewModel: Binder<LoadingState<BadgeImageViewModel>> {
        Binder(base) { view, state in
            switch state {
            case .loading:
                break
            case .loaded(next: let value):
                UIView.animate(
                    withDuration: 0.2,
                    delay: 0.0,
                    options: .transitionCrossDissolve,
                    animations: {
                        view.badgeImageView.viewModel = value
                    },
                    completion: nil
                )
            }
        }
    }

    var content: Binder<LabelContent.State.Presentation> {
        Binder(base) { view, state in
            let loading = {
                view.titleShimmeringView.start()
            }

            switch state {
            case .loading:
                UIView.animate(withDuration: 0.5, animations: loading)
            case .loaded(next: let value):
                UIView.animate(
                    withDuration: 0.2,
                    delay: 0.0,
                    options: .transitionCrossDissolve,
                    animations: {
                        view.titleLabel.content = value.labelContent
                        view.titleShimmeringView.stop()
                    },
                    completion: nil
                )
            }
        }
    }
}
