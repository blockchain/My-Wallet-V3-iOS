// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension String {

    public func distance(
        between target: String,
        using algorithm: StringDistanceAlgorithm = FuzzyAlgorithm(caseInsensitive: false)
    ) -> Double {
        algorithm.distance(between: self, and: target)
    }
}

public protocol StringDistanceAlgorithm {
    func distance(between a: String, and b: String) -> Double
}

public struct FuzzyAlgorithm: StringDistanceAlgorithm {

    let caseInsensitive: Bool

    public init(caseInsensitive: Bool) {
        self.caseInsensitive = caseInsensitive
    }

    public func distance(between a: String, and b: String) -> Double {
        guard a != b else { return 0 }
        var (a, b) = (a, b)
        if caseInsensitive {
            (a, b) = (a.lowercased(), b.lowercased())
        }

        if !b.isEmpty, a.starts(with: b[...b.index(b.startIndex, offsetBy: floor(b.count.d / 1.5).i)]) {
            return 0
        }

        if a.isEmpty { return b.isEmpty ? 0 : 1 }
        var remainder = a[...]
        for char in b {
            guard char == remainder[remainder.startIndex] else { continue }
            remainder.removeFirst()
            guard remainder.isEmpty else { continue }
            return 0.1
        }
        return b.count > 1 ? 1 : 0
    }
}

/// https://en.wikipedia.org/wiki/Jaro%E2%80%93Winkler_distance
public struct JaroWinklerAlgorithm: StringDistanceAlgorithm {

    var scalingFactor: Double
    var caseInsensitive: Bool

    public init(scalingFactor: Double = 0.1, caseInsensitive: Bool = true) {
        self.scalingFactor = scalingFactor
        self.caseInsensitive = caseInsensitive
    }

    public func distance(between a: String, and b: String) -> Double {
        guard a != b else { return 0 }
        var (a, b) = (
            min(a, b, by: \.count),
            max(a, b, by: \.count)
        )
        guard !(a.isEmpty && b.isEmpty) else { return 0 }

        if caseInsensitive {
            (a, b) = (a.lowercased(), b.lowercased())
        }

        let distance = b.count / 2
        var matches = 0.d

        var transpositions = 0.d
        var cursor = -1

        for (i, c1) in a.enumerated() {
            for (j, c2) in b.enumerated() {
                guard max(0, i - distance)..<min(b.count, i + distance) ~= j else { continue }
                guard c1 == c2 else { continue }
                matches += 1
                if cursor != -1, j < cursor {
                    transpositions += 1
                }
                cursor = j
                break
            }
        }

        guard matches > 0 else { return 1 }

        let prefix = a.commonPrefix(with: b).count.clamped(to: 0...4).d

        let similarity = (
            matches / a.count.d
                + matches / b.count.d
                + (matches - transpositions) / matches
        ) / 3

        return 1 - similarity + prefix * scalingFactor * (1 - similarity)
    }
}

public struct StringContainsAlgorithm: StringDistanceAlgorithm {

    var caseInsensitive: Bool

    public init(caseInsensitive: Bool = true) {
        self.caseInsensitive = caseInsensitive
    }

    public func distance(between a: String, and b: String) -> Double {
        guard a != b else { return 0 }
        var (a, b) = (
            min(a, b, by: \.count),
            max(a, b, by: \.count)
        )
        if caseInsensitive {
            (a, b) = (a.lowercased(), b.lowercased())
        }
        return b.contains(a) ? 0 : 1
    }
}
