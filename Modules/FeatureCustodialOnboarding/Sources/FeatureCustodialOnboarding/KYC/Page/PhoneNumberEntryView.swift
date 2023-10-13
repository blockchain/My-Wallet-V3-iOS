import BlockchainUI
import SwiftUI

public struct PhoneNumberEntryView: View {

    @BlockchainApp var app

    @State private var phoneNumber: String = ""
    @State private var pattern: String = #"\d{10}"#

    var completion: () -> Void

    @StateObject var object = PhoneNumberEntryStateObject()

    var isValid: Bool {
        !object.state.isFailure && NSPredicate(format: "SELF MATCHES %@", pattern)
            .evaluate(with: phoneNumber)
    }

    public var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 16.pt) {
                Text(L10n.phoneNumber)
                    .typography(.title3)
                    .foregroundColor(.semantic.title)
                Text(L10n.weNeedToVerify)
                    .typography(.body1)
                    .foregroundColor(.semantic.body)
                PhoneNumberView(phoneNumber: $phoneNumber)
                    .padding(.top, 16.pt)
                if case let .failure(error) = object.state {
                    Text(error.message)
                        .typography(.caption1)
                        .foregroundColor(.semantic.error)
                }
            }
            .multilineTextAlignment(.leading)
            .frame(maxHeight: .infinity, alignment: .top)
            VStack {
                PrimaryButton(
                    title: L10n.next,
                    isLoading: object.isLoading,
                    action: {
                        switch await object.submit(phoneNumber: phoneNumber) {
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
        .onAppear {
            $app.post(event: blockchain.ux.kyc.prove.phone.number)
        }
    }
}

struct PhoneNumberView: View {

    let numberOfCharacters = 10

    @Binding var phoneNumber: String

    var isValid: Bool {
        phoneNumber.count == numberOfCharacters
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12.pt) {
            Text("🇺🇸")
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)

            Text("+1")
                .typography(.paragraph2)
                .foregroundColor(.semantic.title)

            Divider()
                .frame(height: 24)

            TextField(L10n.phoneNumberPlaceholder, text: binding)
        }
        .padding(12.pt)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isValid ? Color.semantic.success : .semantic.muted, lineWidth: 1)
                .background(Color.white)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    var binding: Binding<String> {
        Binding<String>(
            get: {
                var temporary = ""
                let characters = Array(phoneNumber)
                for (i, character) in characters.enumerated() {
                    switch i {
                    case 0: temporary.append("(" + String(character))
                    case 2: temporary.append(String(character) + ") ")
                    case 5: temporary.append(String(character) + "-")
                    case _: temporary.append(character)
                    }
                }
                return temporary
            },
            set: { newValue in
                phoneNumber = newValue.filter(\.isNumber).string
            }
        )
    }
}

@MainActor class PhoneNumberEntryStateObject: ObservableObject {

    @Published var state: AsyncState<Void, UX.Error> = .idle
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.KYCOnboardingService) var KYCOnboardingService

    var isLoading: Bool {
        state != .idle
    }

    @discardableResult
    func submit(phoneNumber: String) async -> AsyncState<Void, UX.Error> {
        state = .loading
        do {
            try await KYCOnboardingService.requestInstantLink(mobileNumber: phoneNumber)
            state = .success
        } catch {
            state = .failure(UX.Error(error: error))
        }
        return state
    }
}

struct PhoneNumberEntryView_Preview: PreviewProvider {
    static var previews: some View {
        PhoneNumberEntryView(completion: { print(#fileID) })
    }
}
