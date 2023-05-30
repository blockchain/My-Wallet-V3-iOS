import Extensions

extension Compute {

    struct Yes: ComputeKeyword, Equatable {
        let `if`: [Bool]?
        let unless: [Bool]?
    }
}

extension Compute.Yes {

    public func compute() throws -> Any? {
        let ifs = `if` ?? []
        let buts = unless ?? []
        return ifs.allSatisfy { $0 } && buts.none { $0 }
    }
}

extension Compute.Yes {

    public var description: String {
        return "Yes(if: \(`if` ?? []), unless: \(`unless` ?? []))"
    }
}
