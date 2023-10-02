// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import PlatformKit
import RxCocoa
import RxSwift
import ToolKit

/// A `UIView` containing two `UILabel`, one on top of the other, an a `UIButton` on top to intercept touch events.
public final class ContentLabelView: UIView {

    public var presenter: ContentLabelViewPresenter! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            guard let presenter else { return }
            presenter
                .titleLabelContent
                .drive(titleLabel.rx.content)
                .disposed(by: disposeBag)

            presenter
                .descriptionLabelContent
                .drive(descriptionLabel.rx.content)
                .disposed(by: disposeBag)

            button.rx.tap
                .throttle(
                    .milliseconds(200),
                    latest: false,
                    scheduler: ConcurrentDispatchQueueScheduler(qos: .background)
                )
                .observe(on: MainScheduler.instance)
                .bindAndCatch(to: presenter.tapRelay)
                .disposed(by: disposeBag)
        }
    }

    // MARK: - Properties

    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let button = UIButton()
    private var disposeBag = DisposeBag()

    // MARK: - Properties

    public init() {
        super.init(frame: UIScreen.main.bounds)

        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(button)

        titleLabel.layoutToSuperview(.top, .leading, .trailing)
        descriptionLabel.layoutToSuperview(.bottom, .leading, .trailing)
        descriptionLabel.layout(edge: .top, to: .bottom, of: titleLabel, offset: Spacing.padding1)
        button.fillSuperview()
    }

    required init?(coder: NSCoder) { unimplemented() }
}
