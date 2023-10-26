import BlockchainUI
import SwiftUI

public struct ChallengeView: View {

    @BlockchainApp var app

    let challenge: ChallengeType

    @State private var date: Date?
    @State private var ssnLast4: String = ""
    @State private var phoneNumber: String = ""
    @State private var pattern: String = #"\d{10}"#

    var toLegacyKYC: () -> Void
    var completion: () -> Void

    @StateObject var object = ChallengeStateObject()

    var isValid: Bool {
        !object.state.isFailure 
        && NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: phoneNumber)
        && (challenge == .dob && date.isNotNil || challenge == .ssn && ssnLast4.count == 4)
    }

    public var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 16.pt) {
                Text(L10n.findYourInfo)
                    .typography(.title3)
                    .foregroundColor(.semantic.title)
                Text(L10n.findYourInfoSubtitle)
                    .typography(.body1)
                    .foregroundColor(.semantic.body)
                    .padding(.bottom, Spacing.padding1)

                switch challenge {
                case .dob:
                    DateOfBirthView(date: $date)
                case .ssn:
                    SsnLast4View(ssnLast4: $ssnLast4)
                }

                PhoneNumberView(phoneNumber: $phoneNumber)
                    .padding(.top, 16.pt)
                if case .failure(let error) = object.state {
                    Text(error.message)
                        .typography(.caption1)
                        .foregroundColor(.semantic.error)
                }
            }
            .multilineTextAlignment(.leading)
            .frame(maxHeight: .infinity, alignment: .top)
            VStack(spacing: Spacing.padding2) {
                Text(LocalizedStringKey(L10n.findYourInfoFooter))
                    .typography(.caption1)
                    .foregroundColor(.semantic.body)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, Spacing.padding2)
                SmallMinimalButton(title: L10n.noUsNumber, action: toLegacyKYC)
                PrimaryButton(
                    title: L10n.next,
                    isLoading: object.isLoading,
                    action: {
                        switch await object.submit(
                            dob: date,
                            ssn: ssnLast4,
                            phoneNumber: phoneNumber
                        ) {
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

struct SsnLast4View: View {

    @Binding var ssnLast4: String
    @State private var isSSNDisplayed = false

    var body: some View {
        VStack(alignment: .leading) {
            Text(L10n.ssnLast4)
                .typography(.paragraph2)
                .foregroundColor(.semantic.title)
            HStack {
                if isSSNDisplayed {
                    TextField(L10n.ssnLast4Placeholder, text: $ssnLast4)
                } else {
                    SecureField(L10n.ssnLast4Placeholder, text: $ssnLast4)
                }
                Group {
                    if isSSNDisplayed {
                        Icon.visibilityOff.color(.semantic.muted).small()
                    } else {
                        Icon.visibilityOn.color(.semantic.muted).small()
                    }
                }
                .onTapGesture {
                    isSSNDisplayed.toggle()
                }
                .padding(.trailing, Spacing.padding1)
            }
            .padding(12.pt)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.clear, lineWidth: 1)
                    .background(Color.white)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            Text(L10n.ssnLast4Caption)
                .typography(.caption1)
                .foregroundColor(.semantic.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct DateOfBirthView: View {

    @Binding var date: Date?

    var body: some View {
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
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct PhoneNumberView: View {

    let numberOfCharacters = 10

    @Binding var phoneNumber: String

    var isValid: Bool {
        phoneNumber.count == numberOfCharacters
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(L10n.phoneNumber)
                .typography(.paragraph2)
                .foregroundColor(.semantic.title)
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
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isValid ? Color.semantic.success : .clear, lineWidth: 1)
                    .background(Color.white)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
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

@MainActor class ChallengeStateObject: ObservableObject {

    @Published var state: AsyncState<Void, UX.Error> = .idle
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.KYCOnboardingService) var KYCOnboardingService

    var isLoading: Bool {
        state != .idle
    }

    @discardableResult
    func submit(
        dob: Date?,
        ssn: String?,
        phoneNumber: String
    ) async -> AsyncState<Void, UX.Error> {
        state = .loading
        do {
            try await KYCOnboardingService.requestInstantLink(
                mobileNumber: phoneNumber,
                last4Ssn: ssn,
                dateOfBirth: dob
            )
            state = .success
        } catch {
            state = .failure(UX.Error(error: error))
        }
        return state
    }
}

struct ChallengeView_Preview: PreviewProvider {
    static var previews: some View {
        ChallengeView(challenge: .ssn, toLegacyKYC: {}, completion: { print(#fileID) })
    }
}
