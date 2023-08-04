// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift
import SwiftUI
import UIKit

public class MultiBadgeView: UIView {

    // MARK: Private Properties

    private let stackView = UIStackView()

    private var disposeBag = DisposeBag()

    private var horizontalConstraints: Axis.Constraints?
    private var verticalConstraints: Axis.Constraints?
    private var heightConstraint: NSLayoutConstraint!

    // MARK: - Public Properties

    public var model: MultiBadgeViewModel? {
        willSet {
            disposeBag = DisposeBag()
            stackView.removeSubviews()
        }
        didSet {
            guard let model else { return }
            model
                .badges
                .drive(weak: self) { (self, models) in
                    self.stackView.removeSubviews()
                    models.forEach { self.add($0) }
                    self.stackView.addArrangedSubview(UIView())
                }
                .disposed(by: disposeBag)

            model
                .layoutMargins
                .drive(weak: self) { (self, layoutMargins) in
                    self.horizontalConstraints?.leading.constant = layoutMargins.left
                    self.horizontalConstraints?.trailing.constant = -layoutMargins.right
                    self.verticalConstraints?.leading.constant = layoutMargins.top
                    self.verticalConstraints?.trailing.constant = -layoutMargins.bottom
                    self.invalidateIntrinsicContentSize()
                }
                .disposed(by: disposeBag)

            model
                .height
                .drive(weak: self) { (self, height) in
                    self.heightConstraint?.constant = height
                    self.invalidateIntrinsicContentSize()
                }
                .disposed(by: disposeBag)
        }
    }

    // MARK: Init

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    public override var intrinsicContentSize: CGSize {
        let margins = verticalConstraints?.leading.constant ?? 0 + -(verticalConstraints?.trailing.constant ?? 0)
        return CGSize(width: UIView.noIntrinsicMetric, height: heightConstraint.constant + margins)
    }

    // MARK: Private Methods

    private func add(_ presenter: BadgeAssetPresenting) {
        let badge = BadgeView()
        badge.contentHuggingPriority = (.defaultHigh, .defaultHigh)
        stackView.addArrangedSubview(badge)
        badge.layout(edges: .height, to: stackView)
        presenter.state
            .compactMap { $0 }
            .bindAndCatch(to: badge.rx.viewModel)
            .disposed(by: disposeBag)
    }

    private func setup() {
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        addSubview(stackView)
        heightConstraint = stackView.layout(dimension: .height, to: 32, priority: .defaultLow)
        horizontalConstraints = stackView.layoutToSuperview(axis: .horizontal)
        verticalConstraints = stackView.layoutToSuperview(axis: .vertical)
    }
}

extension Reactive where Base: MultiBadgeView {
    var viewModel: Binder<MultiBadgeViewModel> {
        Binder(base) { view, model in
            view.model = model
        }
    }
}

// MARK: - SwiftUI

public struct MultiBadgeViewRepresentable: View, UIViewRepresentable {
    let viewModel: Driver<MultiBadgeViewModel>
    let disposeBag = DisposeBag()

    public init(viewModel: Driver<MultiBadgeViewModel>) {
        self.viewModel = viewModel
    }

    public func makeUIView(context: Context) -> some UIView {
        let view = MultiBadgeView()
        viewModel
            .drive(view.rx.viewModel)
            .disposed(by: disposeBag)

        viewModel
            .flatMap(\.visibility)
            .map(\.isHidden)
            .drive(view.rx.isHidden)
            .disposed(by: disposeBag)

        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    public func updateUIView(_ uiView: UIViewType, context: Context) {
        // Do nothing
    }
}
