import BlockchainUI
import SwiftUI

struct PersonalInformation: Codable {

    struct Address: Hashable, Codable, Identifiable, CustomStringConvertible {
        var id: String { string }
        var string: String { lines.joined(separator: ", ") }
        var description: String { string }
        let lines: [String]
    }

    var firstName: String
    var lastName: String
    var address: Address
    var addresses: [Address]
    var dateOfBirth: Date
    var SSN: String
}

public struct PersonalInformationConfirmationView: View {

    let personalInformation: PersonalInformation
    @State private var edit: PersonalInformation {
        didSet { selectAddress = false }
    }

    init(personalInformation: PersonalInformation) {
        self.personalInformation = personalInformation
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
            VStack {
                PrimaryButton(
                    title: L10n.next,
                    isLoading: false,
                    action: {

                    }
                )
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(Color.semantic.light)
        .onTapGesture {
            selected = nil
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
                            Text(edit.address.string)
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
                Button(L10n.changeAddress, action: { })
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
                        Text(shortDateFormatter.string(from: personalInformation.dateOfBirth))
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
                                Text(personalInformation.SSN)
                            } else {
                                Text("•••••" + personalInformation.SSN.suffix(4))
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
        ScrollView {
            DividedVStack {
                ForEach(edit.addresses) { address in
                    Button(
                        action: {
                            edit.address = address
                        },
                        label: {
                            VStack(alignment: .leading, spacing: 0) {
                                if let first = address.lines.first {
                                    Text(first)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .typography(.paragraph2)
                                        .foregroundColor(.semantic.title)
                                }
                                if address.lines.dropFirst().count > 0 {
                                    Text(address.lines.dropFirst().joined(separator: ", "))
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

struct PersonalInformationConfirmationView_Preview: PreviewProvider {
    static var previews: some View {
        PersonalInformationConfirmationView(
            personalInformation: PersonalInformation(
                firstName: "Oliver",
                lastName: "Atkinson",
                address: PersonalInformation.Address(lines: [
                    "1 Coltsfoot Court",
                    "Austin",
                    "Texas",
                    "USA"
                ]),
                addresses: [
                    PersonalInformation.Address(lines: [
                        "1 Coltsfoot Court",
                        "Austin",
                        "Texas",
                        "USA"
                    ]),
                    PersonalInformation.Address(lines: [
                        "2 Coltsfoot Court",
                        "Austin",
                        "Texas",
                        "USA"
                    ]),
                    PersonalInformation.Address(lines: [
                        "3 Coltsfoot Court",
                        "Austin",
                        "Texas",
                        "USA"
                    ])
                    ,
                    PersonalInformation.Address(lines: [
                        "5 Coltsfoot Court",
                        "Austin",
                        "Texas",
                        "USA"
                    ]),
                    PersonalInformation.Address(lines: [
                        "6 Coltsfoot Court",
                        "Austin",
                        "Texas",
                        "USA"
                    ])
                ],
                dateOfBirth: .distantPast,
                SSN: "1234567890"
            )
        )
    }
}
