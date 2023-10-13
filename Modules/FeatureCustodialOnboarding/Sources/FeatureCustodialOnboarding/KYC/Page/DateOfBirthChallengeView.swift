import BlockchainUI
import SwiftUI

public struct DateOfBirthChallengeView: View {

    @BlockchainApp var app

    @State private var date: Date?
    @StateObject private var object = DateOfBirthChallengeObject()

    var completion: () -> Void

    public var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 16.pt) {
                Text(L10n.verifyIn60)
                    .typography(.title3)
                    .foregroundColor(.semantic.title)
                Text(L10n.addYourDateOfBirth)
                    .typography(.body1)
                    .foregroundColor(.semantic.body)
                VStack(alignment: .leading) {
                    Text(L10n.dateOfBirth)
                        .typography(.paragraph2)
                        .foregroundColor(.semantic.title)
                    DatePickerInputView("MM/DD/YYYY", date: $date)
                        .background(
                            RoundedRectangle(cornerRadius: 16.0)
                                .fill(Color.white)
                        )
                        .frame(height: 44.pt)
                    if case let .failure(error) = object.state {
                        Text(error.message)
                            .typography(.caption1)
                            .foregroundColor(.semantic.error)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            VStack {
                PrimaryButton(
                    title: L10n.next,
                    isLoading: object.isLoading,
                    action: {
                        guard let date else { return }
                        switch await object.submit(dateOfBirth: date) {
                        case .success: completion()
                        default: break
                        }
                    }
                )
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.semantic.light)
        .onAppear {
            $app.post(event: blockchain.ux.kyc.prove.challenge.dob)
        }
    }
}

final class DateOfBirthChallengeObject: ObservableObject {

    @Published var state: AsyncState<Void, UX.Error> = .idle

    @Dependency(\.app) var app
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.KYCOnboardingService) var KYCOnboardingService

    var isLoading: Bool {
        switch state {
        case .idle, .failure: return false
        case .loading, .success: return true
        }
    }

    @discardableResult
    func submit(dateOfBirth: Date) async -> AsyncState<Void, UX.Error> {
        state = .loading
        do {
            let challenge = try await KYCOnboardingService.challenge(dateOfBirth: dateOfBirth)
            try await app.set(blockchain.ux.kyc.prove.challenge.prefill.id, to: challenge.prefill.prefillId)
            state = .success
        } catch {
            state = .failure(UX.Error(error: error))
        }
        return state
    }
}

struct DateOfBirthChallengeView_Preview: PreviewProvider {
    static var previews: some View {
        DateOfBirthChallengeView(completion: { print(#fileID) })
    }
}
