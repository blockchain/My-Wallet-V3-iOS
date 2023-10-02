// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift
import SwiftUI
import ToolKit
import UIKit

/// A small view that typically sits in a `UITableViewCell` showing
/// a state such as verified, rejected, or a flag indicating the
/// currency you have selected in settings.
public final class BadgeView: UIView {

    // MARK: - Private IBOutlets

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var accessoryContainer: UIView!
    @IBOutlet private var accessoryContainerWidth: NSLayoutConstraint!
    @IBOutlet private var accessoryContainerAspectRatio: NSLayoutConstraint!
    @IBOutlet private var accessoryContainerTrailing: NSLayoutConstraint!

    // MARK: - Rx

    private var disposeBag = DisposeBag()

    // MARK: - Public Properties

    public var viewModel: BadgeViewModel! {
        willSet {
            disposeBag = DisposeBag()
            accessoryContainer.removeSubviews()
            updateAccessoryView(visibility: .hidden)
        }
        didSet {
            guard viewModel != nil else { return }
            // Set non-reactive properties
            layer.cornerRadius = viewModel.cornerRadius
            titleLabel.font = viewModel.font

            // Set accessibility
            accessibility = viewModel.accessibility

            // Bind background color
            viewModel.backgroundColor
                .drive(containerView.rx.backgroundColor)
                .disposed(by: disposeBag)

            // bind label color
            viewModel.contentColor
                .drive(titleLabel.rx.textColor)
                .disposed(by: disposeBag)

            // Bind label text
            viewModel.text
                .drive(titleLabel.rx.text)
                .disposed(by: disposeBag)

            switch viewModel.accessory {
            case .none:
                updateAccessoryView(visibility: .hidden)
            case .progress(let model):
                updateAccessoryView(visibility: .visible)
                let backgroundCircle = BadgeCircleView(
                    strokeColor: .primary,
                    strokeBackgroundColor: .lightBadgeBackground,
                    fillColor: .white,
                    strokeWidth: 6
                )
                backgroundCircle.translatesAutoresizingMaskIntoConstraints = false
                accessoryContainer.addSubview(backgroundCircle)
                accessoryContainer.layout(edges: .leading, .trailing, .top, .bottom, to: backgroundCircle)
                backgroundCircle.model = model
            }
        }
    }

    private func updateAccessoryView(visibility: Visibility) {
        switch visibility {
        case .hidden:
            accessoryContainerTrailing.constant = 0
            accessoryContainerAspectRatio.priority = .defaultLow
            accessoryContainerWidth.priority = .penultimateHigh
        case .visible:
            accessoryContainerTrailing.constant = 8
            accessoryContainerAspectRatio.priority = .penultimateHigh
            accessoryContainerWidth.priority = .defaultLow
        }
    }

    // MARK: - Setup

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        fromNib(in: .module)
        clipsToBounds = true
    }
}

extension Reactive where Base: BadgeView {

    public var badgeViewModel: Binder<BadgeViewModel> {
        Binder(base) { view, model in
            view.viewModel = model
        }
    }

    public var viewModel: Binder<BadgeAsset.State.BadgeItem.Presentation> {
        Binder(base) { view, state in
            switch state {
            case .loaded(let next):
                view.viewModel = next.viewModel
            case .loading:
                view.viewModel = nil
            }
        }
    }
}

// MARK: - SwiftUI

public struct BadgeViewRepresentable: View, UIViewRepresentable {
    let viewModel: BadgeViewModel
    let size: CGFloat

    public init(viewModel: BadgeViewModel, size: CGFloat) {
        self.viewModel = viewModel
        self.size = size
    }

    public func makeUIView(context: Context) -> BadgeView {
        let view = BadgeView()
        view.viewModel = viewModel
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layout(size: .edge(size))
        return view
    }

    public func updateUIView(_ uiView: BadgeView, context: Context) {
        // Do nothing
    }
}
