// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift
import UIKit

final class YodleePendingView: UIView {

    private lazy var stackView = UIStackView()
    private(set) lazy var compositeView: CompositeStatusView = CompositeStatusView(
        edge: 80,
        mainContainerViewRatio: 1.0,
        sideContainerViewRatio: 0.45
    )

    private(set) lazy var mainTitle = UILabel()
    private(set) lazy var subtitle = InteractableTextView()
    private(set) lazy var mainActionButton = ButtonView()
    private(set) lazy var cancelActionButton = ButtonView()

    init() {
        super.init(frame: .zero)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .white
        mainTitle.numberOfLines = 0
        mainTitle.textAlignment = .center
        mainTitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(compositeView)
        stackView.addArrangedSubview(mainTitle)
        stackView.addArrangedSubview(subtitle)
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = Spacing.standard
        stackView.setCustomSpacing(Spacing.outer, after: compositeView)

        addSubview(stackView)
        compositeView.layout(size: .edge(80))
        stackView.layoutToSuperview(.centerY, offset: -Spacing.inner)
        stackView.layoutToSuperview(.leading, offset: Spacing.outer)
        stackView.layoutToSuperview(.trailing, offset: -Spacing.outer)

        let buttonStackView = UIStackView(arrangedSubviews: [mainActionButton, cancelActionButton])
        buttonStackView.axis = .vertical
        buttonStackView.spacing = Spacing.inner
        addSubview(buttonStackView)

        mainActionButton.layout(dimension: .height, to: 48)
        cancelActionButton.layout(dimension: .height, to: 48)
        buttonStackView.layout(edge: .top, to: .bottom, of: stackView, relation: .greaterThanOrEqual, offset: Spacing.outer)
        buttonStackView.layoutToSuperview(.leading, offset: Spacing.outer)
        buttonStackView.layoutToSuperview(.trailing, offset: -Spacing.outer)
        buttonStackView.layoutToSuperview(.bottom, usesSafeAreaLayoutGuide: true, offset: -Spacing.outer)
    }

    fileprivate func configureButtons(using content: YodleeButtonsContent) {
        if let continueViewModel = content.continueButtonViewModel {
            mainActionButton.viewModel = continueViewModel
            mainActionButton.isHidden = false
        } else if let tryAgainViewModel = content.tryAgainButtonViewModel {
            mainActionButton.viewModel = tryAgainViewModel
            mainActionButton.isHidden = false
        }
        if let cancelViewModel = content.cancelActionButtonViewModel {
            cancelActionButton.viewModel = cancelViewModel
        }
        cancelActionButton.isHidden = content.isCancelButtonHidden
    }
}

extension Reactive where Base: YodleePendingView {
    var content: Binder<YodleePendingContent> {
        Binder<YodleePendingContent>(base) { base, model in
            base.compositeView.currentTypeRelay.accept(model.compositeViewType)
            base.mainTitle.content = model.mainTitleContent
            base.subtitle.viewModel = model.subtitleTextViewModel
            if let buttonContent = model.buttonContent {
                base.configureButtons(using: buttonContent)
            } else {
                base.mainActionButton.isHidden = true
                base.cancelActionButton.isHidden = true
            }
        }
    }
}
