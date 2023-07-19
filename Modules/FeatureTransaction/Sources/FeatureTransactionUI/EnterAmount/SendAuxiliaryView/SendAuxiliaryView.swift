// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import ToolKit
import UIKit

final class SendAuxiliaryView: UIView {

    // MARK: - Properties

    var presenter: SendAuxiliaryViewPresenter! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            maxButtonView.viewModel = presenter.maxButtonViewModel
            availableBalanceView.presenter = presenter.availableBalanceContentViewPresenter
            networkFeeView.presenter = presenter.networkFeeContentViewPresenter

            presenter
                .imageContent
                .drive(imageView.rx.content)
                .disposed(by: disposeBag)

            presenter
                .state
                .map(\.bitpayVisibility)
                .drive(imageView.rx.visibility)
                .disposed(by: disposeBag)

            presenter
                .state
                .map(\.networkFeeVisibility)
                .drive(networkFeeView.rx.visibility)
                .disposed(by: disposeBag)
        }
    }

    private let availableBalanceView: ContentLabelView
    private let networkFeeView: ContentLabelView
    private let imageView: UIImageView
    private let maxButtonView: ButtonView
    private var disposeBag = DisposeBag()

    init() {
        self.availableBalanceView = ContentLabelView()
        self.networkFeeView = ContentLabelView()
        self.maxButtonView = ButtonView()
        self.imageView = UIImageView()

        super.init(frame: UIScreen.main.bounds)

        addSubview(availableBalanceView)
        addSubview(maxButtonView)
        addSubview(networkFeeView)
        addSubview(imageView)

        availableBalanceView.layoutToSuperview(.centerY)
        availableBalanceView.layoutToSuperview(.leading, offset: Spacing.padding3)
        availableBalanceView.layout(
            edge: .trailing,
            to: .centerX,
            of: self,
            relation: .equal
        )

        networkFeeView.layoutToSuperview(.centerY)
        networkFeeView.layoutToSuperview(.trailing, offset: -Spacing.padding3)
        networkFeeView.layout(
            edge: .leading,
            to: .centerX,
            of: self,
            relation: .equal
        )

        maxButtonView.layoutToSuperview(.centerY)
        maxButtonView.layoutToSuperview(.trailing, offset: -Spacing.padding3)
        maxButtonView.layout(dimension: .height, to: 30)

        imageView.layoutToSuperview(.centerY)
        imageView.layoutToSuperview(.trailing, offset: -Spacing.padding3)
    }

    required init?(coder: NSCoder) { unimplemented() }
}
