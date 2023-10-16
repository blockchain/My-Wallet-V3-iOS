import Combine
import Errors
import Foundation
@testable import FeatureUserDeletionDomain

public final class MockUserDeletionRepositoryAPI: UserDeletionRepositoryAPI {

    public struct StubbedResults {
        public var deleteUser: AnyPublisher<Void, NetworkError> = .just(())
    }

    public var stubbedResults = StubbedResults()

    public func deleteUser(
        with reason: String?
    ) -> AnyPublisher<Void, NetworkError> {
        stubbedResults.deleteUser
    }
}
