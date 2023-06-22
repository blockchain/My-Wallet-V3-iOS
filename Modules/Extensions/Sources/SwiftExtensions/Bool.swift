// Copyright © Blockchain Luxembourg S.A. All rights reserved.

infix operator &&=: AssignmentPrecedence

public func &&= (x: inout Bool, y: Bool) {
    x = x && y
}

extension Bool {
    public var not: Bool { !self }
    public var isYes: Bool { self == true }
    public var isNo: Bool { self == false }
}

extension Any? {
    public var isYes: Bool { (self as? Bool) == true }
    public var isNo: Bool { (self as? Bool) == false }
}

extension Bool {

    @inlinable public static func && (lhs: Self, rhs: () async throws -> Self) async rethrows -> Self {
        guard lhs else { return false }
        return try await rhs()
    }

    @inlinable public static func || (lhs: Self, rhs: () async throws -> Self) async rethrows -> Self {
        if lhs { return true }
        return try await rhs()
    }
}
