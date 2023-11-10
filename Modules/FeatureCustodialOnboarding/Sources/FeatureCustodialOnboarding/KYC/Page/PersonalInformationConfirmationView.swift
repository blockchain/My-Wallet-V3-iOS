import BlockchainUI
import FeatureAddressSearchDomain
import FeatureAddressSearchUI
import SwiftUI

public struct PersonalInformationConfirmationView: View {

    @BlockchainApp var app

    let personalInformation: PersonalInformation
    let addressSearchBuilder: AddressSearchBuilder

    @State private var edit: PersonalInformation {
        didSet { selectAddress = false }
    }

    @State private var searchAddressPresented = false

    var completion: () -> Void

    @StateObject var object = PersonalInformationConfirmationObject()

    init(
        personalInformation: PersonalInformation,
        addressSearchBuilder: AddressSearchBuilder = AddressSearchBuilder(),
        completion: @escaping () -> Void
    ) {
        self.personalInformation = personalInformation
        self.addressSearchBuilder = addressSearchBuilder
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
        .sheet(isPresented: $searchAddressPresented) {
            addressSearchBuilder.searchAddressView(
                prefill: edit.addresses?.first?.toSearchAddress
            ) { result in
                switch result {
                case .saved(let address):
                    edit.address = address.toAddress
                case .abandoned:
                    break
                }
                searchAddressPresented = false
            }
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
                            Text(edit.address?.line1 ?? "Select Address")
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
                Button(
                    L10n.changeAddress,
                    action: {
                        searchAddressPresented = true
                    }
                )
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
                                    if let first = address.line1 {
                                        Text(first)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .typography(.paragraph2)
                                            .foregroundColor(.semantic.title)
                                    }
                                    if let second = address.line2 {
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
}

extension Address {
    var toSearchAddress: FeatureAddressSearchDomain.Address {
        FeatureAddressSearchDomain.Address(state: state, country: country)
    }
}

extension FeatureAddressSearchDomain.Address {
    var toAddress: Address? {
        Address(
            line1: line1,
            line2: line2,
            city: city,
            state: state,
            country: country,
            postalCode: postCode
        )
    }
}

#if DEBUG

struct PersonalInformationConfirmationView_Preview: PreviewProvider {
    static var previews: some View {
        PersonalInformationConfirmationView(
            personalInformation: PersonalInformation(
                firstName: "Oliver",
                lastName: "Atkinson",
                addresses: [
                    Address(line1: "1 Coltsfoot Court", line2: "Harrogate, Yorkshire, HG3 2WW", city: "Harrogate", country: "FR", postalCode: "HG3 2WW"),
                    Address(line1: "2 Coltsfoot Court", line2: "Harrogate, Yorkshire, HG3 2WW", city: "Harrogate", country: "FR", postalCode: "HG3 2WW"),
                    Address(line1: "3 Coltsfoot Court", line2: "Harrogate, Yorkshire, HG3 2WW", city: "Harrogate", country: "FR", postalCode: "HG3 2WW"),
                    Address(line1: "4 Coltsfoot Court", line2: "Harrogate, Yorkshire, HG3 2WW", city: "Harrogate", country: "FR", postalCode: "HG3 2WW")
                ],
                ssn: "1234567890",
                dob: "04/03/1990"
            ), 
            addressSearchBuilder: AddressSearchBuilder(addressSearchService: NoOpAddressSearchService()),
            completion: {
                print(#fileID, #line)
            }
        )
    }
}

struct NoOpAddressSearchService: AddressSearchServiceAPI {

    static func sampleResult(
        addressId: String? = "addressId",
        text: String? = "line 1 line 2",
        type: String? = AddressSearchResult.AddressType.address.rawValue,
        highlight: String? = nil,
        description: String? = "London E14 6GF"
    ) -> AddressSearchResult {
        AddressSearchResult(
            addressId: addressId,
            text: text,
            type: type,
            highlight: highlight,
            description: description
        )
    }

    static func sampleDetails(
        addressId: String? = "addressId",
        line1: String? = "line 1",
        line2: String? = "line 2",
        line3: String? = nil,
        line4: String? = nil,
        line5: String? = nil,
        street: String? = "street 3",
        buildingNumber: String? = nil,
        city: String? = "London",
        postCode: String? = "E14 6GF",
        state: String? = nil,
        country: String? = "GB",
        label: String? = nil
    ) -> AddressDetailsSearchResult {
        AddressDetailsSearchResult(
            addressId: addressId,
            line1: line1,
            line2: line2,
            line3: line3,
            line4: line4,
            line5: line5,
            street: street,
            buildingNumber: buildingNumber,
            city: city,
            postCode: postCode,
            state: state,
            country: country,
            label: label
        )
    }

    func fetchAddresses(searchText: String, containerId: String?, countryCode: String, sateCode: String?) -> AnyPublisher<[FeatureAddressSearchDomain.AddressSearchResult], FeatureAddressSearchDomain.AddressSearchServiceError> {
        .just([Self.sampleResult()])
    }
    
    func fetchAddress(addressId: String) -> AnyPublisher<FeatureAddressSearchDomain.AddressDetailsSearchResult, FeatureAddressSearchDomain.AddressSearchServiceError> {
        .just(Self.sampleDetails())
    }
}

#endif
