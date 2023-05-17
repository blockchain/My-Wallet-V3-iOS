// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import Localization
import PlatformKit
import SwiftUI

private typealias LocalizedStrings = LocalizationConstants.NewKYC.Steps.IdentityVerification

struct IdentityVerificationView: View {

    let store: Store<IdentityVerification.State, IdentityVerification.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    headerIcon
                        .padding(.top, 30)
                    Text(LocalizedStrings.WeNeedToConfirmYourIdentity.title)
                        .typography(.title3)
                        .foregroundColor(.semantic.title)
                        .padding(.top, 5)
                        .accessibility(identifier: AccessibilityIdentifier.headerText)
                    Text(LocalizedStrings.WeNeedToConfirmYourIdentity.description)
                        .typography(.paragraph1)
                        .foregroundColor(.semantic.body)
                        .padding(.bottom, 5)
                        .accessibility(identifier: AccessibilityIdentifier.subheaderText)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, Spacing.padding3)

                documentsTypesItemsListContent
                    .padding(.horizontal, Spacing.textSpacing)

                Spacer()

                PrimaryButton(
                    title: LocalizedStrings.StartVerificationButton.title,
                    action: {
                        viewStore.send(.startVerification)
                    }
                )
                .disabled(viewStore.isLoading)
                .padding([.leading, .trailing, .bottom], 24)
                .accessibility(identifier: AccessibilityIdentifier.startVerificationButton)
            }
            .onAppear {
                viewStore.send(.onViewAppear)
            }
        }
    }

    private var documentsTypesItemsListContent: some View {
        GeometryReader { geometry in
            ScrollView {
                documentsTypesItemsList
            }
            .frame(width: geometry.size.width)
            .frame(minHeight: geometry.size.height)
        }
    }

    private var documentsTypesItemsList: some View {
        WithViewStore(store) { viewStore in
            if viewStore.isLoading {
                HStack {
                    Spacer()
                    VStack {
                        Spacer(minLength: Spacing.padding3)
                        ProgressView()
                    }
                    Spacer()
                }
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(viewStore.documentTypes, id: \.self) { title in
                        PrimaryDivider()
                        createItemRow(type: title)
                            .padding([.leading, .trailing], 4)
                    }
                }
            }
        }
    }

    private func createItemRow(type: KYCDocumentType) -> some View {
        PrimaryRow(
            title: .init(text: type.description),
            highlight: false,
            leading: {
                EmptyView()
            },
            trailing: {
                EmptyView()
            }
        )
        .accessibility(identifier: type.accessibilityIdentifier)
    }

    var headerIcon: some View {
        Icon.user
            .color(.semantic.primary)
            .frame(width: 26.pt, height: 26.pt)
    }
}

struct IdentityVerificationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PrimaryNavigationView {
                IdentityVerificationView(store: .emptyPreview)
            }
            .navigationBarTitleDisplayMode(.inline)

            PrimaryNavigationView {
                IdentityVerificationView(store: .filledPreview)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

extension KYCDocumentType {
    fileprivate var description: String {
        switch self {
        case .passport:
            return LocalizedStrings.DocumentTypes.passport
        case .nationalIdentityCard:
            return LocalizedStrings.DocumentTypes.nationalIdentityCard
        case .residencePermit:
            return LocalizedStrings.DocumentTypes.residencePermit
        case .driversLicense:
            return LocalizedStrings.DocumentTypes.driversLicense
        }
    }
}

enum AccessibilityIdentifier {
    static let headerText = "KYCVerifyIdentityScreen.headerText"
    static let subheaderText = "KYCVerifyIdentityScreen.subheaderText"
    static let passportText = "KYCVerifyIdentityScreen.passportText"
    static let nationalIDCardText = "KYCVerifyIdentityScreen.nationalIDCardText"
    static let residenceCardText = "KYCVerifyIdentityScreen.residenceCardText"
    static let driversLicenseText = "KYCVerifyIdentityScreen.driversLicenseText"
    static let startVerificationButton = "KYCVerifyIdentityScreen.startVerificationButton"
}

extension KYCDocumentType {
    fileprivate var accessibilityIdentifier: String {
        switch self {
        case .passport:
            return AccessibilityIdentifier.passportText
        case .nationalIdentityCard:
            return AccessibilityIdentifier.nationalIDCardText
        case .residencePermit:
            return AccessibilityIdentifier.residenceCardText
        case .driversLicense:
            return AccessibilityIdentifier.driversLicenseText
        }
    }
}
