import AnyCoding
import Extensions

extension Compute {

    struct Map: ComputeKeyword, Equatable {
        let src: AnyJSON
        let dst: AnyJSON
        let copy: [Copy]
    }
}

extension Compute.Map {

    enum CodingKeys: String, CodingKey {
        case src, dst, copy
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let src = try container.decode(AnyJSON.self, forKey: .src)
        self = try Compute.withContext { context in
            context.element = src
        } operation: {
            Compute.Map(
                src: src,
                dst: try container.decodeIfPresent(AnyJSON.self, forKey: .dst) ?? src,
                copy: try container.decodeIfPresent([Copy].self, forKey: .copy) ?? []
            )
        }
    }

    func compute() throws -> Any? {
        var dst = dst
        for copy in copy {
            dst[copy.to] = copy.value
        }
        return dst
    }
}

extension Compute.Map {

   struct Copy: Equatable, Decodable {
        let value: AnyJSON
        let to: [AnyCodingKey]
    }
}

extension Compute.Map: CustomStringConvertible {

    var description: String {
        return "Map(src: \(src), dst: \(dst), copy: \(copy))"
    }
}
