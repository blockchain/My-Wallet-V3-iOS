// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

/// Enumerates the supported payload types as a result of completing completing a KYC page
public enum KYCPagePayload {
    case countrySelected(country: CountryData)
    case stateSelected(_ state: KYCState, _ states: [KYCState])
    case phoneNumberUpdated(phoneNumber: String)
    case emailPendingVerification(email: String)
    case accountStatus(status: KYC.AccountStatus, isReceivingAirdrop: Bool)
}
