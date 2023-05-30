import Extensions

extension Compute {

    struct Item: ComputeKeyword, Equatable {
        let keyPath: [AnyCodingKey]
    }
}

extension Compute.Item {

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        keyPath = try container.decode([AnyCodingKey].self)
    }
}

extension Compute.Item {

    func compute() throws -> Any? {
        @Compute.Context var context
        let element = try context.element.or(throw: "Missing element data in context for \(self)")
        return try element[keyPath].or(throw: "Found no value at \(keyPath) in \(element)")
    }
}

extension Compute.Item {

    var description: String { "Item(\(keyPath))" }
}
