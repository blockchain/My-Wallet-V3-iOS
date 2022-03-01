// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension Graph {

    public struct JSON: Decodable {
        public let date: Date
        public let classes: [Node]
    }
}

extension Graph.JSON {

    public class Decoder: JSONDecoder {
        override public init() {
            super.init()
            dateDecodingStrategy = .formatted(DateFormatter.shared)
        }
    }

    public class DateFormatter: Foundation.DateFormatter {

        public static let shared = DateFormatter()

        public private(set) lazy var iso: ISO8601DateFormatter = {
            self.dateStyle = .long
            self.timeStyle = .short
            let o = ISO8601DateFormatter()
            o.formatOptions.insert(.withFractionalSeconds)
            o.timeZone = .none
            return o
        }()

        override public func date(from string: String) -> Date? {
            iso.date(from: string)
        }

        override public func string(from date: Date) -> String {
            iso.string(from: date)
        }
    }

    public static func from(json data: Data, using decoder: JSONDecoder = Graph.JSON.Decoder()) throws -> Graph.JSON {
        try decoder.decode(Graph.JSON.self, from: data)
    }
}

extension Graph {

    public init(json: JSON) throws {

        var nodes: [Node.ID: Node] = [:]
        var root: Node!

        nodes.reserveCapacity(json.classes.count)

        for node in json.classes where node.mixin == nil {
            nodes[node.id] = node
            guard node.isRoot else { continue }
            guard root == nil else {
                throw Graph.Error(language: json.date, description: "Found two roots: '\(node)' and '\(root!)'")
            }
            root = node
        }

        guard root != nil else {
            throw Graph.Error(language: json.date, description: "Graph \(json.date) does not have a root node")
        }

        try self.init(date: json.date, nodes: nodes, root: root.id)
    }
}

extension Graph.Node {

    public struct JSON: Decodable {
        public let id: ID
        public let protonym: ID?
        public let type: [ID]?
        public let children: [Name]?
        public let synonyms: [Name: Protonym]?
        public let supertype: ID?
        public let mixin: Mixin?
    }

    public init(from decoder: Decoder) throws {
        let json = try JSON(from: decoder)
        self.init(
            id: json.id,
            name: json.id.suffixAfterLastDot().string,
            protonym: json.protonym,
            type: json.type.map(Set.init) ?? [],
            children: json.children.map(Set.init) ?? [],
            synonyms: json.synonyms,
            supertype: json.supertype,
            mixin: json.mixin
        )
    }
}
