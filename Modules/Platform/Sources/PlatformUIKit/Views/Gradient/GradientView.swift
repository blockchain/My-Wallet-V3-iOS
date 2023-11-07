// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct Gradient {
    let startColor: UIColor
    let endColor: UIColor

    init(start: UIColor, end: UIColor) {
        self.startColor = start
        self.endColor = end
    }
}

extension Gradient {
    public static let exchange: Gradient = .init(start: #colorLiteral(red: 0.3, green: 0.09, blue: 0.73, alpha: 1), end: #colorLiteral(red: 0.05, green: 0.09, blue: 0.09, alpha: 1))
}

public enum Radius: Int {
    case none
    case roundedRect
    case roundedTop
    case roundedBottom
    case circle
}

/// This is just a view that shows a gradient. Use this wherever you want to show a gradient
/// and set its properties in Interface Builder.
public class GradientView: UIView {

    enum Direction: Int {
        case up
        case down
        case left
        case right
        case bottomRight
        case bottomLeft
    }

    @IBInspectable var startColor = UIColor(white: 0.0, alpha: 0.9) {
        didSet {
            updateGradientLayer()
        }
    }

    @IBInspectable var endColor: UIColor = .clear {
        didSet {
            updateGradientLayer()
        }
    }

    private var _radius = Radius.none
    @IBInspectable var cornerRadius: Int = Radius.none.rawValue {
        didSet {
            _radius = Radius(rawValue: cornerRadius)!
            updateGradientLayer()
        }
    }

    private var _direction = Direction.up
    @IBInspectable var direction: Int = Direction.up.rawValue {
        didSet {
            _direction = Direction(rawValue: direction)!
            updateGradientLayer()
        }
    }

    var gradientLayer = CAGradientLayer()

    override public var bounds: CGRect {
        didSet {
            gradientLayer.frame = layer.bounds
        }
    }

    // MARK: Initializers

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        updateGradientLayer()
    }

    init() {
        super.init(frame: CGRect.zero)
        updateGradientLayer()
    }

    override convenience init(frame: CGRect) {
        self.init()
    }

    // MARK: Superclass

    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        updateGradientLayer()
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        updateGradientLayer()
    }

    // MARK: Private

    private func updateGradientLayer() {
        backgroundColor = .clear
        let points = pointsForGradient()
        gradientLayer.startPoint = points.startPoint
        gradientLayer.endPoint = points.endPoint
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.shouldRasterize = true

        if gradientLayer.superlayer == nil {
            layer.insertSublayer(gradientLayer, at: 0)
            gradientLayer.frame = layer.bounds
        }

        applyRadius()
    }

    private func applyRadius() {
        layer.masksToBounds = true
        switch _radius {
        case .none:
            layer.cornerRadius = 0.0
        case .roundedRect:
            layer.cornerRadius = 8.0
        case .roundedTop:
            let path = UIBezierPath(
                roundedRect: bounds,
                byRoundingCorners: [.topLeft, .topRight],
                cornerRadii: CGSize(width: 4.0, height: 4.0)
            )
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            layer.mask = mask
        case .roundedBottom:
            let path = UIBezierPath(
                roundedRect: bounds,
                byRoundingCorners: [.bottomLeft, .bottomRight],
                cornerRadii: CGSize(width: 4.0, height: 4.0)
            )
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            layer.mask = mask
        case .circle:
            layer.cornerRadius = bounds.width / 2
        }
    }

    private func pointsForGradient() -> (startPoint: CGPoint, endPoint: CGPoint) {
        switch _direction {
        case .up:
            (CGPoint(x: 0.5, y: 1.0), CGPoint(x: 0.5, y: 0.0))
        case .down:
            (CGPoint(x: 0.5, y: 0.0), CGPoint(x: 0.5, y: 1.0))
        case .left:
            (CGPoint(x: 1.0, y: 0.5), CGPoint(x: 0.0, y: 0.5))
        case .right:
            (CGPoint(x: 0.0, y: 0.5), CGPoint(x: 1.0, y: 0.5))
        case .bottomRight:
            (CGPoint(x: 1.0, y: 1.0), CGPoint(x: 0.5, y: 0.0))
        case .bottomLeft:
            (CGPoint(x: 0.0, y: 1.0), CGPoint(x: 0.5, y: 0.0))
        }
    }
}
