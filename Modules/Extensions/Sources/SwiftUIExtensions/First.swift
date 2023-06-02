import SwiftUI

@ViewBuilder public func First<
    A: View,
    B: View,
    C: View,
    D: View,
    E: View,
    F: View,
    G: View,
    H: View,
    I: View,
    J: View,
    K: View,
    L: View
>(
    _ a: @autoclosure () throws -> A?,
    _ b: @autoclosure () throws -> B? = EmptyView?.none,
    _ c: @autoclosure () throws -> C? = EmptyView?.none,
    _ d: @autoclosure () throws -> D? = EmptyView?.none,
    _ e: @autoclosure () throws -> E? = EmptyView?.none,
    _ f: @autoclosure () throws -> F? = EmptyView?.none,
    _ g: @autoclosure () throws -> G? = EmptyView?.none,
    _ h: @autoclosure () throws -> H? = EmptyView?.none,
    _ i: @autoclosure () throws -> I? = EmptyView?.none,
    _ j: @autoclosure () throws -> J? = EmptyView?.none,
    _ k: @autoclosure () throws -> K? = EmptyView?.none,
    _ l: @autoclosure () throws -> L? = EmptyView?.none
) throws -> some View {
    if let a = try? a() { a }
    else if let b = try? b() { b }
    else if let c = try? c() { c }
    else if let d = try? d() { d }
    else if let e = try? e() { e }
    else if let f = try? f() { f }
    else if let g = try? g() { g }
    else if let h = try? h() { h }
    else if let i = try? i() { i }
    else if let j = try? j() { j }
    else if let k = try? k() { k }
    else if let l = try? l() { l }
    else { try Throw("The view is not implemented yet".error()) }
}

public struct Throw: View {
    public init(_ error: Error) throws { throw error }
    public var body: Never
}
