// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Algorithms

public let π = Double.pi

extension FloatingPoint {
    @inlinable public static var unit: Self { .init(1) }
}

extension Sequence where Element: FloatingPoint {
    public func sum() -> Element { reduce(0, +) }
    public func product() -> Element { reduce(1, *) }
}

public enum SlidingAveragesPrefixAndSuffix: Int {
    case reverseToFit
    case reverse
    case repeating
    case none
}

extension RandomAccessCollection where Element: FloatingPoint {

    public func slidingAverages(
        radius: Int,
        prefixAndSuffix: SlidingAveragesPrefixAndSuffix = .reverseToFit
    ) -> [Element] {
        guard radius != 0, !isEmpty else { return array }
        let start: [Element]
        let end: [Element]
        switch prefixAndSuffix {
        case .reverseToFit:
            start = lazy.prefix(radius).reversed().map { 2 * self.first! - $0 }
            end = lazy.suffix(radius).reversed().map { 2 * self.last! - $0 }
        case .reverse:
            start = prefix(radius).reversed()
            end = suffix(radius).reversed()
        case .repeating:
            start = Array(repeating: first!, count: radius)
            end = Array(repeating: last!, count: radius)
        case .none:
            return slidingAverages(radius: radius)
        }
        var array = [Element](); do {
            array.reserveCapacity(count + radius * 2)
            array.append(contentsOf: start)
            array.append(contentsOf: self)
            array.append(contentsOf: end)
        }
        return array.slidingAverages(radius: radius)
    }

    private func slidingAverages(
        radius: Int
    ) -> [Element] {
        guard radius != 0 else { return array }
        let window = (2 * abs(radius)) + 1
        return windows(ofCount: window).map {
            $0.sum() / Element(window)
        }
    }
}
