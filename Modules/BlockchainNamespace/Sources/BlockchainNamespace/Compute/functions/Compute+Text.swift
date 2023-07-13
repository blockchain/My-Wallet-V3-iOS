extension Compute {

    struct Text: ComputeKeyword, Equatable {
        let by: By; struct By: Decodable, Equatable {
            let joining: Joining; struct Joining: Decodable, Equatable {
                let array: [String]
                let separator: String?
                let terminator: String?
            }
        }
    }
}

extension Compute.Text {

    func compute() throws -> Any? {
        by.joining.array
            .joined(separator: by.joining.separator ?? " ")
            .appending(by.joining.terminator ?? "")
    }
}

extension Compute.Text {

    public var description: String {
        "Text.By.Joining(array: \(by.joining.array), separator: \(by.joining.separator ?? " "), terminator: \(by.joining.terminator ?? "nil")"
    }
}
