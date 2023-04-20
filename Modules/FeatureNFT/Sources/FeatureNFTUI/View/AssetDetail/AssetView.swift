import Foundation
import Nuke
import NukeUI
import SwiftUI
import UIComponentsKit
import UIKit

final class AssetView: UIView {

    var url: URL?
    private let imageView = LazyImageView()
    private let containerView = UIView()

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
        imageView.placeholderView = UIActivityIndicatorView(style: .large)
        imageView.imageView.contentMode = .scaleAspectFit
        imageView.transition = .fadeIn(duration: 0.2)
        addSubview(containerView)
        containerView.addSubview(imageView)
        containerView.constraint(edgesTo: self)
        containerView.addSubview(imageView)
        imageView.constraint(edgesTo: containerView)
        imageView.layer.cornerRadius = 30
        imageView.clipsToBounds = true

        addParallaxToView(
            view: containerView,
            amount: 40
        )
        addShadowParallaxToView(
            view: containerView,
            amount: 40
        )
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.request = .init(url: url)
    }

    func addParallaxToView(view: UIView, amount: Float) {
        let horizontal = UIInterpolatingMotionEffect(
            keyPath: "center.x",
            type: .tiltAlongHorizontalAxis
        )
        horizontal.minimumRelativeValue = -amount
        horizontal.maximumRelativeValue = amount

        let vertical = UIInterpolatingMotionEffect(
            keyPath: "center.y",
            type: .tiltAlongVerticalAxis
        )
        vertical.minimumRelativeValue = -amount
        vertical.maximumRelativeValue = amount

        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontal, vertical]
        view.addMotionEffect(group)
    }

    func addShadowParallaxToView(view: UIView, amount: Float) {
        view.layer.cornerRadius = 30
        view.layer.cornerCurve = .continuous
        view.layer.shadowColor = UIColor.black.withAlphaComponent(0.6).cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowRadius = 30
        view.layer.shadowOpacity = 0.7

        let horizontal = UIInterpolatingMotionEffect(
            keyPath: "layer.shadowOffset.width",
            type: .tiltAlongHorizontalAxis
        )
        horizontal.minimumRelativeValue = amount
        horizontal.maximumRelativeValue = -amount

        let vertical = UIInterpolatingMotionEffect(
            keyPath: "layer.shadowOffset.height",
            type: .tiltAlongVerticalAxis
        )
        vertical.minimumRelativeValue = amount
        vertical.maximumRelativeValue = -amount

        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontal, vertical]
        view.addMotionEffect(group)
    }
}

// MARK: - SwiftUI

struct AssetViewRepresentable: View, UIViewRepresentable {
    let url: URL?
    let size: CGFloat

    init(imageURL: URL?, size: CGFloat) {
        self.url = imageURL
        self.size = size
    }

    func makeUIView(context: Context) -> AssetView {
        let view = AssetView()
        view.url = url
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                view.widthAnchor.constraint(equalToConstant: size),
                view.heightAnchor.constraint(equalToConstant: size)
            ]
        )
        return view
    }

    func updateUIView(_ uiView: AssetView, context: Context) {
        uiView.constraints.first(where: { $0.firstAttribute == .width })?.constant = size
        uiView.constraints.first(where: { $0.firstAttribute == .height })?.constant = size
    }
}
