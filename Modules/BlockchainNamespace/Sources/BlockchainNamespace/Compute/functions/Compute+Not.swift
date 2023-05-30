extension Compute {

    struct Not: ComputeKeyword {
        let boolean: Bool
        init(from decoder: Decoder) throws { boolean = try Bool(from: decoder) }
    }
}

extension Compute.Not {
    func compute() throws -> Any? { !boolean }
}

extension Compute.Not {

    public var description: String {
        return "Not(\(boolean))"
    }
}

