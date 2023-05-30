// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public func isEqual(_ x: Any, _ y: Any) -> Bool {
    if let isEqual = (x as? any Equatable)?.isEqual(to: y) {
        return isEqual
    } else if let equatable = x as? AnyEquatable {
        return equatable.isEqual(to: y)
    } else {
        return (x as? any OptionalProtocol).isNil && (y as? any OptionalProtocol).isNil
    }
}

extension Equatable {

    fileprivate func isEqual(to other: Any) -> Bool {
        self == other as? Self
    }
}

protocol AnyEquatable {
    func isEqual(to other: Any) -> Bool
}

extension Dictionary: AnyEquatable {

    func isEqual(to other: Any) -> Bool {
        guard let other = other as? [Key: Any] else { return false }
        return allSatisfy { k, v in
            other[k].map { SwiftExtensions.isEqual($0, v) } ?? false
        }
    }
}

extension Array: AnyEquatable {

    func isEqual(to other: Any) -> Bool {
        guard let other = other as? [Any] else { return false }
        return Swift.zip(self, other).allSatisfy(SwiftExtensions.isEqual)
    }
}
