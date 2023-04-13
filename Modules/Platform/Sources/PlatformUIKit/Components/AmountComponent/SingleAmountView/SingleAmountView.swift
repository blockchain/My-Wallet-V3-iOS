// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift
import ToolKit
import UIComponentsKit
import UIKit

public final class SingleAmountView: UIView, AmountViewable {

    public var view: UIView {
        self
    }

    // MARK: - Properties

    private let fiatAmountLabelView = AmountLabelView()
    private let auxiliaryButton = ButtonView()

    private let presenter: SingleAmountPresenter

    public init(presenter: SingleAmountPresenter) {
        self.presenter = presenter
        super.init(frame: UIScreen.main.bounds)

        fiatAmountLabelView.presenter = presenter.amountPresenter.presenter

        setupUI()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init from coder isn't supported")
    }

    private func setupUI() {
        let innerStackView = UIStackView(arrangedSubviews: [fiatAmountLabelView, auxiliaryButton])
        innerStackView.axis = .vertical
        innerStackView.alignment = .center
        innerStackView.spacing = Spacing.standard

        let outerStackView = UIStackView(arrangedSubviews: [innerStackView])
        outerStackView.axis = .horizontal
        outerStackView.alignment = .center

        addSubview(outerStackView)
        outerStackView.constraint(
            edgesTo: self,
            insets: UIEdgeInsets(horizontal: Spacing.outer, vertical: Spacing.standard)
        )

        fiatAmountLabelView.constraint(axis: .horizontal, to: innerStackView)
        auxiliaryButton.layoutToSuperview(.leading, relation: .greaterThanOrEqual)
        auxiliaryButton.layoutToSuperview(.trailing, relation: .lessThanOrEqual)
    }

    public func connect(input: Driver<AmountPresenterInput>) -> Driver<AmountPresenterState> {
        Driver.combineLatest(
            presenter.connect(input: input),
            presenter.auxiliaryButtonEnabled
        )
        .map { (state: $0.0, auxiliaryEnabled: $0.1) }
        .map { [weak self] state, auxiliaryEnabled in
            guard let self else { return .validInput(nil) }
            return performEffect(state: state, auxiliaryEnabled: auxiliaryEnabled)
        }
    }

    private func performEffect(state: AmountPresenterState, auxiliaryEnabled: Bool) -> AmountPresenterState {
        let textColor: UIColor
        switch state {
        case .validInput(let viewModel):
            auxiliaryButton.viewModel = viewModel
            textColor = .validInput
        case .invalidInput(let viewModel):
            auxiliaryButton.viewModel = viewModel
            textColor = .invalidInput
        }

        let shouldShowButton = auxiliaryEnabled && auxiliaryButton.viewModel != nil
        let limitButtonVisibility: Visibility = shouldShowButton ? .visible : .hidden
        auxiliaryButton.alpha = limitButtonVisibility.defaultAlpha
        auxiliaryButton.isHidden = limitButtonVisibility.isHidden
        fiatAmountLabelView.textColor = textColor

        return state
    }
}
