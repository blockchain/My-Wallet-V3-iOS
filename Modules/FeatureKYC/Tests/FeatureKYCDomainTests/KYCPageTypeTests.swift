// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureKYCDomain
@testable import PlatformKit
import XCTest

class KYCPageTypeTests: XCTestCase {

    /// A `KYC.UserTiers` where the user has been verified for tier1
    /// and their tier2 status is pending.
    private let pendingTier2Response = KYC.UserTiers(
        tiers: [
            KYC.UserTier(tier: .tier1, state: .verified),
            KYC.UserTier(tier: .tier2, state: .pending)
        ]
    )

    /// A `KYC.UserTiers` where the user has not been verified or
    /// applied to either tier1 or tier2.
    private let noTiersResponse = KYC.UserTiers(
        tiers: [
            KYC.UserTier(tier: .tier1, state: .none),
            KYC.UserTier(tier: .tier2, state: .none)
        ]
    )

    func testStartingPage() {
        XCTAssertEqual(
            KYCPageType.enterEmail,
            KYCPageType.startingPage(
                forUser: createNabuUser(),
                requiredTier: .tier2,
                tiersResponse: pendingTier2Response,
                isSDDEligible: false,
                isSDDVerified: false,
                hasQuestions: false,
                isNewProfile: false
            )
        )
        XCTAssertEqual(
            KYCPageType.country,
            KYCPageType.startingPage(
                forUser: createNabuUser(isEmailVerified: true),
                requiredTier: .tier2,
                tiersResponse: pendingTier2Response,
                isSDDEligible: false,
                isSDDVerified: false,
                hasQuestions: false,
                isNewProfile: false
            )
        )
        XCTAssertEqual(
            KYCPageType.states,
            KYCPageType.startingPage(
                forUser: createNabuUser(isEmailVerified: true, hasCountry: true, requireState: true),
                requiredTier: .tier2,
                tiersResponse: pendingTier2Response,
                isSDDEligible: false,
                isSDDVerified: false,
                hasQuestions: false,
                isNewProfile: false
            )
        )
        XCTAssertEqual(
            KYCPageType.profile,
            KYCPageType.startingPage(
                forUser: createNabuUser(isEmailVerified: true, hasCountry: true, requireState: false),
                requiredTier: .tier2,
                tiersResponse: pendingTier2Response,
                isSDDEligible: false,
                isSDDVerified: false,
                hasQuestions: false,
                isNewProfile: false
            )
        )
        XCTAssertEqual(
            KYCPageType.profileNew,
            KYCPageType.startingPage(
                forUser: createNabuUser(isEmailVerified: true, hasCountry: true, requireState: false),
                requiredTier: .tier2,
                tiersResponse: pendingTier2Response,
                isSDDEligible: false,
                isSDDVerified: false,
                hasQuestions: false,
                isNewProfile: true
            )
        )
        XCTAssertEqual(
            KYCPageType.profile,
            KYCPageType.startingPage(
                forUser: createNabuUser(
                    isEmailVerified: true,
                    hasCountry: true,
                    hasState: true
                ),
                requiredTier: .tier2,
                tiersResponse: pendingTier2Response,
                isSDDEligible: false,
                isSDDVerified: false,
                hasQuestions: false,
                isNewProfile: false
            )
        )
        XCTAssertEqual(
            KYCPageType.profileNew,
            KYCPageType.startingPage(
                forUser: createNabuUser(
                    isEmailVerified: true,
                    hasCountry: true,
                    hasState: true
                ),
                requiredTier: .tier2,
                tiersResponse: pendingTier2Response,
                isSDDEligible: false,
                isSDDVerified: false,
                hasQuestions: false,
                isNewProfile: true
            )
        )
        XCTAssertEqual(
            KYCPageType.address,
            KYCPageType.startingPage(
                forUser: createNabuUser(
                    isEmailVerified: true,
                    hasPersonalDetails: true,
                    hasCountry: true,
                    hasState: true
                ),
                requiredTier: .tier2,
                tiersResponse: pendingTier2Response,
                isSDDEligible: false,
                isSDDVerified: false,
                hasQuestions: false,
                isNewProfile: false
            )
        )
        XCTAssertEqual(
            KYCPageType.enterPhone,
            KYCPageType.startingPage(
                forUser: createNabuUser(
                    isEmailVerified: true,
                    hasPersonalDetails: true,
                    hasAddress: true
                ),
                requiredTier: .tier2,
                tiersResponse: pendingTier2Response,
                isSDDEligible: false,
                isSDDVerified: false,
                hasQuestions: false,
                isNewProfile: false
            )
        )
        XCTAssertEqual(
            KYCPageType.accountUsageForm,
            KYCPageType.startingPage(
                forUser: createNabuUser(
                    isMobileVerified: true,
                    isEmailVerified: true,
                    hasPersonalDetails: true,
                    hasAddress: true
                ),
                requiredTier: .tier2,
                tiersResponse: noTiersResponse,
                isSDDEligible: false,
                isSDDVerified: false,
                hasQuestions: false,
                isNewProfile: false
            )
        )
    }

    func testNextPageTier1() {
        XCTAssertEqual(
            KYCPageType.confirmEmail,
            KYCPageType.enterEmail.nextPage(
                forTier: .tier1,
                user: nil,
                country: nil,
                tiersResponse: pendingTier2Response,
                isNewProfile: false
            )
        )
        XCTAssertEqual(
            KYCPageType.country,
            KYCPageType.confirmEmail.nextPage(
                forTier: .tier1,
                user: nil,
                country: nil,
                tiersResponse: pendingTier2Response,
                isNewProfile: false
            )
        )
        XCTAssertEqual(
            KYCPageType.states,
            KYCPageType.country.nextPage(
                forTier: .tier1,
                user: nil,
                country: createKycCountry(hasStates: true),
                tiersResponse: pendingTier2Response,
                isNewProfile: false
            )
        )
        XCTAssertEqual(
            KYCPageType.profile,
            KYCPageType.country.nextPage(
                forTier: .tier1,
                user: nil,
                country: createKycCountry(hasStates: false),
                tiersResponse: pendingTier2Response,
                isNewProfile: false
            )
        )
        XCTAssertEqual(
            KYCPageType.profileNew,
            KYCPageType.country.nextPage(
                forTier: .tier1,
                user: nil,
                country: createKycCountry(hasStates: false),
                tiersResponse: pendingTier2Response,
                isNewProfile: true
            )
        )
        XCTAssertEqual(
            KYCPageType.profile,
            KYCPageType.states.nextPage(
                forTier: .tier1,
                user: nil,
                country: nil,
                tiersResponse: pendingTier2Response,
                isNewProfile: false
            )
        )
        XCTAssertEqual(
            KYCPageType.profileNew,
            KYCPageType.states.nextPage(
                forTier: .tier1,
                user: nil,
                country: nil,
                tiersResponse: pendingTier2Response,
                isNewProfile: true
            )
        )
        XCTAssertEqual(
            KYCPageType.address,
            KYCPageType.profile.nextPage(
                forTier: .tier1,
                user: nil,
                country: nil,
                tiersResponse: pendingTier2Response,
                isNewProfile: false
            )
        )
        XCTAssertEqual(
            KYCPageType.sddVerificationCheck,
            KYCPageType.address.nextPage(
                forTier: .tier1,
                user: nil,
                country: nil,
                tiersResponse: pendingTier2Response,
                isNewProfile: false
            )
        )
        XCTAssertNil(
            KYCPageType.accountUsageForm.nextPage(
                forTier: .tier1,
                user: nil,
                country: nil,
                tiersResponse: pendingTier2Response,
                isNewProfile: false
            )
        )
    }

    func testNextPageTier2() {
        XCTAssertEqual(
            KYCPageType.confirmEmail,
            KYCPageType.enterEmail.nextPage(
                forTier: .tier2,
                user: nil,
                country: nil,
                tiersResponse: pendingTier2Response,
                isNewProfile: false
            )
        )
        XCTAssertEqual(
            KYCPageType.country,
            KYCPageType.confirmEmail.nextPage(
                forTier: .tier2,
                user: nil,
                country: nil,
                tiersResponse: pendingTier2Response,
                isNewProfile: false
            )
        )
        XCTAssertEqual(
            KYCPageType.states,
            KYCPageType.country.nextPage(
                forTier: .tier2,
                user: nil,
                country: createKycCountry(hasStates: true),
                tiersResponse: pendingTier2Response,
                isNewProfile: false
            )
        )
        XCTAssertEqual(
            KYCPageType.profile,
            KYCPageType.country.nextPage(
                forTier: .tier2,
                user: nil,
                country: createKycCountry(hasStates: false),
                tiersResponse: pendingTier2Response,
                isNewProfile: false
            )
        )
        XCTAssertEqual(
            KYCPageType.profileNew,
            KYCPageType.country.nextPage(
                forTier: .tier2,
                user: nil,
                country: createKycCountry(hasStates: false),
                tiersResponse: pendingTier2Response,
                isNewProfile: true
            )
        )
        XCTAssertEqual(
            KYCPageType.profile,
            KYCPageType.states.nextPage(
                forTier: .tier2,
                user: nil,
                country: nil,
                tiersResponse: pendingTier2Response,
                isNewProfile: false
            )
        )
        XCTAssertEqual(
            KYCPageType.profileNew,
            KYCPageType.states.nextPage(
                forTier: .tier2,
                user: nil,
                country: nil,
                tiersResponse: pendingTier2Response,
                isNewProfile: true
            )
        )
        XCTAssertEqual(
            KYCPageType.address,
            KYCPageType.profile.nextPage(
                forTier: .tier2,
                user: nil,
                country: nil,
                tiersResponse: pendingTier2Response,
                isNewProfile: false
            )
        )
        XCTAssertEqual(
            KYCPageType.sddVerificationCheck,
            KYCPageType.address.nextPage(
                forTier: .tier2,
                user: nil,
                country: nil,
                tiersResponse: pendingTier2Response,
                isNewProfile: false
            )
        )
        XCTAssertEqual(
            KYCPageType.sddVerificationCheck,
            KYCPageType.address.nextPage(
                forTier: .tier2,
                user: createNabuUser(isMobileVerified: true),
                country: nil,
                tiersResponse: noTiersResponse,
                isNewProfile: false
            )
        )
        XCTAssertEqual(
            KYCPageType.verifyIdentity,
            KYCPageType.accountUsageForm.nextPage(
                forTier: .tier2,
                user: nil,
                country: nil,
                tiersResponse: pendingTier2Response,
                isNewProfile: false
            )
        )
        XCTAssertEqual(
            KYCPageType.confirmPhone,
            KYCPageType.enterPhone.nextPage(
                forTier: .tier2,
                user: nil,
                country: nil,
                tiersResponse: pendingTier2Response,
                isNewProfile: false
            )
        )
        XCTAssertEqual(
            KYCPageType.accountUsageForm,
            KYCPageType.confirmPhone.nextPage(
                forTier: .tier2,
                user: nil,
                country: nil,
                tiersResponse: pendingTier2Response,
                isNewProfile: false
            )
        )
        XCTAssertEqual(
            KYCPageType.accountStatus,
            KYCPageType.verifyIdentity.nextPage(
                forTier: .tier2,
                user: nil,
                country: nil,
                tiersResponse: pendingTier2Response,
                isNewProfile: false
            )
        )
    }

    private func createKycCountry(hasStates: Bool = false) -> CountryData {
        let states = hasStates ? ["state"] : []
        return CountryData(code: "test", name: "Test Country", scopes: nil, states: states)
    }

    private func createNabuUser(
        isMobileVerified: Bool = false,
        isEmailVerified: Bool = false,
        hasPersonalDetails: Bool = false,
        hasCountry: Bool = false,
        hasState: Bool = false,
        requireState: Bool = true,
        hasAddress: Bool = false
    ) -> NabuUser {
        let mobile = Mobile(phone: "1234567890", verified: isMobileVerified)
        let address: UserAddress?
        if hasAddress {
            address = UserAddress(
                lineOne: "Address",
                lineTwo: "Address 2",
                postalCode: "123",
                city: "City",
                state: "US-CA",
                countryCode: "US"
            )
        } else if hasCountry {
            address = UserAddress(
                lineOne: nil,
                lineTwo: nil,
                postalCode: nil,
                city: nil,
                state: hasState ? "US-CA" : nil,
                countryCode: requireState ? "US" : "GB"
            )
        } else {
            address = nil
        }
        let personalDetails: PersonalDetails
        if hasPersonalDetails {
            personalDetails = PersonalDetails(
                id: "1234",
                first: "Johnny",
                last: "Appleseed",
                birthday: Date(timeIntervalSince1970: 0)
            )
        } else {
            personalDetails = PersonalDetails(id: nil, first: nil, last: nil, birthday: nil)
        }

        return NabuUser(
            identifier: "identifier",
            personalDetails: personalDetails,
            address: address,
            email: Email(address: "test", verified: isEmailVerified),
            mobile: mobile,
            status: KYC.AccountStatus.none,
            state: NabuUser.UserState.none,
            currencies: Currencies(
                preferredFiatTradingCurrency: .USD,
                usableFiatCurrencies: [.USD],
                defaultWalletCurrency: .USD,
                userFiatCurrencies: [.USD]
            ),
            tags: Tags(blockstack: nil, cowboys: nil),
            tiers: nil,
            needsDocumentResubmission: nil,
            productsUsed: NabuUser.ProductsUsed(exchange: false),
            settings: NabuUserSettings(mercuryEmailVerified: false)
        )
    }
}
