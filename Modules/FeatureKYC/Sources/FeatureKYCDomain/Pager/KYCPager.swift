// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import DIKit
import Errors
import FeatureFormDomain
import PlatformKit
import RxSwift

public final class KYCPager: KYCPagerAPI {

    private let app: AppProtocol
    private let nabuUserService: NabuUserServiceAPI
    private let isNewProfile: Bool
    public private(set) var tier: KYC.Tier
    public private(set) var tiersResponse: KYC.UserTiers

    public init(
        app: AppProtocol = resolve(),
        nabuUserService: NabuUserServiceAPI = resolve(),
        isNewProfile: Bool,
        tier: KYC.Tier,
        tiersResponse: KYC.UserTiers
    ) {
        self.app = app
        self.nabuUserService = nabuUserService
        self.isNewProfile = isNewProfile
        self.tier = tier
        self.tiersResponse = tiersResponse
    }

    public func nextPage(from page: KYCPageType, payload: KYCPagePayload?) -> Maybe<KYCPageType> {
        var hasQuestions = false
        do {
            hasQuestions = try !app.state.get(blockchain.ux.kyc.extra.questions.form.is.empty)
        } catch {
            hasQuestions = false
        }
        // Get country from payload if present
        var kycCountry: CountryData?
        if let payload {
            switch payload {
            case .countrySelected(let country):
                kycCountry = country
            case .stateSelected:
                // no-op: handled in coordinator
                break
            case .phoneNumberUpdated,
                 .emailPendingVerification,
                 .accountStatus:
                // Not handled here
                break
            }
        }

        return Observable.combineLatest(
            nabuUserService.user.asObservable(),
            app.publisher(for: blockchain.ux.kyc.SSN.should.be.collected, as: Bool.self)
                .replaceError(with: false)
                .prefix(1)
                .asObservable()
        )
        .asSingle()
        .flatMapMaybe { [weak self] user, isSSNRequired -> Maybe<KYCPageType> in
            guard let strongSelf = self else { return Maybe.empty() }
            if let nextPage = page.nextPage(
                forTier: strongSelf.tier,
                user: user,
                country: kycCountry,
                tiersResponse: strongSelf.tiersResponse,
                isNewProfile: strongSelf.isNewProfile,
                isSSNRequired: isSSNRequired
            ) {
                return Maybe.just(nextPage)
            } else if hasQuestions {
                return Maybe.just(.accountUsageForm)
            } else {
                return Maybe.empty()
            }
        }
    }
}

// MARK: KYCPageType Extensions

extension KYCPageType {

    public static func startingPage(
        forUser user: NabuUser,
        requiredTier: KYC.Tier,
        tiersResponse: KYC.UserTiers,
        hasQuestions: Bool,
        isNewProfile: Bool,
        isSSNRequired: Bool
    ) -> KYCPageType {
        guard user.email.verified else {
            return .enterEmail
        }

        guard user.address != nil else {
            return .country
        }

        let countryCode = user.address?.countryCode.lowercased()
        let state = user.address?.state
        if countryCode == "us", state == nil {
            return .states
        }

        guard user.personalDetails.isComplete else {
            return isNewProfile ? .profileNew : .profile
        }

        guard user.address?.postalCode != nil else {
            return .address
        }

        guard let mobile = user.mobile, mobile.verified else {
            return .enterPhone
        }

        if hasQuestions {
            return .accountUsageForm
        }

        if isSSNRequired {
            return .ssn
        }

        guard tiersResponse.canCompleteVerified else {
            return .accountStatus
        }

        guard requiredTier < .verified else {
            return .accountUsageForm
        }

        return .verifyIdentity
    }

    public func nextPage(
        forTier tier: KYC.Tier,
        user: NabuUser?,
        country: CountryData?,
        tiersResponse: KYC.UserTiers,
        isNewProfile: Bool,
        isSSNRequired: Bool
    ) -> KYCPageType? {
        switch tier {
        case .unverified:
            nextPageUnverified(
                user: user,
                country: country,
                requiredTier: .verified,
                tiersResponse: tiersResponse,
                isNewProfile: isNewProfile,
                isSSNRequired: isSSNRequired
            )
        case .verified:
            nextPageVerified(
                user: user,
                country: country,
                tiersResponse: tiersResponse,
                isNewProfile: isNewProfile,
                isSSNRequired: isSSNRequired
            )
        }
    }

    private func nextPageUnverified(
        user: NabuUser?,
        country: CountryData?,
        requiredTier: KYC.Tier,
        tiersResponse: KYC.UserTiers,
        isNewProfile: Bool,
        isSSNRequired: Bool
    ) -> KYCPageType? {
        switch self {
        case .finish:
            return nil
        case .welcome:
            if let user {
                // We can pass true here, as non-eligible users would get send to the Tier 2 upgrade path anyway
                return KYCPageType.startingPage(
                    forUser: user,
                    requiredTier: requiredTier,
                    tiersResponse: tiersResponse,
                    hasQuestions: false,
                    isNewProfile: isNewProfile,
                    isSSNRequired: isSSNRequired
                )
            }
            return .enterEmail
        case .enterEmail:
            return .confirmEmail
        case .confirmEmail:
            guard user?.address?.countryCode != nil else {
                return .country
            }
            guard user?.personalDetails.isComplete == false else {
                return .address
            }
            return isNewProfile ? .profileNew : .profile
        case .country:
            if let country, !country.states.isEmpty {
                return .states
            }
            if let user, user.personalDetails.isComplete {
                return .address
            }
            return isNewProfile ? .profileNew : .profile
        case .states:
            return isNewProfile ? .profileNew : .profile
        case .profile, .profileNew:
            return .address
        case .verifyIdentity where isSSNRequired:
            return .ssn
        case .address,
                .enterPhone,
                .confirmPhone,
                .accountUsageForm,
                .verifyIdentity,
                .resubmitIdentity,
                .applicationComplete,
                .accountStatus,
                .ssn:
            // All other pages don't have a next page for tier 1
            return nil
        }
    }

    private func nextPageVerified(
        user: NabuUser?,
        country: CountryData?,
        tiersResponse: KYC.UserTiers,
        isNewProfile: Bool,
        isSSNRequired: Bool
    ) -> KYCPageType? {
        switch self {
        case .enterPhone:
            .confirmPhone
        case .confirmPhone:
            .accountUsageForm
        case .accountUsageForm:
            user?.needsDocumentResubmission == nil ? .verifyIdentity : .resubmitIdentity
        case .verifyIdentity, .resubmitIdentity:
            isSSNRequired ? .ssn : .accountStatus
        case .ssn:
            .accountStatus
        case .applicationComplete:
            // Not used
            nil
        case .accountStatus, .finish:
            nil
        case .welcome,
             .enterEmail,
             .confirmEmail,
             .country,
             .states,
             .address,
             .profile,
             .profileNew:
            nextPageUnverified(
                user: user,
                country: country,
                requiredTier: .verified,
                tiersResponse: tiersResponse,
                isNewProfile: isNewProfile,
                isSSNRequired: isSSNRequired
            )
        }
    }
}
