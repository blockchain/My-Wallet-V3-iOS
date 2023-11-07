// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

extension UIView {

    @discardableResult
    public func constraint(edgesTo other: UIView, insets: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        constraint(axis: .both, to: other, insets: insets)
    }

    @discardableResult
    public func constraint(axis: UIAxis, to other: UIView, insets: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        let constraints: [NSLayoutConstraint] = switch axis {
        case .vertical:
            [
                topAnchor.constraint(equalTo: other.topAnchor, constant: insets.top),
                bottomAnchor.constraint(equalTo: other.bottomAnchor, constant: -insets.bottom)
            ]

        case .horizontal:
            [
                leftAnchor.constraint(equalTo: other.leftAnchor, constant: insets.left),
                rightAnchor.constraint(equalTo: other.rightAnchor, constant: -insets.right)
            ]

        case .both:
            [
                topAnchor.constraint(equalTo: other.topAnchor, constant: insets.top),
                leftAnchor.constraint(equalTo: other.leftAnchor, constant: insets.left),
                rightAnchor.constraint(equalTo: other.rightAnchor, constant: -insets.right),
                bottomAnchor.constraint(equalTo: other.bottomAnchor, constant: -insets.bottom)
            ]
        default:
            []
        }
        activate(constraints)
        return constraints
    }

    @discardableResult
    public func constraint(centerTo other: UIView, insets: CGPoint = .zero) -> [NSLayoutConstraint] {
        let constraints = [
            centerXAnchor.constraint(equalTo: other.centerXAnchor, constant: insets.x),
            centerYAnchor.constraint(equalTo: other.centerYAnchor, constant: insets.y)
        ]
        activate(constraints)
        return constraints
    }

    @discardableResult
    public func constraint(centerXTo other: UIView, insets: CGPoint = .zero) -> [NSLayoutConstraint] {
        let constraints = [
            centerXAnchor.constraint(equalTo: other.centerXAnchor, constant: insets.x)
        ]
        activate(constraints)
        return constraints
    }

    @discardableResult
    public func constraint(centerYTo other: UIView, insets: CGPoint = .zero) -> [NSLayoutConstraint] {
        let constraints = [
            centerYAnchor.constraint(equalTo: other.centerYAnchor, constant: insets.y)
        ]
        activate(constraints)
        return constraints
    }

    private func activate(_ constraints: [NSLayoutConstraint]) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(constraints)
    }
}
