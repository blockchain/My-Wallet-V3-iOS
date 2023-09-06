// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import PlatformKit
import ToolKit

public final class KYCSSNRepository {

    private let app: AppProtocol
    private let client: KYCSSNClientAPI

    private let cache: CachedValueNew<CodableVoid, KYC.SSN, UX.Error>

    public init(app: AppProtocol, client: KYCSSNClientAPI) {
        self.app = app
        self.client = client
        self.cache = .init(
            cache: InMemoryCache(configuration: .onUserStateChanged(), refreshControl: PerpetualCacheRefreshControl()).eraseToAnyCache(),
            fetch: { [client] _ in client.checkSSN().mapError(UX.Error.init(nabu:)).eraseToAnyPublisher() }
        )
    }

    public func checkSSN() -> AnyPublisher<KYC.SSN, UX.Error> {
        cache.get(key: CodableVoid())
    }

    public func submitSSN(_ ssn: String) -> AnyPublisher<Void, UX.Error> {
        client.submitSSN(ssn).mapError(UX.Error.init(nabu:)).eraseToAnyPublisher()
    }

    public func register() async throws {
        try await app.register(
            napi: blockchain.api.nabu.gateway.onboarding,
            domain: blockchain.api.nabu.gateway.onboarding.SSN,
            repository: { [app, cache] _ in
                app.publisher(for: blockchain.ux.kyc.SSN.is.enabled, as: Bool.self)
                    .replaceError(with: false)
                    .flatMap { isEnabled -> AnyPublisher<AnyJSON, Never> in
                        if isEnabled {
                            return cache.stream(key: CodableVoid()).map { ssn -> AnyJSON in
                                switch ssn {
                                case let .success(ssn):
                                    var json = L_blockchain_api_nabu_gateway_onboarding_SSN.JSON()
                                    json.is.mandatory = ssn.requirements.isMandatory
                                    if let message = ssn.verification?.errorMessage {
                                        json.verification.message = message
                                    }
                                    json.regex.validation = ssn.requirements.validationRegex
                                    if let verification = ssn.verification {
                                        json.state = blockchain.api.nabu.gateway.onboarding.SSN.state[][verification.state.value.lowercased()]
                                    }
                                    return json.toJSON()
                                case let .failure(error):
                                    return AnyJSON(error)
                                }
                            }
                            .eraseToAnyPublisher()
                        } else {
                            return .just(.empty)
                        }
                    }
                    .eraseToAnyPublisher()
            }
        )
    }
}

import Dependencies
import DIKit

public struct KYCSSNRepositoryDependencyKey: DependencyKey {
    public static var liveValue: KYCSSNRepository = DIKit.resolve()
    public static let previewValue: KYCSSNRepository = KYCSSNRepository(app: App.preview, client: PreviewKYCSSNClient())
    #if DEBUG
    public static let testValue: KYCSSNRepository = KYCSSNRepository(app: App.test, client: PreviewKYCSSNClient())
    #endif
}

extension DependencyValues {

    public var KYCSSNRepository: KYCSSNRepository {
        get { self[KYCSSNRepositoryDependencyKey.self] }
        set { self[KYCSSNRepositoryDependencyKey.self] = newValue }
    }
}

public class PreviewKYCSSNClient: KYCSSNClientAPI {

    private let then: (
        submit: Result<Void, Nabu.Error>,
        check: (Int) -> Result<KYC.SSN, Nabu.Error>
    )

    public init(
        submit: Result<Void, Nabu.Error> = .failure(.unknown),
        check: @escaping (Int) -> Result<KYC.SSN, Nabu.Error> = { _ in .failure(.unknown) }
    ) {
        self.then = (submit, check)
    }

    private var count: Int = 0

    public func checkSSN() -> AnyPublisher<KYC.SSN, Nabu.Error> {
        defer { count += 1 }
        return then.check(count).publisher.eraseToAnyPublisher()
    }

    public func submitSSN(_ ssn: String) -> AnyPublisher<Void, Nabu.Error> {
        then.submit.publisher.eraseToAnyPublisher()
    }
}
