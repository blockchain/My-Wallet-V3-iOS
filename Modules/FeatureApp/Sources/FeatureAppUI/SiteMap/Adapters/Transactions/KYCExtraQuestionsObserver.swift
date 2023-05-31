import BlockchainNamespace
import Combine
import DIKit
import Errors
import FeatureFormDomain
import FeatureKYCDomain
import ToolKit

public final class KYCExtraQuestionsObserver: Client.Observer {

    private var defaultContext = "TIER_TWO_VERIFICATION"

    unowned let app: AppProtocol
    let accountUsageService: KYCAccountUsageServiceAPI

    public init(
        app: AppProtocol,
        accountUsageService: KYCAccountUsageServiceAPI = resolve()
    ) {
        self.app = app
        self.accountUsageService = accountUsageService
    }

    private var bag: Set<AnyCancellable> = []

    /*
     // Remote Config for blockchain.ux.kyc.extra.questions.context.observer
     {
        "blockchain.ux.transaction[buy].event.will.start": "TRADING",
        "blockchain.ux.transaction[sell].event.will.start": "TRADING",
        "blockchain.ux.transaction[swap].event.will.start": "TRADING",
        "blockchain.ux.transaction[deposit].event.will.start": "FIAT_DEPOSIT",
        "blockchain.ux.transaction[withdraw].event.will.start": "FIAT_WITHDRAW",
        "blockchain.ux.payment.method.link.bank.wire": "FIAT_DEPOSIT",
        "blockchain.ux.payment.method.link.bank": "FIAT_DEPOSIT",
        "blockchain.ux.payment.method.link.card": "FIAT_DEPOSIT",
        "blockchain.ux.payment.method.link": "FIAT_DEPOSIT",
        "blockchain.ux.transaction[buy].event.validate.transaction": "TRADING",
        "blockchain.ux.transaction[buy].event.validate.source": "FIAT_DEPOSIT"
     }
     */

    public func start() {

        app.publisher(for: blockchain.ux.kyc.extra.questions.default.context, as: String.self)
            .compactMap(\.value)
            .assign(to: \.defaultContext, on: self)
            .store(in: &bag)

        app.publisher(for: blockchain.ux.kyc.extra.questions.context.observer, as: [String: String?].self)
            .map { result -> FetchResult.Value<[Tag.Reference: String?]> in
                let decoder = BlockchainNamespaceDecoder()
                return result.map { dictionary in
                    dictionary.compactMapKeys { key in try? decoder.decode(Tag.Reference.self, from: key) }
                }
            }
            .compactMap(\.value)
            .sink(to: My.observe, on: self)
            .store(in: &bag)
    }

    public func stop() {
        bag.removeAll()
    }

    private var refresh, observation, clear: AnyCancellable?

    private func observe(_ observers: [Tag.Reference: String?]) {

        let contexts = Set(
            [defaultContext] + observers.values.compacted().array
        )

        clear = app.on(blockchain.ux.kyc.extra.questions.clear) { [app] _ in
            app.state.transaction { state in
                state.clear(blockchain.ux.kyc.extra.questions.form.id)
                for context in observers.values.compacted().set {
                    state.clear(blockchain.ux.kyc.extra.questions.form[context].data)
                    state.clear(blockchain.ux.kyc.extra.questions.form[context].is.empty)
                }
            }
        }
        .subscribe()

        refresh = app.on(blockchain.session.event.did.sign.in, blockchain.ux.kyc.event.status.did.change)
            .replaceOutput(with: contexts.array)
            .flatMap(refresh(contexts:))
            .sink { [app] forms in
                app.state.clear(blockchain.ux.kyc.extra.questions.form.id)
                app.state.transaction { state in
                    for (context, form) in forms {
                        let tag = blockchain.ux.kyc.extra.questions.form
                        state.set(tag[context].data, to: form)
                        state.set(tag[context].is.empty, to: form.success?.isEmpty)
                    }
                }
            }

        observation = observers.map { tag, context in
            app.on(tag).handleEvents(
                receiveOutput: { [app] _ in
                    app.state.set(blockchain.ux.kyc.extra.questions.form.id, to: context)
                }
            )
        }
        .merge()
        .subscribe()
    }

    private typealias Form = Result<FeatureFormDomain.Form, Nabu.Error>

    private func refresh(
        contexts: [String]
    ) -> AnyPublisher<[(String, Form)], Never> {
        contexts.map { context in
            accountUsageService.fetchExtraKYCQuestions(context: context)
                .result()
                .map { (context, $0) }
        }
        .merge()
        .collect()
        .eraseToAnyPublisher()
    }
}
