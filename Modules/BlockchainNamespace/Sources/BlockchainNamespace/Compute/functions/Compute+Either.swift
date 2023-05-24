extension Compute {

    public struct Either: ComputeKeyword, Equatable {
        let this: AnyJSON
    }
}

extension Compute.Either {

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var these: [Compute.This] = []
        while !container.isAtEnd {
            let this = try container.decode(Compute.This.self)
            these.append(this)
            guard let value = try? AnyJSON(this.compute()) else { continue }
            self.this = value
            return
        }
        throw AnyJSON.Error("Either failed - no matching conditions in \(these)")
    }
}

extension Compute.Either {
    public func compute() throws -> Any? { this.value }
}
