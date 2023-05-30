// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableNavigation
import PlatformUIKit
import RxCocoa
import RxSwift

final class BadgeTableViewCell: UITableViewCell {

    // MARK: - Properties

    var presenter: BadgeCellPresenting! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            guard let presenter else { return }
            presenter.badgeAssetPresenting.state
                .compactMap { $0 }
                .bindAndCatch(to: rx.viewModel)
                .disposed(by: disposeBag)

            presenter.labelContentPresenting.state
                .compactMap { $0 }
                .bindAndCatch(to: rx.content)
                .disposed(by: disposeBag)

            accessibility = presenter.accessibility
        }
    }

    // MARK: - Private IBOutlets

    @IBOutlet fileprivate var titleLabel: UILabel!
    @IBOutlet fileprivate var badgeView: BadgeView!

    // MARK: - Private Properties

    private var disposeBag = DisposeBag()
    fileprivate var badgeShimmeringView: ShimmeringView!
    fileprivate var titleShimmeringView: ShimmeringView!

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        shimmer()
        contentView.backgroundColor = .semantic.background
        titleLabel.textColor = .semantic.title
    }

    // MARK: - Lifecycle

    override func prepareForReuse() {
        super.prepareForReuse()
        presenter = nil
    }

    /// Should be called once when the parent view loads
    private func shimmer() {
        badgeShimmeringView = ShimmeringView(
            in: self,
            centeredIn: badgeView,
            size: .init(width: 75, height: 24)
        )
        titleShimmeringView = ShimmeringView(
            in: self,
            anchorView: titleLabel,
            size: .init(width: 150, height: 24)
        )
    }
}

// MARK: - Rx

extension Reactive where Base: BadgeTableViewCell {
    var viewModel: Binder<BadgeAsset.State.BadgeItem.Presentation> {
        Binder(base) { view, state in
            let loading = {
                view.badgeShimmeringView.start()
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
                        view.badgeView.viewModel = value.viewModel
                        view.badgeShimmeringView.stop()
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
                UIView.animate(
                    withDuration: 0.5,
                    animations: loading
                )
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
