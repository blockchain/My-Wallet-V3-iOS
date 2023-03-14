// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

extension App {

    public class DeepLink {

        private(set) unowned var app: AppProtocol

        private var rules: CurrentValueSubject<[Rule], Never> = .init([])
        private var bag: Set<AnyCancellable> = []

        init(_ app: AppProtocol) {
            self.app = app
        }

        func start() {
            app.publisher(for: blockchain.app.configuration.deep_link.rules, as: [Rule?].self)
                .compactMap(\.value)
                .map { rules in Array(rules.compacted()) }
                .removeDuplicates()
                .assign(to: \.rules.value, on: self)
                .store(in: &bag)

            app.on(blockchain.app.process.deep_link)
                .flatMap { [unowned self] event -> AnyPublisher<Session.Event, Never> in
                    app.publisher(for: blockchain.app.is.ready.for.deep_link, as: Bool.self)
                        .compactMap(\.value)
                        .filter { $0 }
                        .prefix(1)
                        .map { _ in event }
                        .eraseToAnyPublisher()
                }
                .flatMap { [unowned self] event -> AnyPublisher<(Session.Event, [Rule]), Never> in
                    rules
                        .map { rules in (event, rules) }
                        .eraseToAnyPublisher()
                }
                .sink { [weak self] event, rules in
                    self?.process(event: event, with: rules)
                }
                .store(in: &bag)
        }

        func process(event: Session.Event, with rules: [Rule]) {
            do {
                try process(
                    url: event.context.decode(blockchain.app.process.deep_link.url, as: URL.self),
                    with: rules
                )
            } catch {
                app.post(error: error)
            }
        }

        public func canProcess(url: URL) -> Bool {
            (app.state.yes(if: blockchain.app.deep_link.dsl.is.enabled) && DSL.isDSL(url))
                || (app.state.yes(if: blockchain.app.is.ready.for.deep_link) && rules.value.match(for: url) != nil)
        }

        func process(url: URL, with rules: [Rule]) {
            if app.state.yes(if: blockchain.app.deep_link.dsl.is.enabled), DSL.isDSL(url) {
                do {
                    let dsl = try DSL(url, app: app)
                    app.state.transaction { state in
                        for (tag, value) in dsl.context {
                            state.set(tag.in(app), to: value)
                        }
                    }
                    for (ref, value) in dsl.context where ref.tag.is(blockchain.session.configuration.value) {
                        app.remoteConfiguration.override(ref.in(app), with: value)
                    }
                    if let event = dsl.event {
                        let context = Tag.Context(dsl.context)
                        app.post(event: event.ref(to: context), context: context)
                    }
                } catch {
                    app.post(error: error)
                }
                return
            }
            guard let match = rules.match(for: url) else {
                return
            }
            let context = Tag.Context(match.parameters())
            app.state.transaction { state in
                for (tag, value) in context {
                    state.set(tag.in(app), to: value)
                }
            }
            app.post(event: match.rule.event.ref(to: context), context: context)
        }
    }
}

extension App.DeepLink {

    struct DSL: Equatable, Codable {
        var event: Tag.Reference?
        var context: [Tag.Reference: String] = [:]
    }
}

extension App.DeepLink.DSL {

    struct Error: Swift.Error {
        let message: String
    }

    static func isDSL(_ url: URL) -> Bool {
        url.path == "/app"
    }

    init(_ url: URL, app: AppProtocol) throws {
        guard App.DeepLink.DSL.isDSL(url) else {
            throw Error(message: "Not a \(Self.self): \(url)")
        }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw Error(message: "Failed to initialise a \(Self.self) from url \(url)")
        }
        event = try components.fragment.map { try Tag.Reference(id: $0, in: app.language) }
        var context: [Tag.Reference: String] = [:]
        for item in components.queryItems ?? [] {
            try context[Tag.Reference(id: item.name.removingPercentEncoding ?? item.name, in: app.language)] = item.value?.removingPercentEncoding ?? item.value
        }
        self.context = context
    }
}

extension App.DeepLink {
    public struct Rule: Codable, Equatable {
        public init(pattern: String, event: Tag.Reference, parameters: [App.DeepLink.Rule.Parameter]) {
            self.pattern = pattern
            self.event = event
            self.parameters = parameters
        }

        public let pattern: String
        public let event: Tag.Reference
        public let parameters: [Parameter]
    }
}

extension App.DeepLink.Rule {

    public struct Parameter: Codable, Equatable {
        public init(name: String? = nil, value: AnyJSON? = nil, alias: Tag.Event) {
            self.name = name
            self.value = value
            self.alias = alias.key(to: [:])
        }

        public let name: String?
        public let value: AnyJSON?
        public let alias: Tag.Reference
    }

    public struct Match {
        public let url: URL
        public let rule: App.DeepLink.Rule
        public let result: NSTextCheckingResult
    }
}

extension App.DeepLink.Rule.Match {
    public func parameters() -> [Tag.Reference: AnyHashable] {

        let items = url.queryItems()

        return rule.parameters
            .reduce(into: [:]) { rules, parameter in
                if let name = parameter.name {
                    let range = result.range(withName: name)
                    rules[parameter.alias] = range.location == NSNotFound
                        ? items[named: name]?.value
                        : NSString(string: url.absoluteString).substring(with: range)
                } else if let value = parameter.value {
                    rules[parameter.alias] = value
                }
            }
    }
}

extension URL {
    func queryItems() -> [URLQueryItem] {
        let components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        let queryItems = components?.queryItems ?? []

        // since the web only uses URL fragments followed by query items,
        // it seems to be the easiest way to get the query items back
        // ie: https://login.blockchain.com/#/app/asset?code=BTC
        let fragmentItems = URLComponents(string: components?.fragment ?? "")?
            .queryItems ?? []

        return queryItems + fragmentItems
    }
}

extension Collection<App.DeepLink.Rule> {

    public func match(for url: URL) -> App.DeepLink.Rule.Match? {
        lazy.compactMap { rule -> App.DeepLink.Rule.Match? in
            guard let pattern = try? NSRegularExpression(pattern: rule.pattern) else {
                return nil
            }
            let string = url.absoluteString
            guard let match = pattern.firstMatch(
                in: string,
                range: NSRange(string.startIndex..., in: string)
            ) else {
                return nil
            }
            return App.DeepLink.Rule.Match(
                url: url,
                rule: rule,
                result: match
            )
        }
        .first
    }
}

extension Collection<URLQueryItem> {

    public subscript(named name: String) -> URLQueryItem? {
        item(named: name)
    }

    public func item(named name: String) -> URLQueryItem? {
        first(where: { $0.name == name })
    }
}
