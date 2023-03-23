// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors
import FeatureFormDomain
import NetworkKit

public struct SimplifiedDueDiligenceResponse: Codable, Equatable {
    public let eligible: Bool
    public let tier: Int
}

// swiftlint:disable:next type_name
public struct SimplifiedDueDiligenceVerificationResponse: Codable, Equatable {
    let verified: Bool
    let taskComplete: Bool
}

public protocol KYCClientAPI: AnyObject {

    func tiers() -> AnyPublisher<KYC.UserTiers, NabuNetworkError>

    func supportedDocuments(
        for country: String
    ) -> AnyPublisher<KYCSupportedDocumentsResponse, NabuNetworkError>

    func user() -> AnyPublisher<NabuUser, NabuNetworkError>

    func listOfStates(
        in country: String
    ) -> AnyPublisher<[KYCState], NabuNetworkError>

    func setInitialResidentialInfo(
        country: String,
        state: String?
    ) -> AnyPublisher<Void, NabuNetworkError>

    func setTradingCurrency(
        _ currency: String
    ) -> AnyPublisher<Void, Nabu.Error>

    func selectCountry(
        country: String,
        state: String?,
        notifyWhenAvailable: Bool,
        jwtToken: String
    ) -> AnyPublisher<Void, NabuNetworkError>

    func updatePersonalDetails(
        firstName: String?,
        lastName: String?,
        birthday: Date?
    ) -> AnyPublisher<Void, NabuNetworkError>

    func updateAddress(
        userAddress: UserAddress
    ) -> AnyPublisher<Void, NabuNetworkError>

    func credentialsForVeriff() -> AnyPublisher<VeriffCredentials, NabuNetworkError>

    func submitToVeriffForVerification(
        applicantId: String
    ) -> AnyPublisher<Void, NabuNetworkError>

    func fetchUser() -> AnyPublisher<NabuUser, NabuNetworkError>

    func fetchLimitsOverview() -> AnyPublisher<KYCLimitsOverviewResponse, NabuNetworkError>

    func fetchExtraKYCQuestions(context: String) -> AnyPublisher<Form, NabuNetworkError>

    func submitExtraKYCQuestions(_ form: Form) -> AnyPublisher<Void, NabuNetworkError>
}

final class KYCClient: KYCClientAPI {

    // MARK: - Types

    private enum Path {

        // GET

        static let tiers = ["kyc", "tiers"]
        static let credentials = ["kyc", "credentials"]
        static let credentiasForVeriff = ["kyc", "credentials", "veriff"]
        static let currentUser = ["users", "current"]
        static let tierTradingLimitsOverview = ["limits", "overview"]
        static let accountUsage = ["kyc", "extra-questions"]

        static func supportedDocuments(for country: String) -> [String] {
            ["kyc", "supported-documents", country]
        }

        static func listOfStates(in country: String) -> [String] {
            ["countries", country, "states"]
        }

        // POST

        static let initialAddress = ["users", "current", "address", "initial"]
        static let country = ["users", "current", "country"]
        static let verifications = ["verifications"]
        static let submitVerification = ["kyc", "verifications"]

        // PUT

        static let updateAddress = ["users", "current", "address"]
        static let updateUserDetails = ["users", "current"]
    }

    // MARK: - Properties

    private let requestBuilder: RequestBuilder
    private let networkAdapter: NetworkAdapterAPI

    // MARK: - Setup

    init(
        networkAdapter: NetworkAdapterAPI = resolve(tag: DIKitContext.retail),
        requestBuilder: RequestBuilder = resolve(tag: DIKitContext.retail)
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    func tiers() -> AnyPublisher<KYC.UserTiers, NabuNetworkError> {
        let request = requestBuilder.get(
            path: Path.tiers,
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    func supportedDocuments(
        for country: String
    ) -> AnyPublisher<KYCSupportedDocumentsResponse, NabuNetworkError> {
        let request = requestBuilder.get(
            path: Path.supportedDocuments(for: country),
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    func credentialsForVeriff() -> AnyPublisher<VeriffCredentials, NabuNetworkError> {
        let request = requestBuilder.get(
            path: Path.credentiasForVeriff,
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    func user() -> AnyPublisher<NabuUser, NabuNetworkError> {
        fetchUser()
    }

    func listOfStates(
        in country: String
    ) -> AnyPublisher<[KYCState], NabuNetworkError> {
        let request = requestBuilder.get(
            path: Path.listOfStates(in: country)
        )!
        return networkAdapter
            .perform(request: request)
            .map { (states: [KYCState]) in
                states.sorted { $0.name.uppercased() < $1.name.uppercased() }
            }
            .eraseToAnyPublisher()
    }

    func submitToVeriffForVerification(
        applicantId: String
    ) -> AnyPublisher<Void, NabuNetworkError> {
        struct Payload: Encodable {

            private enum CodingKeys: String, CodingKey {
                case applicantId
                case clientType = "X-CLIENT-TYPE"
            }

            let applicantId: String
            let clientType: String

            init(applicantId: String) {
                self.applicantId = applicantId
                self.clientType = HttpHeaderValue.clientTypeApp
            }
        }

        let payload = Payload(applicantId: applicantId)

        let request = requestBuilder.post(
            path: Path.submitVerification,
            body: try? payload.encode(),
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    func setInitialResidentialInfo(
        country: String,
        state: String?
    ) -> AnyPublisher<Void, NabuNetworkError> {
        struct Payload: Encodable {
            let country: String
            let state: String?
        }

        func normalizedState() -> String? {
            guard let state else {
                return nil
            }
            return "\(country)-\(state)".uppercased()
        }

        let payload = Payload(
            country: country.uppercased(),
            state: normalizedState()
        )
        let request = requestBuilder.put(
            path: Path.initialAddress,
            body: try? payload.encode(),
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    func setTradingCurrency(_ currency: String) -> AnyPublisher<Void, Nabu.Error> {
        struct Payload: Codable { let fiatTradingCurrency: String }
        let request = requestBuilder.put(
            path: ["users", "current", "currency"],
            body: try? Payload(fiatTradingCurrency: currency).encode(),
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    func selectCountry(
        country: String,
        state: String?,
        notifyWhenAvailable: Bool,
        jwtToken: String
    ) -> AnyPublisher<Void, NabuNetworkError> {
        struct Payload: Encodable {
            let jwt: String
            let countryCode: String
            let state: String?
            let notifyWhenAvailable: String

            init(jwt: String, country: String, state: String?, notifyWhenAvailable: Bool) {
                self.jwt = jwt
                self.countryCode = country
                self.state = state
                self.notifyWhenAvailable = "\(notifyWhenAvailable)"
            }
        }

        let payload = Payload(
            jwt: jwtToken,
            country: country,
            state: state,
            notifyWhenAvailable: notifyWhenAvailable
        )

        let request = requestBuilder.post(
            path: Path.country,
            body: try? payload.encode(),
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    func updatePersonalDetails(
        firstName: String?,
        lastName: String?,
        birthday: Date?
    ) -> AnyPublisher<Void, NabuNetworkError> {
        let payload = KYCUpdatePersonalDetailsRequest(
            firstName: firstName,
            lastName: lastName,
            birthday: birthday
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(DateFormatter.birthday)

        let request = requestBuilder.put(
            path: Path.updateUserDetails,
            body: try? encoder.encode(payload),
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    func updateAddress(
        userAddress: UserAddress
    ) -> AnyPublisher<Void, NabuNetworkError> {
        let payload = KYCUpdateAddressRequest(address: userAddress)
        let request = requestBuilder.put(
            path: Path.updateAddress,
            body: try? payload.encode(),
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    // MARK: Combine Interface

    func fetchUser() -> AnyPublisher<NabuUser, NabuNetworkError> {
        let request = requestBuilder.get(
            path: Path.currentUser,
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    func fetchLimitsOverview() -> AnyPublisher<KYCLimitsOverviewResponse, NabuNetworkError> {
        let request = requestBuilder.get(
            path: Path.tierTradingLimitsOverview,
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    func fetchExtraKYCQuestions(context: String) -> AnyPublisher<Form, Nabu.Error> {
        let request = requestBuilder.get(
            path: Path.accountUsage,
            parameters: [URLQueryItem(name: "context", value: context)],
            authenticated: true
        )!
        return networkAdapter.perform(request: request, responseType: Form.self)
            .eraseToAnyPublisher()
    }

    func submitExtraKYCQuestions(_ form: Form) -> AnyPublisher<Void, NabuNetworkError> {
        let request = requestBuilder.put(
            path: Path.accountUsage,
            body: try? form.encode(),
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }
}
