// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import Combine
import Errors
import FeatureFormDomain
import PlatformKit

public protocol KYCAccountUsageServiceAPI {

    func fetchExtraKYCQuestions(context: String) -> AnyPublisher<Form, Nabu.Error>
    func submitExtraKYCQuestions(_ form: Form) -> AnyPublisher<Void, Nabu.Error>
}

final class KYCAccountUsageService: KYCAccountUsageServiceAPI {

    private let app: AppProtocol
    private let apiClient: KYCClientAPI

    init(app: AppProtocol, apiClient: KYCClientAPI) {
        self.app = app
        self.apiClient = apiClient
    }

    func fetchExtraKYCQuestions(context: String) -> AnyPublisher<Form, Nabu.Error> {
        app.publisher(for: blockchain.ux.kyc.extra.questions.api.version, as: [String].self)
            .replaceError(with: [])
            .prefix(1)
            .flatMap { [apiClient] version -> AnyPublisher<Form, Nabu.Error> in
                apiClient.fetchExtraKYCQuestions(context: context, version: version)
                    .catch { error -> AnyPublisher<Form, Nabu.Error> in
                        if error.code.rawValue == 204 {
                            return Just(Form())
                                .setFailureType(to: Nabu.Error.self)
                                .eraseToAnyPublisher()
                        } else {
                            return Fail(outputType: Form.self, failure: error)
                                .eraseToAnyPublisher()
                        }
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func submitExtraKYCQuestions(_ form: Form) -> AnyPublisher<Void, Nabu.Error> {
        app.publisher(for: blockchain.ux.kyc.extra.questions.api.version, as: [String].self)
            .replaceError(with: [])
            .prefix(1)
            .flatMap { [apiClient] version -> AnyPublisher<Void, Nabu.Error> in
                apiClient.submitExtraKYCQuestions(form, version: version)
            }
            .eraseToAnyPublisher()
    }
}
