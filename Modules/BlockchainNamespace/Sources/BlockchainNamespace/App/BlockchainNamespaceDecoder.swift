// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnyCoding

open class BlockchainNamespaceDecoder: AnyDecoder {

    var context: Tag.Context = [:]
    var language: Language {
        userInfo[.language] as? Language ?? Language.root.language
    }

    override public func convert<T>(_ any: Any, to type: T.Type) throws -> Any? {
        switch (any, type) {
        case (let tag as Tag, is Tag.Reference.Type):
            return tag.ref(to: context)
        case (let ref as Tag.Reference, is Tag.Type):
            return ref.tag
        case (let id as L, is Tag.Type):
            return id[]
        case (let id as L, is Tag.Reference.Type):
            return id[].ref(to: context)
        case (let string as String, is Tag.Type):
            return try Tag(id: string, in: language)
        case (let string as String, is Tag.Reference.Type):
            return try Tag.Reference(id: string, in: language)
        case (let event as Tag.Event, is Tag.Reference.Type):
            return event.key(to: context)
        default:
            switch (any, Wrapper<T>.self) {
            case (let string as String, let enumRepresentable as EnumRepresentable.Type):
                return try enumRepresentable.value(from: string, using: self)
            case (let tag as Tag.Event, let enumRepresentable as EnumRepresentable.Type):
                return try enumRepresentable.value(from: tag.description, using: self)
            default:
                return try super.convert(any, to: type)
            }
        }
    }
}

extension AnyJSON {

    @inlinable public func decode<T: Decodable>(
        _: T.Type = T.self,
        using decoder: AnyDecoderProtocol = BlockchainNamespaceDecoder()
    ) throws -> T {
        try decoder.decode(T.self, from: wrapped)
    }
}

private protocol EnumRepresentable {
    static func value(from any: String, using decoder: BlockchainNamespaceDecoder) throws -> Any?
}

private enum Wrapper<T> {}

extension Wrapper: EnumRepresentable where T: RawRepresentable, T.RawValue == String {
    static func value(from any: String, using decoder: BlockchainNamespaceDecoder) throws -> Any? {
        if let direct = T(rawValue: any) {
            return direct
        } else {
            guard let tag = try? Tag(id: any, in: decoder.language) else { return nil }
            guard let parent = tag.lineage.first(where: { $0.is(blockchain.db.type.enum) }) else { return nil }
            return try T(rawValue: tag.idRemainder(after: parent).string)
        }
    }
}
