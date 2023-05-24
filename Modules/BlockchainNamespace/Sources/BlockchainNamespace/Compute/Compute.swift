import Extensions

public enum Compute {

    public static func metadata(_ file: String = #fileID, _ line: Int = #line) -> Metadata {
        blockchain.db.returns.key().metadata(.compute, file: file, line: line)
    }
}

extension Compute {

    public enum CodingKeys: String, CodingKey {
        case returns = "{returns}"
        case `default`
    }

    public static let key = (
        returns: CodingKeys.returns.string,
        default: CodingKeys.default.string
    )

    struct JSON {

        let id: String
        let codingPath: [CodingKey]
        let returns: [String: Any]?
        let empty: Any

        init(codingPath: [CodingKey], returns: [String: Any]? = nil, empty: Any) {
            self.id = codingPath.string
            self.codingPath = codingPath
            self.returns = returns
            self.empty = empty
        }
    }
}

extension Compute.JSON: Hashable {
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
