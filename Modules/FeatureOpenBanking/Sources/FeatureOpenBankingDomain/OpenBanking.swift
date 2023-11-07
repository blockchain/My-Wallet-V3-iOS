// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import DIKit
import Foundation

public final class OpenBanking {

    public struct Data: Hashable {

        public init(
            account: OpenBanking.BankAccount,
            action: OpenBanking.Data.Action
        ) {
            self.account = account
            self.action = action
        }

        public enum Action: Hashable {
            case link(institution: OpenBanking.Institution)
            case deposit(amountMinor: String, product: String)
            case confirm(order: OpenBanking.Order)
        }

        public let account: OpenBanking.BankAccount
        public let action: Action
    }

    public enum Output: Hashable {
        case linked(OpenBanking.BankAccount, institution: OpenBanking.Institution)
        case deposited(OpenBanking.Payment.Details)
        case confirmed(OpenBanking.Order)
    }

    public enum Action: FailureAction, Hashable {
        case waitingForConsent(Output)
        case success(Output)
        case fail(OpenBanking.Error)

        public static func failure(_ error: OpenBanking.Error) -> OpenBanking.Action {
            .fail(error)
        }
    }

    public let banking: OpenBankingClientAPI
    public let app: AppProtocol

    private var scheduler: AnySchedulerOf<DispatchQueue> { banking.scheduler }

    public init(app: AppProtocol, banking: OpenBankingClientAPI) {
        self.banking = banking
        self.app = app
    }

    public var authorisationURLPublisher: AnyPublisher<URL, Never> {
        app.on(blockchain.ux.payment.method.open.banking.authorisation.url)
            .compactMap { event in event.context[event.reference] as? URL }
            .eraseToAnyPublisher()
    }

    public var isAuthorising: Bool {
        app.state.contains(blockchain.ux.payment.method.open.banking.authorisation.url)
    }

    public func createBankAccount() -> AnyPublisher<OpenBanking.BankAccount, Error> {
        banking.createBankAccount()
    }

    public func reset() {
        app.state.transaction { state in
            state.clear(blockchain.ux.payment.method.open.banking.callback.path)
            state.clear(blockchain.ux.payment.method.open.banking.is.authorised)
            state.clear(blockchain.ux.payment.method.open.banking.authorisation.url)
            state.clear(blockchain.ux.payment.method.open.banking.error.code)
            state.clear(blockchain.ux.payment.method.open.banking.consent.error)
            state.clear(blockchain.ux.payment.method.open.banking.consent.token)
        }
    }

    public func start(_ data: Data) -> AnyPublisher<Action, Never> {

        let publisher = actionPublisher(data).share()

        switch data.action {
        case .link(let institution):
            return publisher
                .flatMap { [waitForAccountLinking] action -> AnyPublisher<Action, Never> in
                    switch action {
                    case .waitingForConsent:
                        waitForAccountLinking(data.account, institution, action)
                    default:
                        Just(action).eraseToAnyPublisher()
                    }
                }
                .eraseToAnyPublisher()
        default:
            return publisher
                .flatMap { [waitForConsent] action -> AnyPublisher<Action, Never> in
                    switch action {
                    case .waitingForConsent(let consent):
                        waitForConsent(consent, action)
                    default:
                        Just(action).eraseToAnyPublisher()
                    }
                }
                .eraseToAnyPublisher()
        }
    }

    private func actionPublisher(_ data: Data) -> AnyPublisher<Action, Never> {
        switch data.action {
        case .link(let institution):
            link(institution, data: data)
        case .deposit(let amountMinor, let product):
            deposit(amountMinor: amountMinor, product: product, data: data)
        case .confirm(let order):
            confirm(order: order, data: data)
        }
    }

    private func link(
        _ institution: OpenBanking.Institution,
        data: Data
    ) -> AnyPublisher<Action, Never> {
        banking.activate(bankAccount: data.account, with: institution.id)
            .flatMap { [banking] output -> AnyPublisher<Action, Never> in
                banking.poll(account: output, until: \.hasAuthorizationURL)
                    .flatMap { account -> AnyPublisher<OpenBanking.BankAccount, OpenBanking.Error> in
                        if account.error.isNotNil, let error = account.ux {
                            Fail(error: .ux(error)).eraseToAnyPublisher()
                        } else if let error = account.error {
                            Fail(error: error).eraseToAnyPublisher()
                        } else {
                            Just(account).setFailureType(to: OpenBanking.Error.self).eraseToAnyPublisher()
                        }
                    }
                    .map(Action.waitingForConsent(.linked(output, institution: institution)))
                    .catch(Action.failure)
                    .eraseToAnyPublisher()
            }
            .catch(Action.failure)
            .eraseToAnyPublisher()
    }

    private func deposit(amountMinor: String, product: String, data: Data) -> AnyPublisher<Action, Never> {
        banking.deposit(amountMinor: amountMinor, product: product, from: data.account)
            .flatMap { [banking] payment in
                banking.poll(payment: payment)
                    .flatMap { payment -> AnyPublisher<OpenBanking.Payment.Details, OpenBanking.Error> in
                        if payment.error.isNotNil, let error = payment.ux {
                            Fail(error: .ux(error)).eraseToAnyPublisher()
                        } else if let error = payment.error {
                            Fail(error: error).eraseToAnyPublisher()
                        } else {
                            Just(payment).setFailureType(to: OpenBanking.Error.self).eraseToAnyPublisher()
                        }
                    }
                    .map { paymentDetails in
                        Action.waitingForConsent(.deposited(paymentDetails))
                    }
                    .catch(Action.failure)
            }
            .catch(Action.failure)
            .eraseToAnyPublisher()
    }

    private func confirm(
        order: OpenBanking.Order,
        data: Data
    ) -> AnyPublisher<Action, Never> {
        func isFinal(_ order: OpenBanking.Order) -> Bool {
            [.finished, .canceled, .expired, .failed, .depositMatched].contains(order.state)
        }
        func poll(_ order: OpenBanking.Order) -> AnyPublisher<Action, Never> {
            banking.poll(
                order: order,
                until: isFinal
            )
            .flatMap { order -> AnyPublisher<OpenBanking.Order, OpenBanking.Error> in
                if order.paymentError.isNotNil, let error = order.ux {
                    .failure(.ux(error))
                } else if let error = order.paymentError {
                    .failure(error)
                } else {
                    Just(order).setFailureType(to: OpenBanking.Error.self).eraseToAnyPublisher()
                }
            }
            .catch { error -> AnyPublisher<OpenBanking.Order, OpenBanking.Error> in
                switch error {
                case .timeout:
                    .just(order)
                default:
                    .failure(error)
                }
            }
            .map(Action.waitingForConsent(.confirmed(order)))
            .catch(Action.failure)
            .eraseToAnyPublisher()
        }

        return banking.get(order: order)
            .flatMap { [banking] order -> AnyPublisher<Action, Never> in
                if let error = order.paymentError {
                    .just(Action.failure(error))
                } else if order.state == .pendingConfirmation {
                    banking.confirm(order: order.id, using: order.paymentMethodId)
                        .flatMap(poll)
                        .catch(Action.failure)
                        .eraseToAnyPublisher()
                } else {
                    poll(order)
                }
            }
            .catch(Action.failure)
            .eraseToAnyPublisher()
    }

    private lazy var consentErrorPublisher = app
        .publisher(for: blockchain.ux.payment.method.open.banking.consent.error, as: OpenBanking.Error.self)
        .map(\.result)
        .mapError(OpenBanking.Error.init)
        .map(Action.failure)
        .catch(Action.failure)
        .eraseToAnyPublisher()

    private func waitForAccountLinking(
        account: OpenBanking.BankAccount,
        institution: OpenBanking.Institution,
        action: Action
    ) -> AnyPublisher<Action, Never> {
        app.publisher(for: blockchain.ux.payment.method.open.banking.is.authorised, as: Bool.self)
            .map(\.result)
            .ignoreResultFailure()
            .flatMap { [banking] authorised -> AnyPublisher<(Bool, OpenBanking.BankAccount), OpenBanking.Error> in
                banking.poll(account: account, until: \.isNotPending)
                    .map { (authorised, $0) }
                    .eraseToAnyPublisher()
            }
            .flatMap { [consentErrorPublisher] authorised, account -> AnyPublisher<Action, Never> in
                if authorised {
                    if let error = account.error {
                        Just(Action.failure(error))
                            .eraseToAnyPublisher()
                    } else {
                        Just(Action.success(.linked(account, institution: institution)))
                            .eraseToAnyPublisher()
                    }
                } else {
                    consentErrorPublisher.first().eraseToAnyPublisher()
                }
            }
            .catch(Action.failure)
            .merge(with: Just(action))
            .eraseToAnyPublisher()
    }

    private func waitForConsent(output consent: Output, action: Action) -> AnyPublisher<Action, Never> {
        app.publisher(for: blockchain.ux.payment.method.open.banking.is.authorised, as: Bool.self)
            .map(\.result)
            .ignoreResultFailure()
            .flatMap { [consentErrorPublisher] authorised -> AnyPublisher<Action, Never> in
                if authorised {
                    Just(Action.success(consent))
                        .eraseToAnyPublisher()
                } else {
                    consentErrorPublisher
                }
            }
            .catch(Action.failure)
            .merge(with: Just(action))
            .eraseToAnyPublisher()
    }
}

extension OpenBanking.BankAccount {

    var isNotPending: Bool {
        state != .pending
    }

    var hasAuthorizationURL: Bool {
        attributes.authorisationUrl != nil
    }
}
