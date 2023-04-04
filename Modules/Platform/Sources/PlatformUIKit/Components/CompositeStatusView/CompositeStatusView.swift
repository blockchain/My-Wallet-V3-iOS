// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxRelay
import RxSwift

/// A view compose of two views (main and side) that each can be configured with different content types.
/// Check `CompositeStatusViewType` to see the available content types.
public final class CompositeStatusView: UIView {

    final class ContainerView: UIView {

        // MARK: - Properties

        let attributesRelay = BehaviorRelay(value: CompositeStatusViewType.Composite.SideViewAttributes.none)

        var attributes: Driver<CompositeStatusViewType.Composite.SideViewAttributes> {
            attributesRelay.asDriver()
        }

        private let contentSizeRatio: CGFloat
        private let disposeBag = DisposeBag()

        // MARK: - Setup

        /// Default initializer.
        /// - Parameters:
        ///   - edge: The length of the axis of this element.
        ///   - contentSizeRatio: The ratio of the size of the elements that will be added to this view.
        init(
            edge: CGFloat,
            contentSizeRatio: CGFloat = 0.80
        ) {
            self.contentSizeRatio = contentSizeRatio

            let size = CGSize(edge: edge)
            super.init(frame: CGRect(origin: .zero, size: size))

            backgroundColor = .white

            attributes
                .drive(
                    onNext: { [weak self] attributes in
                        guard let self else { return }
                        removeSubviews()
                        switch attributes.type {
                        case .loader:
                            setupLoadingView()
                        case .image(let imageResource):
                            setupImageView(with: imageResource)
                        case .none:
                            break
                        }
                    })
                .disposed(by: disposeBag)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            nil
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            layer.cornerRadius = min(bounds.width, bounds.height) * 0.5
        }

        private func setupImageView(with imageResource: ImageResource) {
            let content = ImageViewContent(imageResource: imageResource)
            let imageView = UIImageView(image: nil)
            add(view: imageView)
            imageView.set(content)
        }

        private func setupLoadingView() {
            let edge = bounds.width * contentSizeRatio
            let loadingView = LoadingAnimatingView(
                diameter: edge,
                strokeColor: .secondary,
                strokeBackgroundColor: UIColor.secondary.withAlphaComponent(0.3),
                fillColor: .clear,
                strokeWidth: 4
            )
            add(view: loadingView)
            loadingView.animate()
        }

        private func add(view: UIView) {
            addSubview(view)
            view.layoutToSuperviewSize(ratio: contentSizeRatio)
            view.layoutToSuperviewCenter()
        }
    }

    private final class MainContainerView: UIView {

        var cornerRadius: CGFloat = 0 {
            didSet {
                setNeedsLayout()
                layoutIfNeeded()
            }
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            layer.cornerRadius = min(bounds.width, bounds.height) * cornerRadius
        }
    }

    // MARK: - Properties

    public let currentTypeRelay = BehaviorRelay(value: CompositeStatusViewType.none)

    var currentType: Driver<CompositeStatusViewType> {
        currentTypeRelay.asDriver()
    }

    private var sideViewCenterPositionConstraints: [NSLayoutConstraint] = []
    private var sideViewCornerPositionConstraints: [NSLayoutConstraint] = []

    private let sideContainerView: UIView
    private let mainContainerView: MainContainerView

    private let mainContainerViewRatio: CGFloat
    private let sideContainerViewRatio: CGFloat

    private let disposeBag = DisposeBag()

    // MARK: - Setup

    public init(
        edge: CGFloat,
        mainContainerViewRatio: CGFloat = 0.85,
        sideContainerViewRatio: CGFloat = 0.35
    ) {
        self.mainContainerViewRatio = mainContainerViewRatio
        self.sideContainerViewRatio = sideContainerViewRatio

        let mainContainerViewEdge = edge * mainContainerViewRatio

        let sideContainerViewSize = CGSize(edge: edge * sideContainerViewRatio)

        self.sideContainerView = UIView(frame: CGRect(origin: .zero, size: sideContainerViewSize))
        self.mainContainerView = MainContainerView(frame: CGRect(origin: .zero, size: CGSize(edge: mainContainerViewEdge)))

        let size = CGSize(edge: edge)

        super.init(frame: CGRect(origin: .zero, size: size))
        layout(size: size)

        layoutMainContainerView()
        layoutSideContainerView(edge: edge, mainContainerViewEdge: mainContainerViewEdge)
        sideContainerView.layout(size: sideContainerViewSize)

        currentType
            .drive(
                onNext: { [weak self] type in
                    guard let self else { return }
                    mainContainerView.removeSubviews()
                    sideContainerView.removeSubviews()
                    switch type {
                    case .image(let imageResource):
                        setupImageView(with: imageResource)
                    case .loader:
                        setupLoadingView()
                    case .composite(let composite):
                        switch composite.baseViewType {
                        case .badgeImageViewModel(let viewModel):
                            setupBadgeImageView(with: viewModel)
                        case .image(let imageResource):
                            setupImageView(with: imageResource)
                        case .templateImage(let name, let bundle, let color):
                            setupTemplateImageView(with: name, bundle: bundle, templateColor: color)
                        case .text(let text):
                            setupLabel(with: text)
                        }
                        setupSideView(with: composite.sideViewAttributes)
                    case .none:
                        break
                    }
                    mainContainerView.backgroundColor = type.backgroundColor
                    mainContainerView.cornerRadius = type.cornerRadiusRatio
                })
            .disposed(by: disposeBag)
    }

    private func layoutMainContainerView() {
        addSubview(mainContainerView)
        mainContainerView.layoutToSuperviewSize(ratio: mainContainerViewRatio)
        mainContainerView.layoutToSuperviewCenter()
    }

    private func layoutSideContainerView(edge: CGFloat, mainContainerViewEdge: CGFloat) {
        addSubview(sideContainerView)
        let space = (edge - mainContainerViewEdge) * 0.5
        let radius = mainContainerViewEdge * 0.5
        let sideContainerViewX = radius * cos(.pi * 0.125)
        let sideContainerViewY = -radius * sin(.pi * 0.25)
        let centerX = sideContainerView.layoutToSuperview(.centerX, offset: sideContainerViewX - space, priority: .penultimateHigh)!
        let centerY = sideContainerView.layoutToSuperview(.centerY, offset: sideContainerViewY + space, priority: .penultimateHigh)!
        sideViewCenterPositionConstraints += [centerX, centerY]

        let sideConstraint = sideContainerView.layout(edge: .centerX, to: .trailing, of: mainContainerView, priority: .defaultLow)!
        let topConstraint = sideContainerView.layout(edge: .centerY, to: .top, of: mainContainerView, priority: .defaultLow)!
        sideViewCornerPositionConstraints += [sideConstraint, topConstraint]
    }

    private func setupSideView(with attributes: CompositeStatusViewType.Composite.SideViewAttributes) {
        let sideView = ContainerView(edge: sideContainerView.bounds.width)
        sideContainerView.addSubview(sideView)
        sideView.fillSuperview()
        sideView.attributesRelay.accept(attributes)

        switch attributes.position {
        case .radiusDistanceFromCenter:
            sideViewCornerPositionConstraints.forEach { $0.priority = .defaultLow }
            sideViewCenterPositionConstraints.forEach { $0.priority = .penultimateHigh }
        case .rightCorner:
            sideViewCornerPositionConstraints.forEach { $0.priority = .penultimateHigh }
            sideViewCenterPositionConstraints.forEach { $0.priority = .defaultLow }
        }
    }

    private func setupLoadingView() {
        let loadingView = LoadingAnimatingView(
            diameter: mainContainerView.bounds.width,
            strokeColor: .secondary,
            strokeBackgroundColor: UIColor.secondary.withAlphaComponent(0.3),
            fillColor: .clear
        )

        add(view: loadingView)
        loadingView.animate()
    }

    private func setupBadgeImageView(with viewModel: BadgeImageViewModel) {
        let badgeImageView = BadgeImageView()
        badgeImageView.viewModel = viewModel
        add(view: badgeImageView)
    }

    private func setupImageView(with imageResource: ImageResource) {
        let content = ImageViewContent(imageResource: imageResource)
        let imageView = UIImageView(image: nil)
        add(view: imageView)
        imageView.set(content)
    }

    private func setupTemplateImageView(with name: String, bundle: Bundle, templateColor: UIColor) {
        let image = UIImage(named: name, in: bundle, compatibleWith: .none)!
            .withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.tintColor = templateColor
        add(view: imageView)
    }

    private func setupLabel(with text: String) {
        let label = UILabel()
        label.textColor = .white
        label.text = text
        label.textAlignment = .center
        label.font = .main(.medium, 46)
        label.adjustsFontSizeToFitWidth = true
        add(view: label)
    }

    private func add(view: UIView) {
        mainContainerView.addSubview(view)
        view.layoutToSuperviewSize(ratio: mainContainerViewRatio)
        view.layoutToSuperviewCenter()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
