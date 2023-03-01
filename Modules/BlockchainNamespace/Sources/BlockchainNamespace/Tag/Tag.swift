// Copyright © Blockchain Luxembourg S.A. All rights reserved.
// swiftlint:disable type_name

import Extensions
import Foundation
import Lexicon

public struct Tag {

    public typealias ID = String
    public typealias Name = String

    public let id: ID
    public var name: Name { node.name }

    public let node: Node
    public unowned let language: Language

    @inlinable public var parent: Tag? { lazy(\.parent) }
    private let parentID: ID?

    var isGraphNode: Bool { lazy(\.isGraphNode) }

    @inlinable public var protonym: Tag? { lazy(\.protonym) }
    @inlinable public var ownChildren: [Name: Tag] { lazy(\.ownChildren) }
    @inlinable public var children: [Name: Tag] { lazy(\.children) }
    @inlinable public var ownType: [ID: Tag] { lazy(\.ownType) }
    @inlinable public var type: [ID: Tag] { lazy(\.type) }
    @inlinable public var privacyPolicy: Tag { lazy(\.privacyPolicy) }
    @inlinable public var lineage: UnfoldFirstSequence<Tag> { lazy(\.lineage) }

    @inlinable public var NAPI: L_blockchain_namespace_napi? { lazy(\.NAPI) }
    @inlinable public var isNAPI: Bool { lazy(\.isNAPI) }
    @inlinable public var isRootNAPI: Bool { lazy(\.isRootNAPI) }
    @inlinable public var isRootNAPIDescendant: Bool { lazy(\.isRootNAPIDescendant) }

    private var lazy = Lazy()

    init(parent: ID?, node: Lexicon.Graph.Node, in language: Language) {
        self.parentID = parent
        self.id = parent?.dot(node.name) ?? node.name
        self.node = .init(graph: node)
        self.language = language
    }
}

extension Tag {

    @dynamicMemberLookup
    public class Node {
        let graph: Lexicon.Graph.Node
        init(graph: Lexicon.Graph.Node) { self.graph = graph }
        subscript<T>(dynamicMember keyPath: KeyPath<Lexicon.Graph.Node, T>) -> T {
            graph[keyPath: keyPath]
        }
    }

    @usableFromInline var template: Tag.Reference.Template { lazy(\.template) }

    @usableFromInline var isCollection: Bool { lazy(\.isCollection) }
    @usableFromInline var isLeaf: Bool { lazy(\.isLeaf) }
    @usableFromInline var isLeafDescendant: Bool { lazy(\.isLeafDescendant) }

    @usableFromInline var breadcrumb: [Tag] { lazy(\.breadcrumb) }
}

extension Tag {

    @usableFromInline func lazy<T>(_ keyPath: KeyPath<Lazy, T>) -> T {
        language.sync { lazy[self][keyPath: keyPath] }
    }

    @usableFromInline final class Lazy {

        var my: Tag!

        init() {}

        fileprivate subscript(tag: Tag) -> Lazy {
            my = tag; return self
        }

        @usableFromInline lazy var parent: Tag? = my.parentID.flatMap(my.language.tag)
        @usableFromInline lazy var isGraphNode: Bool = my.parent.map { parent in
            parent.isGraphNode && parent.node.children.keys.contains(my.name)
        } ?? true

        @usableFromInline lazy var protonym: Tag? = Tag.protonym(of: my)
        @usableFromInline lazy var children: [Name: Tag] = Tag.children(of: my)
        @usableFromInline lazy var ownType: [ID: Tag] = Tag.ownType(my)
        @usableFromInline lazy var ownChildren: [Name: Tag] = Tag.ownChildren(of: my)
        @usableFromInline lazy var type: [ID: Tag] = Tag.type(of: my)
        @usableFromInline lazy var privacyPolicy: Tag = Tag.privacyPolicy(of: my)
        @usableFromInline lazy var lineage: UnfoldFirstSequence<Tag> = Tag.lineage(of: my)

        @usableFromInline lazy var NAPI: L_blockchain_namespace_napi? = try? Tag.NAPI(my)
        @usableFromInline lazy var isNAPI: Bool = Tag.isNAPI(my)
        @usableFromInline lazy var isRootNAPI: Bool = Tag.isRootNAPI(my)
        @usableFromInline lazy var isRootNAPIDescendant: Bool = Tag.isRootNAPIDescendant(my)

        @usableFromInline lazy var template: Tag.Reference.Template = .init(my)
        @usableFromInline lazy var isCollection: Bool = Tag.isCollection(my)
        @usableFromInline lazy var isLeaf: Bool = Tag.isLeaf(my)
        @usableFromInline lazy var isLeafDescendant: Bool = Tag.isLeafDescendant(my)
        @usableFromInline lazy var breadcrumb: [Tag] = lineage.reversed().prefix(while: \.isLeafDescendant.not)
    }
}

extension Tag {

    public init(_ identifier: L, in language: Language) {
        do {
            self = try Tag(id: identifier(\.id), in: language)
        } catch {
            fatalError(
                """
                Failed to load language from identifier \(identifier(\.id))
                \(error)
                """
            )
        }
    }

    public init(id: String, in language: Language) throws {
        if id.isEmpty {
            self = blockchain.db.type.tag.none[]
        } else if let tag = language.tag(id) {
            self = tag
        } else {
            throw blockchain[].error(message: "'\(id)' does not exist in language")
        }
    }
}

extension Tag {

    public func `as`<T: L>(_ other: T) throws -> T {
        guard `is`(other) else {
            throw error(message: "\(self) is not a \(other)")
        }
        return T(id)
    }
}

extension Tag {

    public func `is`(_ type: Tag.Event) -> Bool {
        `is`(type[])
    }

    public func `is`(_ types: Tag.Event...) -> Bool {
        for type in types where isNot(type) { return false }
        return true
    }

    public func `is`(_ tag: Tag) -> Bool {
        type[tag.id] != nil
    }

    public func `is`(_ types: Tag...) -> Bool {
        for type in types where isNot(type) { return false }
        return true
    }

    public func `is`(_ types: some Sequence<Tag>) -> Bool {
        for type in types where isNot(type) { return false }
        return true
    }

    public func isNot(_ type: Tag.Event) -> Bool {
        `is`(type) == false
    }

    public func isNot(_ type: Tag) -> Bool {
        `is`(type) == false
    }
}

public func ~= (lhs: Tag.Event, rhs: Tag.Event) -> Bool {
    rhs[].is(lhs[])
}

public func ~= (lhs: Tag.Event, rhs: Tag.Reference) -> Bool {
    rhs[].is(lhs[]) && lhs.key(to: [:]).context.allSatisfy { rhs.context[$0] == $1 }
}

extension Tag {

    public func isAncestor(of other: Tag) -> Bool {
        id.isDotPathAncestor(of: other.id)
    }

    public func isNotAncestor(of other: Tag) -> Bool {
        !isAncestor(of: other)
    }

    public func isDescendant(of other: Tag) -> Bool {
        id.isDotPathDescendant(of: other.id)
    }

    public func isNotDescendant(of other: Tag) -> Bool {
        !isDescendant(of: other)
    }

    public func idRemainder(after tag: Tag) throws -> Substring {
        guard isDescendant(of: tag) else {
            throw error(message: "\(tag) is not an ancestor of \(self)")
        }
        return id.dotPath(after: tag.id)
    }
}

public func ~= <T>(pattern: (T) -> Bool, value: T) -> Bool {
    pattern(value)
}

public func isAncestor(of a: L) -> (Tag) -> Bool {
    isAncestor(of: a[])
}

public func isAncestor(of a: Tag) -> (Tag) -> Bool {
    { b in b.isAncestor(of: a) }
}

public func isDescendant(of a: L) -> (Tag) -> Bool {
    isDescendant(of: a[])
}

public func isDescendant(of a: Tag) -> (Tag) -> Bool {
    { b in b.isDescendant(of: a) }
}

extension Tag {

    public subscript(dotPath descendant: String) -> Tag? {
        self[descendant.splitIfNotEmpty().map(String.init)]
    }

    public subscript(descendant: Name...) -> Tag? {
        self[descendant]
    }

    public subscript(
        descendant: some Collection<Name>
    ) -> Tag? {
        try? self.descendant(descendant)
    }

    public func descendant(
        _ descendant: some Collection<Name>
    ) throws -> Tag {
        var result = self
        for name in descendant {
            result = try result.child(named: name)
        }
        return result
    }

    public func child(named name: Name) throws -> Tag {
        guard let child = children[name] else {
            throw error(message: "\(self) does not have a child '\(name)' - it has children: \(children)")
        }
        return child.protonym ?? child
    }

    public func distance(to tag: Tag) throws -> Int {
        if isDescendant(of: tag) {
            return id.dotPath(after: tag.id).splitIfNotEmpty().count
        } else if isAncestor(of: tag) {
            return tag.id.dotPath(after: id).splitIfNotEmpty().count
        } else {
            throw error(message: "\(self) is not similar to \(tag)")
        }
    }
}

extension Tag {

    static func isCollection(_ tag: Tag) -> Bool {
        tag.is(blockchain.db.collection)
    }

    static func isLeaf(_ tag: Tag) -> Bool {
        guard tag.parent != nil else { return false }
        return !tag.is(blockchain.session.state.value)
            && !tag.isLeafDescendant
            && (tag.children.isEmpty || tag.is(blockchain.db.leaf))
    }

    static func isLeafDescendant(_ tag: Tag) -> Bool {
        guard let parent = tag.parent else { return false }
        return parent.isLeafDescendant || parent.isLeaf
    }

    static func privacyPolicy(of tag: Tag) -> Tag {
        tag.lineage.first(where: { tag in tag.is(blockchain.ux.type.analytics.privacy.policy) })
            ?? blockchain.ux.type.analytics.privacy.policy.include[]
    }
}

extension Tag {

    public var analytics: Analytics { Analytics(privacyPolicy) }

    public struct Analytics {

        let policy: Tag
        init(_ policy: Tag) {
            self.policy = policy
        }

        public var isIncluded: Bool {
            policy.is(blockchain.ux.type.analytics.privacy.policy.include)
        }

        public var isExcluded: Bool {
            policy.is(blockchain.ux.type.analytics.privacy.policy.exclude)
        }

        public var isObfuscated: Bool {
            policy.is(blockchain.ux.type.analytics.privacy.policy.obfuscate)
        }
    }
}

extension Tag {

    @discardableResult
    static func add(parent: ID?, node: Lexicon.Graph.Node, to language: Language) -> Tag {
        let id = parent?.dot(node.name) ?? node.name
        if let node = language.nodes[id] { return node }
        let tag = Tag(parent: parent, node: node, in: language)
        language.nodes[tag.id] = tag
        return tag
    }

    static func lineage(of id: Tag) -> UnfoldFirstSequence<Tag> {
        sequence(first: id, next: \.parent)
    }

    static func protonym(of tag: Tag) -> Tag? {
        guard let suffix = tag.node.protonym else {
            return nil
        }
        guard let parent = tag.parent else {
            assertionFailure("Synonym '\(suffix)', tag '\(tag.id)', does not have a parent.")
            return nil
        }
        guard let protonym = parent[suffix.components(separatedBy: ".")] else {
            assertionFailure("Could not find protonym '\(suffix)' of \(tag.id)")
            return nil
        }

        tag.language.nodes[tag.id] = protonym // MARK: always map synonym to its protonym

        return .init(protonym)
    }

    static func ownChildren(of tag: Tag) -> [Name: Tag] {
        var ownChildren: [Name: Tag] = [:]
        for (name, node) in tag.node.children {
            ownChildren[name] = Tag.add(parent: tag.id, node: node, to: tag.language)
        }
        return ownChildren
    }

    static func children(of tag: Tag) -> [Name: Tag] {
        if let protonym = tag.protonym {
            var children: [Name: Tag] = [:]
            for (name, child) in protonym.children {
                children[name] = Tag.add(parent: tag.id, node: child.node.graph, to: tag.language)
            }
            return children
        } else {
            var ownChildren = tag.ownChildren
            for (_, type) in tag.ownType {
                for (name, child) in type.children {
                    ownChildren[name] = Tag.add(parent: tag.id, node: child.node.graph, to: tag.language)
                }
            }
            return ownChildren
        }
    }

    static func ownType(_ tag: Tag) -> [ID: Tag] {
        var type: [ID: Tag] = [:]
        if tag.isGraphNode {
            for id in tag.node.type {
                type[id] = tag.language.tag(id)
            }
        } else if let parent = tag.lineage.first(where: \.isGraphNode) {
            let descendant = tag.id.dotPath(after: parent.id).splitIfNotEmpty().string
            for id in parent.node.type {
                guard let node = tag.language.tag(id)?[descendant] else { continue }
                type[node.id] = node
            }
        }
        return type
    }

    static func type(of tag: Tag) -> [ID: Tag] {
        if let protonym = tag.node.protonym, let tag = tag.language.tag(protonym) {
            return tag.type
        }
        var type = tag.ownType
        type[tag.id] = tag
        for (_, tag) in tag.ownType {
            type.merge(tag.type) { o, _ in o }
        }
        return type
    }

    static func NAPI(_ tag: Tag) throws -> L_blockchain_namespace_napi {
        try tag.lineage.first(where: \.isRootNAPI)
            .or(throw: "No NAPI ancestor in \(tag)")
            .as(blockchain.namespace.napi)
    }

    static func isNAPI(_ tag: Tag) -> Bool {
        tag.isRootNAPIDescendant
    }

    static func isRootNAPI(_ tag: Tag) -> Bool {
        tag.is(blockchain.namespace.napi)
    }

    static func isRootNAPIDescendant(_ tag: Tag) -> Bool {
        guard let parent = tag.parent else { return false }
        return parent.isRootNAPIDescendant || (parent.isRootNAPI && tag.name != "napi")
    }
}

extension Tag {

    public func value<T>(
        in data: AnyJSON,
        at descendant: Tag,
        as type: T.Type = AnyJSON.self
    ) throws -> T {
        try value(in: data.as([String: Any].self), at: descendant, as: type)
    }

    public func value<T>(
        in data: [String: Any],
        at descendant: Tag,
        as type: T.Type = AnyJSON.self
    ) throws -> T {
        let path = try descendant.idRemainder(after: self).string
        guard let any = data[dotPath: path] else {
            throw error(message: "No value found at \(path) in \(self) data: \(data)")
        }
        switch type {
        case is AnyJSON.Type:
            return AnyJSON(any) as! T
        default:
            return try (any as? T).or(throw: error(message: "\(any) is not a \(T.self)"))
        }
    }

    public enum DeclaredDescendantMultipleOptionsPolicy {
        case any
        case `throws`
        case priority((_ tag: Tag, _ children: Set<Tag>) throws -> Tag)
    }

    public func lastDeclaredDescendant(
        in data: AnyJSON,
        policy: DeclaredDescendantMultipleOptionsPolicy
    ) throws -> Tag {
        try lastDeclaredDescendant(in: data.as([String: Any].self), policy: policy)
    }

    public func lastDeclaredDescendant(
        in data: [String: Any],
        policy: DeclaredDescendantMultipleOptionsPolicy
    ) throws -> Tag {

        var tag = self
        var data = data

        repeat {

            let options = tag.children.keys.set
                .intersection(data.keys.set)
                .compactMap { name in
                    tag[name].map { (name: name, child: $0) }
                }

            var name: String?

            switch policy {
            case .throws where options.count > 1:
                throw error(message: "Multiple options breaks \(policy) policy for \(tag) in \(self) - options: \(options)")

            case .priority(let ƒ) where options.count > 1:
                tag = try ƒ(tag, options.map(\.1).set)
                name = options.first(where: { $0.child == tag })?.name

            case .any, .throws, .priority:
                guard let any = options.first else {
                    throw error(message: "None of \(data.keys.set) are uninherited children of \(tag)")
                }
                tag = any.child
                name = any.name
            }

            guard
                !tag.isLeaf,
                !tag.node.children.isEmpty,
                let key = name,
                let remainder = data[key] as? [String: Any]
            else { break }

            data = remainder
        } while true

        return tag
    }
}

extension Tag: Equatable, Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: Tag, rhs: Tag) -> Bool {
        lhs.id == rhs.id && lhs.language == rhs.language
    }

    public static func == (lhs: Tag, rhs: L) -> Bool {
        lhs == rhs[lhs.language]
    }

    public static func == (lhs: L, rhs: Tag) -> Bool {
        lhs[rhs.language] == rhs
    }
}

extension CodingUserInfoKey {
    public static let language = CodingUserInfoKey(rawValue: "com.blockchain.namespace.language")!
    public static let context = CodingUserInfoKey(rawValue: "com.blockchain.namespace.context")!
}

extension Tag: Codable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let language = decoder.userInfo[.language] as? Language ?? Language.root.language
        let id = try container.decode(String.self)
        let tag = try Self(id: id, in: language)
        self = tag.protonym ?? tag
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(id)
    }
}

extension Tag: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String { id }
    public var debugDescription: String { id }
}

extension L {
    public subscript() -> Tag { self[Language.root.language] }
    public subscript(language: Language) -> Tag { Tag(self, in: language) }
}

// MARK: - Static Tag

extension I where Self: L {
    public subscript(value: some Sendable & Hashable) -> Tag.KeyTo<L> {
        Tag.KeyTo(id: self, context: [self: value])
    }
}

extension I_blockchain_db_collection where Self: L {

    public subscript(value: String) -> Tag.KeyTo<Self> {
        Tag.KeyTo(id: self, context: [id: value])
    }

    @_disfavoredOverload
    public subscript(value: some CustomStringConvertible) -> Tag.KeyTo<Self> {
        Tag.KeyTo(id: self, context: [id: value.description])
    }

    public subscript(value: some RawRepresentable<String>) -> Tag.KeyTo<Self> {
        Tag.KeyTo(id: self, context: [id: value.rawValue])
    }
}

extension Tag.KeyTo where A: I_blockchain_db_collection {

    public subscript(value: String) -> Tag.KeyTo<A> {
        Tag.KeyTo(id: id, context: context + [id.id: value])
    }

    public subscript(event: Tag.Event) -> Tag.KeyTo<A> {
        Tag.KeyTo(id: id, context: context + [id.id: event.description])
    }

    public subscript(value: some RawRepresentable<String>) -> Tag.KeyTo<A> {
        Tag.KeyTo(id: id, context: context + [id.id: value.rawValue])
    }
}

extension Tag {

    @dynamicMemberLookup
    public struct KeyTo<A: L>: Hashable {

        private let id: A
        private let context: [L: AnyHashable]

        internal init(id: A, context: [L: AnyHashable]) {
            self.id = id
            self.context = context
        }

        public subscript<B: L>(dynamicMember keyPath: KeyPath<A, B>) -> KeyTo<B> {
            KeyTo<B>(id: id[keyPath: keyPath], context: context)
        }

        public subscript(value: some Sendable & Hashable) -> KeyTo<A> {
            KeyTo(id: id, context: context + [id: value])
        }
    }
}

extension Tag.KeyTo: Tag.Event, CustomStringConvertible {

    public var description: String { id(\.id) }
    public func key(to context: Tag.Context = [:]) -> Tag.Reference {
        id[].ref(to: Tag.Context(self.context) + context)
    }

    public subscript() -> Tag {
        id[]
    }

    public func callAsFunction(
        in context: Tag.Context = [:]
    ) -> Tag.Reference {
        key(to: context)
    }

    public func callAsFunction<Value>(
        _ keyPath: KeyPath<Tag.Reference, Value>,
        in context: Tag.Context = [:]
    ) -> Value {
        key(to: context)[keyPath: keyPath]
    }
}
