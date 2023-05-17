// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Foundation

public final class ShimmeringView: UIView {

    public enum Constants {
        public static let cornerRadius: CGFloat = 4
    }

    final class AnimatingView: UIView, ShimmeringViewing {}

    private weak var anchorView: UIView!

    private var dark: UIColor

    private lazy var animatingView: AnimatingView = {
        let view = AnimatingView(frame: bounds)
        addSubview(view)
        return view
    }()

    public var isShimmering: Bool {
        animatingView.isShimmering
    }

    public init(
        in superview: UIView,
        anchorView: UIView,
        size: CGSize,
        cornerRadius: CGFloat = Constants.cornerRadius,
        light: UIColor = .lightShimmering,
        dark: UIColor = .darkShimmering
    ) {
        self.anchorView = anchorView
        self.dark = dark
        super.init(frame: .init(origin: .zero, size: size))
        backgroundColor = light
        superview.addSubview(self)

        // Contain shimmer inside superview
        layout(edge: .leading, to: .leading, of: superview, relation: .greaterThanOrEqual, priority: .required)
        layout(edge: .trailing, to: .trailing, of: superview, relation: .lessThanOrEqual, priority: .required)

        // Layout shimmer to Anchor
        layout(to: .leading, of: anchorView, priority: .penultimateHigh)
        layout(to: .bottom, of: anchorView)
        layout(to: .height, of: anchorView, priority: .defaultHigh)

        // Layout shimmer to Size
        layout(dimension: .width, to: size.width)
        layout(dimension: .height, to: size.height, priority: .defaultLow)

        animatingView.fillSuperview()
        layer.cornerRadius = cornerRadius
        animatingView.layer.cornerRadius = cornerRadius
        layoutIfNeeded()
        start()
    }

    public init(
        in superview: UIView,
        centeredIn anchorView: UIView,
        size: CGSize,
        cornerRadius: CGFloat = Constants.cornerRadius,
        light: UIColor = .semantic.light,
        dark: UIColor = .semantic.dark
    ) {
        self.anchorView = anchorView
        self.dark = dark
        super.init(frame: CGRect(origin: .zero, size: size))
        backgroundColor = light
        superview.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: anchorView.centerXAnchor),
            centerYAnchor.constraint(equalTo: anchorView.centerYAnchor),
            widthAnchor.constraint(equalToConstant: size.width),
            heightAnchor.constraint(equalToConstant: size.height)
        ])

        animatingView.layoutToSuperviewSize()
        layer.cornerRadius = cornerRadius
        animatingView.layer.cornerRadius = cornerRadius
        layoutIfNeeded()
        start()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) is not implemented")
    }

    public func start() {
        animatingView.startShimmering(color: dark)
        alpha = 1
    }

    public func stop() {
        alpha = 0
        animatingView.stopShimmering()
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        animatingView.layoutShimmeringFrameIfNeeded()
    }
}
