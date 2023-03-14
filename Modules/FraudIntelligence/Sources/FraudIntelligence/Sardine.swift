//
//  Copyright © 2022 Blockchain Luxembourg S.A. All rights reserved.
//

import Blockchain
import Combine

public final class Sardine<MobileIntelligence: MobileIntelligence_p>: Client.Observer {

    struct Flow: Decodable, Hashable {
        let name: String
        let event: Tag.Reference
        let start: Condition?
    }

    let app: AppProtocol
    let scheduler: AnySchedulerOf<DispatchQueue>

    var http: URLSessionProtocol
    private let baseURL = URL(string: "https://\(Bundle.main.plist?.RETAIL_CORE_URL ?? "api.blockchain.info/nabu-gateway")")!

    var bag: Set<AnyCancellable> = []
    var isProduction: Bool = false

    public init(
        _ app: AppProtocol,
        http: URLSessionProtocol = URLSession.shared,
        scheduler: AnySchedulerOf<DispatchQueue> = .main,
        isProduction: Bool = false,
        sdk _: MobileIntelligence.Type = MobileIntelligence.self
    ) {
        self.app = app
        self.http = http
        self.scheduler = scheduler
        self.isProduction = isProduction
    }

    // MARK: Observers

    var uuid: () -> String = { UUID().uuidString }

    public func start() {

        let session = uuid()
        app.state.set(blockchain.app.fraud.sardine.session, to: session)

        app.publisher(for: blockchain.app.fraud.sardine.client.identifier, as: String.self)
            .prefix(1)
            .sink { [weak self] id in
                guard let self else { return }
                self.initialise(
                    clientId: self.isProduction
                        ? (id.value ?? "01ac52dd-f1ed-4715-be81-1023407cdd82")
                        : "31d83c7d-c869-4ebb-a667-b89ec31aeb4e",
                    sessionKey: session
                )
            }
            .store(in: &bag)

        user.combineLatest(flow)
            .receive(on: scheduler)
            .sink { [weak self] user, flow in
                self?.update(userId: user, flow: flow)
            }
            .store(in: &bag)

        app.publisher(for: blockchain.app.fraud.sardine.flow, as: [Flow].self)
            .compactMap(\.value)
            .flatMap { [app] flows -> Publishers.MergeMany<AnyPublisher<Flow, Never>> in
                flows.map { flow in app.on(flow.event).replaceOutput(with: flow) }.merge()
            }
            .withLatestFrom(app.publisher(for: blockchain.app.fraud.sardine.supported.flows, as: Set<String>.self).compactMap(\.value)) { ($0, $1) }
            .sink { [app] flow, supported in
                guard supported.contains(flow.name) else { return }
                guard flow.start.or(.yes).check(in: app) else { return }
                app.post(value: flow.name, of: blockchain.app.fraud.sardine.current.flow)
            }
            .store(in: &bag)

        app.publisher(for: blockchain.app.fraud.sardine.trigger, as: [Tag.Reference?].self)
            .compactMap(\.value)
            .flatMap { [app] tags in
                tags.compacted().map { tag in app.on(tag) }.merge()
            }
            .withLatestFrom(flow) { ($0, $1) }
            .receive(on: scheduler)
            .sink { [app] _, flow in
                guard flow.isNotNil else { return }
                app.post(event: blockchain.app.fraud.sardine.submit)
            }
            .store(in: &bag)

        app.on(blockchain.session.event.did.sign.in, blockchain.session.event.did.sign.out) { [unowned self] event in
            switch event.tag {
            case blockchain.session.event.did.sign.in:
                try await request(token: app.stream(blockchain.user.token.nabu).compactMap(\.value).next())
            case blockchain.session.event.did.sign.out:
                request(token: nil)
            default:
                break
            }
        }
        .subscribe()
        .store(in: &bag)

        request(token: nil)

        event.start()
    }

    func request(token: String?) {
        var request = URLRequest(url: baseURL.appendingPathComponent("user/risk/settings"))
        let acceptLanguage = ["Accept-Language": "application/json"]
        do {
            request.allHTTPHeaderFields = try ["Authorization": "Bearer " + token.or(throw: "No Authorization Token")] + acceptLanguage
        } catch {
            request.allHTTPHeaderFields = acceptLanguage
        }

        http.dataTaskPublisher(for: request.peek("🌎", \.cURLCommand))
            .map(\.data)
            .decode(type: [String: [[String: String]]].self, decoder: JSONDecoder())
            .sink { [app] flows in
                app.state.set(blockchain.app.fraud.sardine.supported.flows, to: flows["flows"]?.map(\.["name"]))
            }
            .store(in: &bag)
    }

    public func stop() {
        bag.removeAll()
        event.stop()
    }

    // MARK: Values

    lazy var user = app.publisher(for: blockchain.user.id, as: String.self)
        .map(\.value)

    lazy var flow = app.publisher(for: blockchain.app.fraud.sardine.current.flow, as: String.self)
        .map(\.value)

    lazy var event = app.on(blockchain.app.fraud.sardine.submit) { [app, scheduler] event in
        scheduler.schedule {
            MobileIntelligence.submitData { response in
                if response.status == true {
                    app.post(
                        event: blockchain.app.fraud.sardine.submit.success,
                        context: event.context + [blockchain.app.fraud.sardine.submit.success: response.message]
                    )
                } else {
                    app.post(
                        event: blockchain.app.fraud.sardine.submit.failure,
                        context: event.context + [blockchain.app.fraud.sardine.submit.failure: response.message]
                    )
                }
            }
        }
    }

    // MARK: Sardine Integration

    var sardine: AnyObject?

    func initialise(clientId: String, sessionKey: String) {
        scheduler.schedule {
            var options = MobileIntelligence.Options()
            options.clientId = clientId
            options.sessionKey = sessionKey.sha256()
            if self.isProduction {
                options.environment = MobileIntelligence.Options.ENV_PRODUCTION
            } else {
                options.environment = MobileIntelligence.Options.ENV_SANDBOX
            }
            self.sardine = MobileIntelligence.start(withOptions: options)
        }
    }

    func update(userId: String?, flow: String?) {
        scheduler.schedule { [app] in
            var options = MobileIntelligence.UpdateOptions()
            options.userIdHash = userId?.sha256()
            if let flow {
                options.flow = flow
            }
            MobileIntelligence.updateOptions(options: options) { [app] _ in
                app.post(event: blockchain.app.fraud.sardine.submit)
            }
        }
    }
}

extension Sardine: CustomStringConvertible {
    public var description: String { "Sardine AI 🐟 \(bag.isEmpty ? "❌ Offline" : "✅ Online")" }
}

struct Condition: Decodable, Hashable {
    let `if`: [Tag.Reference]?
    let unless: [Tag.Reference]?
}

extension Condition {

    static var yes: Condition { Condition(if: nil, unless: nil) }

    func check(in app: AppProtocol) -> Bool {
        (`if` ?? []).allSatisfy(isYes(app)) && (unless ?? []).none(isYes(app))
    }
}

private func isYes(_ app: AppProtocol) -> (_ ref: Tag.Reference) -> Bool {
    { ref in result(app, ref).isYes }
}

private func result(_ app: AppProtocol, _ ref: Tag.Reference) -> FetchResult {
    switch ref.tag {
    case blockchain.session.state.value:
        return app.state.result(for: ref)
    case blockchain.session.configuration.value:
        return app.remoteConfiguration.result(for: ref)
    default:
        return .error(.keyDoesNotExist(ref), ref.metadata(.app))
    }
}
