extension Compute {

    public struct Count: ComputeKeyword, Equatable {
        public let of: AnyJSON?
    }
}

extension Compute.Count {

    public func compute() throws -> Any? {
        (of?.any as? any Collection)?.count ?? 0
    }
}

extension Compute.Count: CustomStringConvertible {
    public var description: String { "Count(of: \(of?.description ?? "nil"))" }
}
