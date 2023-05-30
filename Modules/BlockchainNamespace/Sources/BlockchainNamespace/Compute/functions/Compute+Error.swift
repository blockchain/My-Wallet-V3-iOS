extension Compute {

    public struct Error: ComputeKeyword, Equatable {
        public let message: String
    }
}

extension Compute.Error {

    public func compute() throws -> Any? {
        throw AnyJSON.Error(message)
    }
}

extension Compute.Error {
    public var description: String { return "Compute.Error(\(message))" }
}
