// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import struct CoreGraphics.CGFloat

extension BinaryInteger {
    @inlinable public var i: Int { .init(self) }
    @inlinable public var i32: Int32 { .init(self) }
    @inlinable public var i64: UInt64 { .init(self) }
    @inlinable public var u: UInt { .init(self) }
    @inlinable public var u32: UInt32 { .init(self) }
    @inlinable public var u64: UInt64 { .init(self) }
    @inlinable public var d: Double { .init(self) }
    @inlinable public var f: Float { .init(self) }
    @inlinable public var cg: CGFloat { .init(self) }
}

extension BinaryFloatingPoint {
    @inlinable public var i: Int { .init(self) }
    @inlinable public var i32: Int32 { .init(self) }
    @inlinable public var i64: UInt64 { .init(self) }
    @inlinable public var u: UInt { .init(self) }
    @inlinable public var u32: UInt32 { .init(self) }
    @inlinable public var u64: UInt64 { .init(self) }
    @inlinable public var d: Double { .init(self) }
    @inlinable public var f: Float { .init(self) }
    @inlinable public var cg: CGFloat { .init(self) }
}
