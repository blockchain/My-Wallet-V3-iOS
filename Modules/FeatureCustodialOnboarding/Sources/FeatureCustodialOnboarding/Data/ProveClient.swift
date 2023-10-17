import Blockchain
import NetworkKit

public struct InstantLink: Codable, Hashable {
    public let status: Status; public struct Status: NewTypeString {
        public var value: String
        public init(_ value: String) { self.value = value }
    }
}

extension InstantLink.Status {
    public static let verified: Self = "VERIFIED"
    public static let rejected: Self = "REJECTED"
    public static let inProgress: Self = "IN_PROGRESS"
    public static let expired: Self = "EXPIRED"
}

public struct Challenge: Codable, Hashable {
    public var prefill: PersonalInformation
}

public struct PersonalInformation: Codable, Hashable {
    public var prefillId: String
    public var firstName, lastName: String
    public var addresses: [Address]?
    public var address: Address?
    public var emailAddresses: [String]?
    public var ssn, dob: String
}

public struct Address: Codable, Hashable {
    public var address, extendedAddress, city, region: String?
    public var postalCode: String?
}

public struct Ownership: Codable, Hashable {
    public let status: Status; public struct Status: NewTypeString {
        public var value: String
        public init(_ value: String) { self.value = value }
    }
}

extension Ownership.Status {
    public static let approved: Self = "VERIFIED"
    public static let rejected: Self = "REJECTED"
}

public class ProveClient {

    @Dependency(\.networkAdapter) var adapter
    @Dependency(\.requestBuilder) var requestBuilder

    public init() {}

    public func requestInstantLink(mobileNumber: String) async throws {
        try await adapter.perform(
            request: requestBuilder.post(
                path: "/onboarding/prove/possession/instant-link",
                body: [
                    "mobileNumber": OnboardingFlow.Slug.allCases
                ].json()
            )
            .or(throw: "Could not build request in \(#fileID).\(#function)".error())
        )
        .await()
    }

    public func requestInstantLinkResend() async throws {
        try await adapter.perform(
            request: requestBuilder.post(
                path: "/onboarding/prove/possession/instant-link/resend",
                body: [:].json()
            )
            .or(throw: "Could not build request in \(#fileID).\(#function)".error())
        )
        .await()
    }

    public func instantLink() async throws -> InstantLink {
        try await adapter.perform(
            request: requestBuilder.get(path: "/onboarding/prove/possession/instant-link/result")
                .or(throw: "Could not build request in \(#fileID).\(#function)".error())
        )
        .await()
    }

    public func challenge(dateOfBirth: String) async throws -> Challenge {
        try await adapter.perform(
            request: requestBuilder.post(
                path: "/onboarding/prove/ownership/pre-fill",
                body: [
                    "dob": dateOfBirth
                ].json()
            )
            .or(throw: "Could not build request in \(#fileID).\(#function)".error())
        )
        .await()
    }

    public func lookupPrefill(id: String) async throws -> PersonalInformation {
        try await adapter.perform(
            request: requestBuilder.get(
                path: "/onboarding/prove/ownership/pre-fill/\(id)"
            )
            .or(throw: "Could not build request in \(#fileID).\(#function)".error())
        )
        .await()
    }

    public func confirm(personalInformation: PersonalInformation) async throws -> Ownership {
        try await adapter.perform(
            request: requestBuilder.post(
                path: "/onboarding/prove/ownership/pre-fill",
                body: [
                    "prefillId": personalInformation.prefillId,
                    "action": "CONFIRM",
                    "prefillDataUpdated": personalInformation.json()
                ].json()
            )
            .or(throw: "Could not build request in \(#fileID).\(#function)".error())
        )
        .await()
    }

    public func reject(personalInformation: PersonalInformation) async throws -> Ownership {
        try await adapter.perform(
            request: requestBuilder.post(
                path: "/onboarding/prove/ownership/pre-fill",
                body: [
                    "prefillId": personalInformation.prefillId,
                    "action": "REJECT"
                ].json()
            )
            .or(throw: "Could not build request in \(#fileID).\(#function)".error())
        )
        .await()
    }
}