// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import Lexicon

public final class Language: @unchecked Sendable {

    public let graph: Lexicon.Graph
    public var date: Date { graph.date }

    public private(set) var root: Tag!

    private let lock = NSRecursiveLock()

    var _nodes: [Tag.ID: Tag] = [:]
    var nodes: [Tag.ID: Tag] {
        get { sync { _nodes } }
        set { sync { _nodes = newValue } }
    }

    private init(graph: Lexicon.Graph) throws {
        self.graph = graph
        self.root = Tag.add(parent: nil, node: graph.root, to: self)
        Self.unownedLanguageReferences.append(self)
    }
}

extension Language {

    private static var count: UInt = 0
    private static let lock = NSLock()
    private static var id: UInt {
        lock.lock()
        defer { lock.unlock() }
        count += 1
        return count
    }

    func sync<T>(execute work: () throws -> T) rethrows -> T {
        lock.lock()
        defer { lock.unlock() }
        return try work()
    }
}

extension Language {

    public subscript(id: Tag.ID) -> Tag? { tag(id) }
    public subscript(id: L) -> Tag {
        guard let tag = tag(id(\.id)) else {
            fatalError(
                """
                \(id) does not exist in the language. Check the lexicon has been saved and generated.
                You may have removed an id from the lexicon but are still referencing it from the code.
                """
            )
        }
        return tag
    }

    public func tag(_ id: Tag.ID) -> Tag? {
        sync { nodes[id] ?? root[id.dotPath(after: root.id).splitIfNotEmpty(separator: ".").string] }
    }
}

extension Language {

    public static func root(of graph: Lexicon.Graph) throws -> Tag {
        try Language(graph: graph).root
    }

    public static func root(taskpaper: Data) throws -> Tag {
        try root(of: TaskPaper(taskpaper).decode())
    }
}

extension Language {

    public static let errors: AnyPublisher<Tag.Error, Never> = subject
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()

    private static let subject = PassthroughSubject<Tag.Error, Never>()

    public func post(
        error description: String,
        file: String = #fileID,
        line: Int = #line
    ) {
        let error = blockchain.namespace.language.error[].error(
            message: description,
            file: file,
            line: line
        )
        Language.subject.send(error)
        #if DEBUG
        fatalError(String(describing: error))
        #endif
    }

    public func post(error: Error, file: String = #fileID, line: Int = #line) {
        post(error: error.localizedDescription, file: file, line: line)
    }
}

extension Language {

    // swiftlint:disable force_try
    public static let root: Tag = try! Language.root(
        taskpaper: Data(contentsOf: "blockchain".lexicon)
    )

    static var unownedLanguageReferences: [Language] = []
}

extension Language: Identifiable, Hashable {

    public static func == (lhs: Language, rhs: Language) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension String {

    fileprivate var lexicon: URL {
        URL(fileURLWithPath: Bundle.namespace.path(forResource: self, ofType: "lexicon")!)
    }
}
