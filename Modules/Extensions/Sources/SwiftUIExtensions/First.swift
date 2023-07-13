import SwiftUI

@ViewBuilder public func First(
    _ a: @autoclosure () throws -> (some View)?,
    _ b: @autoclosure () throws -> (some View)? = EmptyView?.none,
    _ c: @autoclosure () throws -> (some View)? = EmptyView?.none,
    _ d: @autoclosure () throws -> (some View)? = EmptyView?.none,
    _ e: @autoclosure () throws -> (some View)? = EmptyView?.none,
    _ f: @autoclosure () throws -> (some View)? = EmptyView?.none,
    _ g: @autoclosure () throws -> (some View)? = EmptyView?.none,
    _ h: @autoclosure () throws -> (some View)? = EmptyView?.none,
    _ i: @autoclosure () throws -> (some View)? = EmptyView?.none,
    _ j: @autoclosure () throws -> (some View)? = EmptyView?.none,
    _ k: @autoclosure () throws -> (some View)? = EmptyView?.none,
    _ l: @autoclosure () throws -> (some View)? = EmptyView?.none
) throws -> some View {
    if let a = try? a() {
        a
    } else if let b = try? b() {
        b
    } else if let c = try? c() {
        c
    } else if let d = try? d() {
        d
    } else if let e = try? e() {
        e
    } else if let f = try? f() {
        f
    } else if let g = try? g() {
        g
    } else if let h = try? h() {
        h
    } else if let i = try? i() {
        i
    } else if let j = try? j() {
        j
    } else if let k = try? k() {
        k
    } else if let l = try? l() {
        l
    } else {
        try Throw("The view is not implemented yet".error())
    }
}

public struct Throw: View {
    public init(_ error: Error) throws { throw error }
    public var body: Never
}
