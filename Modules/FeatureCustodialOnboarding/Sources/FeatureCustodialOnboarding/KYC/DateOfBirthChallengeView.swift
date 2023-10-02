import BlockchainUI
import SwiftUI

public struct DateOfBirthChallengeView: View {

    @State private var date: Date?
    @State private var minimumAgeRequirement = 18
    @StateObject private var object = DateOfBirthChallengeObject()

    var completion: () -> Void

    var isValid: Bool {
        guard let date else { return false }
        guard let year = Calendar.current.dateComponents([.year], from: date, to: Date()).year else { return false }
        return year >= minimumAgeRequirement
    }

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
                    isLoading: false,
                    action: {
                        guard let date else { return }
                        switch await object.submit(dateOfBirth: date) {
                        case .success: completion()
                        default: break
                        }
                    }
                )
                .disabled(!isValid)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.semantic.light)
    }
}

final class DateOfBirthChallengeObject: ObservableObject {

    @Published var state: AsyncState<Void, UX.Error> = .idle
    @Dependency(\.mainQueue) var mainQueue

    @discardableResult
    func submit(dateOfBirth: Date) async -> AsyncState<Void, UX.Error> {
        state = .loading
        do {
            try await mainQueue.sleep(for: .seconds(3))
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
