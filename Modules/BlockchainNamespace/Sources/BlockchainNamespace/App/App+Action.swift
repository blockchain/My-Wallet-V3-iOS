import Foundation

extension Session.Event {
    public var action: Action? { context[blockchain.ui.type.action[]] as? Action }
}

public struct Action: Equatable, Hashable {

    public let tag: L_blockchain_ui_type_action
    public let event: Tag.Reference
    public let data: AnyJSON
    public let date: Date

    public init(
        tag: L_blockchain_ui_type_action,
        event: Tag.Reference,
        data: AnyJSON,
        date: Date = .init()
    ) {
        self.tag = tag
        self.event = event
        self.data = AnyJSON(data)
        self.date = date
    }
}

extension AppProtocol {

    func handle(action event: Session.Event) async throws {
        let id = try event.tag.as(blockchain.ui.type.action)
        let data = try await get(event.reference, as: ActionData.self)
        guard await should(perform: event.reference, given: data) else { return }
        try perform(id, event: event, with: data)
    }

    func should(perform key: Tag.Reference, given data: ActionData) async -> Bool {
        if data.policy?.discard?.if == true { return false }
        if data.policy?.discard?.when == true { return false }
        if data.policy?.perform?.if == false { return false }
        if data.policy?.perform?.when == false {
            for await data in stream(key, as: ActionData.self).compactMap(\.value) {
                if data.policy?.discard?.if == true || data.policy?.discard?.when == true { return false }
                if data.policy?.perform?.if == true || data.policy?.perform?.when == true { return true }
            }
            return false
        }
        return true
    }

    func perform(_ action: L_blockchain_ui_type_action, event: Session.Event, with data: ActionData) throws {
        var json = try data.then.dictionary().or(throw: "Expected [String: Any]")
        var emit: (tag: Tag, value: Tag.Reference)?
        defer {
            if let emit {
                post(
                    event: emit.value,
                    context: event.context + [blockchain.ui.type.action: Action(tag: action, event: emit.value, data: nil)],
                    file: event.source.file,
                    line: event.source.line
                )
            }
        }
        if let tag = try? json["emit"].decode(Tag.Reference.self) {
            emit = (action.then.emit[], tag.key(to: event.reference.context))
            json["emit"] = nil
        }
        guard json.isNotEmpty else { return }
        let tag = try action.then[].lastDeclaredDescendant(in: json, policy: .throws)
        let data = try action.then[].value(in: data.then, at: tag)
        let key = tag.ref(to: event.reference.context, in: self)
        post(
            event: key,
            context: event.context + [blockchain.ui.type.action: Action(tag: action, event: key, data: data)],
            file: event.source.file,
            line: event.source.line
        )
    }
}

public struct ActionData: Decodable, Equatable {
    public let then: AnyJSON
    public let policy: Policy?
}

extension ActionData {

    public struct Policy: Decodable, Equatable {
        public let perform: Conditions?
        public let discard: Conditions?
    }

    public struct Conditions: Decodable, Equatable {
        public let `if`: Bool?
        public let when: Bool?
    }
}
