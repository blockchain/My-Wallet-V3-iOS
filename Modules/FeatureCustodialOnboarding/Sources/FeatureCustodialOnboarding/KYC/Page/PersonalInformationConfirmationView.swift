import BlockchainUI
import SwiftUI

public struct PersonalInformationConfirmationView: View {

    @BlockchainApp var app

    let personalInformation: PersonalInformation
    @State private var edit: PersonalInformation {
        didSet { selectAddress = false }
    }

    var completion: () -> Void

    @StateObject var object = PersonalInformationConfirmationObject()

    init(personalInformation: PersonalInformation, completion: @escaping () -> Void) {
        self.personalInformation = personalInformation
        self.completion = completion
        _edit = .init(wrappedValue: personalInformation)
    }

    public var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 8.pt) {
                    Text(L10n.confirmYourDetails)
                        .typography(.title3)
                        .foregroundColor(.semantic.title)
                    Text(L10n.checkYourInformation)
                        .typography(.body1)
                        .foregroundColor(.semantic.body)
                    form()
                        .padding(.top, 16.pt)
                }
            }
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            VStack(alignment: .leading) {
                if let error = object.error {
                    Text(error.title)
                        .typography(.caption2)
                        .foregroundTexture(.semantic.title)
                    Text(error.message)
                        .lineLimit(nil)
                        .typography(.caption1)
                        .foregroundTexture(.semantic.error)
                }
                PrimaryButton(
                    title: L10n.confirm,
                    isLoading: object.isLoading,
                    action: {
                        switch await object.confirm(personalInformation: edit) {
                        case .success: completion()
                        default: break
                        }
                    }
                )
            }
            .multilineTextAlignment(.leading)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(Color.semantic.light)
        .onTapGesture {
            selected = nil
        }
        .onAppear {
            $app.post(event: blockchain.ux.kyc.prove.personal.information.confirmation)
        }
    }

    @State private var selected: PartialKeyPath<PersonalInformation>?
    @State private var isSSNDisplayed = false
    @State private var selectAddress = false

    @ViewBuilder func form() -> some View {
        VStack(spacing: 24.pt) {

            VStack(alignment: .leading, spacing: 2.pt) {
                Text(L10n.firstName)
                    .typography(.paragraph2)
                    .foregroundColor(.semantic.title)
                Input(
                    text: $edit.firstName,
                    isFirstResponder: $selected.equals(\.firstName),
                    defaultBorderColor: .semantic.background
                )
            }

            VStack(alignment: .leading, spacing: 2.pt) {
                Text(L10n.lastName)
                    .typography(.paragraph2)
                    .foregroundColor(.semantic.title)
                Input(
                    text: $edit.lastName,
                    isFirstResponder: $selected.equals(\.lastName),
                    defaultBorderColor: .semantic.background
                )
            }

            VStack(alignment: .leading, spacing: 2.pt) {
                Text(L10n.address)
                    .typography(.paragraph2)
                    .foregroundColor(.semantic.title)
                Button(
                    action: { selectAddress.toggle() },
                    label: {
                        HStack {
                            Text(edit.address?.address ?? "Select Address")
                                .typography(.body1)
                                .foregroundColor(.semantic.title)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Icon.chevronDown
                                .color(.semantic.muted)
                                .small()
                        }
                    }
                )
                .tint(Color.semantic.title)
                .padding(15.pt)
                .frame(maxWidth: .infinity, minHeight: 44, idealHeight: 44, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.semantic.background)
                )
                .popover(isPresented: $selectAddress) {
                    if #available(iOS 16.4, *) {
                        addresses()
                            .presentationCompactAdaptation(.popover)
                    } else {
                        addresses()
                    }
                }
                Button(L10n.changeAddress, action: {})
                    .typography(.caption1)
                    .foregroundColor(.semantic.primary)
                    .padding(4.pt)
            }

            VStack(spacing: .zero) {
                TableRow(
                    title: {
                        Text(L10n.dateOfBirth)
                            .typography(.caption1)
                            .foregroundColor(.semantic.body)
                    },
                    byline: {
                        Text(personalInformation.dob)
                            .typography(.paragraph2)
                            .foregroundColor(.semantic.title)
                    }
                )
                PrimaryDivider()
                TableRow(
                    title: {
                        Text(L10n.socialSecurityNumber)
                            .typography(.caption1)
                            .foregroundColor(.semantic.body)
                    },
                    byline: {
                        Group {
                            if isSSNDisplayed {
                                Text(personalInformation.ssn)
                            } else {
                                Text("•••••" + personalInformation.ssn.suffix(4))
                            }
                        }
                        .typography(.paragraph2)
                        .foregroundColor(.semantic.title)
                    },
                    trailing: {
                        if isSSNDisplayed {
                            Icon.visibilityOff.color(.semantic.muted).small()
                        } else {
                            Icon.visibilityOn.color(.semantic.muted).small()
                        }
                    }
                )
                .background(Color.semantic.background)
                .onTapGesture {
                    isSSNDisplayed.toggle()
                }
            }
            .background(Color.semantic.background)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .circular))
        }
    }

    @ViewBuilder func addresses() -> some View {
        if let addresses = edit.addresses {
            ScrollView {
                DividedVStack {
                    ForEach(addresses, id: \.self) { address in
                        Button(
                            action: { edit.address = address },
                            label: {
                                VStack(alignment: .leading, spacing: 0) {
                                    if let first = address.address {
                                        Text(first)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .typography(.paragraph2)
                                            .foregroundColor(.semantic.title)
                                    }
                                    if let second = address.extendedAddress {
                                        Text(second)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .typography(.caption1)
                                            .foregroundColor(.semantic.body)
                                    }
                                }
                                .frame(idealWidth: CGRect.screen.width, idealHeight: 48)
                                .padding(.horizontal)
                                .padding(.top, 16.pt)
                                .background(Color.semantic.background)
                            }
                        )
                    }
                }
                .padding(.top, 16.pt)
            }
            .background(Color.semantic.background)
        }
    }
}

@MainActor class PersonalInformationConfirmationObject: ObservableObject {

    @Published var state: AsyncState<Ownership, UX.Error> = .idle
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.KYCOnboardingService) var KYCOnboardingService

    var isLoading: Bool {
        switch state {
        case .idle, .failure: false
        case .loading, .success: true
        }
    }

    var error: UX.Error? {
        guard case .failure(let failure) = state else { return nil }
        return UX.Error(error: failure)
    }

    @discardableResult
    func confirm(personalInformation: PersonalInformation) async -> AsyncState<Ownership, UX.Error> {
        state = .loading
        do {
            state = try await .success(KYCOnboardingService.confirm(personalInformation))
        } catch {
            state = .failure(UX.Error(error: error))
        }
        return state
    }

    @discardableResult
    func reject(personalInformation: PersonalInformation) async -> AsyncState<Ownership, UX.Error> {
        state = .loading
        do {
            state = try await .success(KYCOnboardingService.reject(personalInformation))
        } catch {
            state = .failure(UX.Error(error: error))
        }
        return state
    }
}

struct PersonalInformationConfirmationView_Preview: PreviewProvider {
    static var previews: some View {
        PersonalInformationConfirmationView(
            personalInformation: PersonalInformation(
                prefillId: "1",
                firstName: "Oliver",
                lastName: "Atkinson",
                addresses: [
                    Address(address: "1 Coltsfoot Court", extendedAddress: "Harrogate, Yorkshire, HG3 2WW", city: "Harrogate", postalCode: "HG3 2WW"),
                    Address(address: "2 Coltsfoot Court", extendedAddress: "Harrogate, Yorkshire, HG3 2WW", city: "Harrogate", postalCode: "HG3 2WW"),
                    Address(address: "3 Coltsfoot Court", extendedAddress: "Harrogate, Yorkshire, HG3 2WW", city: "Harrogate", postalCode: "HG3 2WW"),
                    Address(address: "4 Coltsfoot Court", extendedAddress: "Harrogate, Yorkshire, HG3 2WW", city: "Harrogate", postalCode: "HG3 2WW")
                ],
                ssn: "1234567890",
                dob: "04/03/1990"
            ),
            completion: {
                print(#fileID, #line)
            }
        )
    }
}
