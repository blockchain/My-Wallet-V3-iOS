// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift

/// Handles paging from one `KYCPageType` to another.
public protocol KYCPagerAPI: Any {

    var tier: KYC.Tier { get }
    /// We need a `tiersResponse` as it is this model that determines
    /// whether or not a user is verified approved. We can
    /// derive their status and present a `KYCInformationController` which
    /// is of `KYCPageType.accountStatus`
    var tiersResponse: KYC.UserTiers { get }

    /// Returns the next page from the provided KYCPageType. This method also takes into account
    /// sanctioned checks such that if the rules engine determines that a user should be put
    /// through a higher tier KYC flow, this method will keep returning new pages.
    ///
    /// - Parameters:
    ///   - page: the page to return the next page from
    ///   - payload: an optional payload for the page
    /// - Returns: a Maybe which emits a KYCPageType if there is a next page, otherwise, returns nothing
    func nextPage(from page: KYCPageType, payload: KYCPagePayload?) -> Maybe<KYCPageType>
}
