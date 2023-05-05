import BlockchainNamespace
import Combine
import Errors
import Foundation
import ToolKit

@MainActor
public class BINDWithdrawService: ObservableObject {

    @Published public private(set) var result: Result<BINDBeneficiary, UX.Error>?
    @Published public private(set) var isLoading: Bool = false

    private let repository: BINDWithdrawRepositoryProtocol

    public init(
        initialResult result: Result<BINDBeneficiary, UX.Error>? = nil,
        repository: BINDWithdrawRepositoryProtocol
    ) {
        self.result = result
        self.repository = repository
    }

    public func search(_ text: String) {
        guard text.isNotEmpty else {
            return result = nil
        }

        Task(priority: .userInitiated) {
            isLoading = true
            do {
                result = try await .success(repository.search(address: text).await())
            } catch {
                result = .failure(UX.Error(error: error))
            }
            isLoading = false
        }
    }

    public func link(_ beneficiary: BINDBeneficiary) async throws {
        isLoading = true
        try await repository.link(beneficiary: beneficiary.id).await()
        isLoading = false
    }
}
