// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit
import RxSwift
import UIKit

final class InfoAuxiliaryViewPresenter: AuxiliaryViewPresenting {

    private let transactionState: TransactionState

    private weak var delegate: AuxiliaryViewPresentingDelegate?
    private let disposeBag = DisposeBag()

    init(transactionState: TransactionState, delegate: AuxiliaryViewPresentingDelegate?) {
        self.transactionState = transactionState
        self.delegate = delegate
    }

    func makeViewController() -> UIViewController {
        let viewController = UIViewController()
        let topInfoView = makeTopInfoView()
        viewController.view.addSubview(topInfoView)
        topInfoView.constraint(edgesTo: viewController.view)
        return viewController
    }

    private func makeTopInfoView() -> UIView {
        let topInfoView = SelectionButtonView()
        topInfoView.viewModel = SelectionButtonViewModel(showSeparator: false)

        let topSelectionTitle = TransactionFlowDescriptor.EnterAmountScreen
            .headerTitle(state: transactionState)
        let topSelectionSubtitle = TransactionFlowDescriptor.EnterAmountScreen
            .headerSubtitle(state: transactionState)
        topInfoView.viewModel.titleRelay.accept(topSelectionTitle)
        topInfoView.viewModel.titleAccessibilityRelay.accept(
            .id(Accessibility.Identifier.ContentLabelView.title)
                .copy(label: topSelectionTitle)
        )
        topInfoView.viewModel.subtitleRelay.accept(topSelectionSubtitle)
        topInfoView.viewModel.subtitleAccessibilityRelay.accept(
            .id(Accessibility.Identifier.ContentLabelView.description)
                .copy(label: topSelectionSubtitle)
        )
        topInfoView.viewModel.isButtonEnabledRelay.accept(transactionState.action == .withdraw)
        topInfoView.viewModel.leadingContentTypeRelay.accept(.none)

        let transactionImageViewModel = TransactionDescriptorViewModel(
            sourceAccount: transactionState.source as? SingleAccount,
            destinationAccount: transactionState.action == .swap ? transactionState.destination as? SingleAccount : nil,
            assetAction: transactionState.action,
            adjustActionIconColor: transactionState.action != .swap
        )
        topInfoView.viewModel.trailingContentRelay.accept(.transaction(transactionImageViewModel))

        let titleDescriptor: (font: UIFont, textColor: UIColor) = (
            font: .main(.medium, 12.0),
            textColor: .semantic.body
        )
        topInfoView.viewModel.titleFontRelay.accept(titleDescriptor.font)
        topInfoView.viewModel.titleFontColor.accept(titleDescriptor.textColor)

        let subtitleDescriptor: (font: UIFont, textColor: UIColor) = (
            font: .main(.semibold, 14.0),
            textColor: .semantic.title
        )
        topInfoView.viewModel.subtitleFontRelay.accept(subtitleDescriptor.font)
        topInfoView.viewModel.subtitleFontColor.accept(subtitleDescriptor.textColor)

        topInfoView.viewModel.tap
            .asObservable()
            .subscribe(onNext: { [weak self] in
                self?.handleTap()
            })
            .disposed(by: disposeBag)

        return topInfoView
    }

    private func handleTap() {
        delegate?.auxiliaryViewTapped(self, state: transactionState)
    }
}
