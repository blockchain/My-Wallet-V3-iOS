// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Extensions

public enum FeatureFlagError: Error {
    case decodingError(Error)
    case missingKeyRawValue
    case timeout
}

public protocol FeatureFetching: AnyObject {
    func fetch<Feature: Decodable>(
        for key: AppFeature,
        as type: Feature.Type
    ) -> AnyPublisher<Feature, FeatureFlagError>

    func isEnabled(
        _ feature: AppFeature
    ) -> AnyPublisher<Bool, Never>

    func object<Feature: Decodable>(
        for feature: AppFeature
    ) -> AnyPublisher<Feature?, FeatureFlagError>
}

extension FeatureFetching {

    public func isEnabled(
        _ feature: AppFeature
    ) -> AnyPublisher<Bool, Never> {
        fetch(for: feature, as: Bool.self)
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }

    public func object<Feature: Decodable>(
        for feature: AppFeature
    ) -> AnyPublisher<Feature?, FeatureFlagError> {
        fetch(for: feature, as: Feature?.self)
    }
}

public typealias FeatureFlagsServiceAPI = FeatureFetching
