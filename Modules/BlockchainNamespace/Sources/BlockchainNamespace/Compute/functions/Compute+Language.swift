extension Compute {

    public struct Language: ComputeKeyword, Equatable {
        public let id: String
    }
}

extension Compute.Language {

    public func compute() throws -> Any? {
        try AnyJSON(Tag.Reference(id: id, in: .root.language))
    }
}

extension Compute.Language {

    public var description: String {
        "Language(id: \(id))"
    }
}
