//
//  Skeleton.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 1/31/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public struct Skeleton {
    
    fileprivate static let key: String = "SkeletonKey"
    
    public let colors: [UIColor]
    public let direction: Direction
    public let duration: TimeInterval
    
    public enum Direction {
        case rightToLeft
        case leftToRight
    }
    
    public init(
        colors: [UIColor],
        direction: Direction,
        duration: TimeInterval
        ) {
        self.colors = colors
        self.direction = direction
        self.duration = duration
    }
}

public extension Skeleton {
    /// This is for demonstration purposes.
    /// Though it's important that when this is adopted we
    /// agree to one type of model that is used consistantly
    /// otherwise we will have different `Skeleton` durations
    /// and colors throughout the app.
    /// Note that it's also important that the colors start and end
    /// with the same color, otherwise the looping animation looks
    /// weird. 
    public static let 💀: Skeleton = Skeleton(
        colors: [.lightGray, .darkGray, .lightGray],
        direction: .rightToLeft,
        duration: 2.0
    )
}

private struct DirectionalPair {
    
    static let startPath: String = "Skeleton.DirectionalPair.Start"
    static let endPath: String = "Skeleton.DirectionalPair.End"
    
    let from: CGPoint
    let to: CGPoint
}

public extension CAGradientLayer {
    func applySkeleton(_ skeleton: Skeleton) {
        colors = skeleton.colors.map({ return $0.cgColor })
        let startAnimation = CABasicAnimation.start(
            skeleton.direction.start,
            path: #keyPath(startPoint)
        )
        let endAnimation = CABasicAnimation.end(
            skeleton.direction.end,
            path: #keyPath(endPoint)
        )
        let group = CAAnimationGroup()
        group.animations = [startAnimation, endAnimation]
        group.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        group.duration = skeleton.duration
        group.repeatCount = .infinity
        add(group, forKey: Skeleton.key)
    }
}

fileprivate extension CABasicAnimation {
    
    static func start(_ pair: DirectionalPair, path: String) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: path)
        animation.fromValue = NSValue(cgPoint: pair.from)
        animation.toValue = NSValue(cgPoint: pair.to)
        return animation
    }
    
    static func end(_ pair: DirectionalPair, path: String) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: path)
        animation.fromValue = NSValue(cgPoint: pair.from)
        animation.toValue = NSValue(cgPoint:pair.to)
        return animation
    }
}

fileprivate extension Skeleton.Direction {
    
    var start: DirectionalPair {
        switch self {
        case .leftToRight:
            return DirectionalPair(
                from: CGPoint(x: 1.0, y: 0.5),
                to: CGPoint(x: -1.0, y: 0.5)
            )
        case .rightToLeft:
            return DirectionalPair(
                from: CGPoint(x: -1.0, y: 0.5),
                to: CGPoint(x: 1.0, y: 0.5)
            )
        }
    }
    
    var end: DirectionalPair {
        switch self {
        case .leftToRight:
            return DirectionalPair(
                from: CGPoint(x: 2.0, y: 0.5),
                to: CGPoint(x: 0.0, y: 0.5)
            )
        case .rightToLeft:
            return DirectionalPair(
                from: CGPoint(x: 0.0, y: 0.5),
                to: CGPoint(x: 2.0, y: 0.5)
            )
        }
    }
}
