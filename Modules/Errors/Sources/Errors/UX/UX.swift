import BlockchainNamespace
import Extensions
import Foundation
import Localization
import OrderedCollections

// swiftlint:disable type_name
public enum UX {

    public struct Error: Swift.Error {

        public typealias Metadata = OrderedDictionary<String, String>

        public var source: Swift.Error?

        public var id: String?
        public var title: String
        public var message: String
        public var expected: Bool = true
        public var icon: UX.Icon?
        public var metadata: Metadata
        public var actions: [Action]
        public var categories: [String] = []

        public private(set) var dialog: UX.Dialog?

        public init(
            source: Swift.Error? = nil,
            id: String? = nil,
            title: String,
            message: String,
            icon: UX.Icon? = nil,
            metadata: Metadata = [:],
            actions: [UX.Action] = .default
        ) {
            self.source = source
            self.id = id ?? extract(Nabu.Error.self, from: source)?.ux?.id
            self.title = title
            self.message = message
            self.icon = icon
            self.metadata = metadata
            self.actions = actions
        }

        public init(
            source: Swift.Error? = nil,
            id: String? = nil,
            title: String?,
            message: String?,
            icon: UX.Icon? = nil,
            metadata: Metadata = [:],
            actions: [UX.Action] = .default
        ) {
            self.source = source
            self.id = id ?? extract(Nabu.Error.self, from: source)?.ux?.id
            self.title = title ?? L10n.oops.title
            self.message = message ?? L10n.oops.message
            self.icon = icon
            self.metadata = metadata
            self.actions = actions
            self.expected = title != nil
        }
    }
}

extension UX.Error: Equatable {

    public static func == (lhs: UX.Error, rhs: UX.Error) -> Bool {
        lhs.id == rhs.id
            && lhs.title == rhs.title
            && lhs.message == rhs.message
            && lhs.icon == rhs.icon
            && lhs.metadata == rhs.metadata
            && lhs.actions == rhs.actions
            && String(describing: lhs.source) == String(describing: rhs.source)
    }
}

extension UX.Error: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(message)
        hasher.combine(icon)
        hasher.combine(metadata)
        hasher.combine(actions)
    }
}

extension UX.Error: CustomStringConvertible {
    public var description: String {
        """
        UX.Error(id: \(String(describing: id)))

        \(title)
        \(message)
        """
    }
}

typealias L10n = LocalizationConstants.UX.Error

extension UX.Error {

    public init(nabu: Nabu.Error) {

        var metadata: Metadata = [:]

        source = nabu

        if let ux = nabu.ux {
            id = ux.id
            title = ux.title
            message = ux.message
            icon = ux.icon
            actions = ux.actions ?? []
            categories = ux.categories ?? []
            dialog = ux
        } else {
            id = nil
            title = L10n.networkError.title
            message = nabu.description ?? L10n.oops.message
            icon = nil
            actions = .default
            expected = false
        }

        if let request = nabu.request {
            if let id = request.allHTTPHeaderFields?["X-Request-ID"] {
                metadata[L10n.request] = id
            }
        }

        self.metadata = metadata
    }

    public init(nabu ux: UX.Dialog) {
        source = nil
        id = ux.id
        title = ux.title
        message = ux.message
        icon = ux.icon
        actions = ux.actions ?? .default
        metadata = [:]
        categories = ux.categories ?? []
        dialog = ux
    }
}

extension UX.Error {

    public init(error: Swift.Error?) {
        switch error {
        case let ux as UX.Error:
            self = ux
        case let nabu as Nabu.Error:
            self.init(nabu: nabu)
        default:
            if let ux = extract(UX.Error.self, from: error) {
                self = ux
            } else if let ux = extract(Nabu.Error.self, from: error) {
                self = Self(nabu: ux)
            } else if let ux = extract(UX.Dialog.self, from: error) {
                self = Self(nabu: ux)
            } else {
                self.init(
                    source: error,
                    title: L10n.oops.title,
                    message: L10n.oops.message,
                    icon: nil,
                    metadata: [:],
                    actions: .default
                )
                expected = false
            }
        }
    }
}

extension [UX.Action] {

    public static var `default`: Self = [
        UX.Action(title: L10n.ok)
    ]
}

extension UX.Error: TimeoutFailure {

    public static var timeout: UX.Error {
        UX.Error(error: nil)
    }
}

extension UX.Error {

    public func context(in app: AppProtocol) -> Tag.Context {
        let nabu = extract(Nabu.Error.self, from: source)
        let network = extract(NetworkError.self, from: source)
        return [
            blockchain.ux.error.context.id: id,
            blockchain.ux.error.context.type: expected
                ? (try? app.state.get(blockchain.ux.error.context.type, as: String.self))?.snakeCase().uppercased() ?? "ERROR"
                : "OOPS_ERROR",
            blockchain.ux.error.context.action: (
                try? app.state.get(blockchain.ux.error.context.action, as: String.self)
            )?.snakeCase().uppercased() ?? "NONE",
            blockchain.ux.error.context.category: categories,
            blockchain.ux.error.context.network.endpoint: nabu?.request?.url?.path ?? network?.request?.url?.path,
            blockchain.ux.error.context.network.error.code: nabu?.code.rawValue.description ?? network?.response?.statusCode.description,
            blockchain.ux.error.context.network.error.description: nabu?.description ?? extract(CustomStringConvertible.self, from: self).description,
            blockchain.ux.error.context.network.error.id: nabu?.id,
            blockchain.ux.error.context.network.error.type: nabu?.type.rawValue,
            blockchain.ux.error.context.title: title,
            blockchain.ux.error.context.source: nabu.isNotNil ? "NABU" : "CLIENT"
        ]
    }
}
