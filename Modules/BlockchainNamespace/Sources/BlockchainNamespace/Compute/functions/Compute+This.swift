extension Compute {

    struct This: ComputeKeyword, Equatable {
        let condition: Bool?
        let value: AnyJSON
    }
}

extension Compute.This {

    func compute() throws -> Any? {
        guard condition ?? true else { throw "false" }
        return value
    }
}

extension Compute.This {

    public var description: String {
        "This(value: \(value), condition: \(condition ?? true))"
    }
}
