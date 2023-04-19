// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import FeatureReferralDomain
import SwiftUI

public struct ReferFriendState: Equatable {
    var codeIsCopied: Bool
    var referralInfo: Referral
    @BindingState var isShareModalPresented: Bool = false
    @BindingState var isShowReferralViewPresented: Bool = false

    public init(
        codeIsCopied: Bool = false,
        referralInfo: Referral
    ) {
        self.codeIsCopied = codeIsCopied
        self.referralInfo = referralInfo
    }
}
