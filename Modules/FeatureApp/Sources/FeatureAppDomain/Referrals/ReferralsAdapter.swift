// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import Errors
import FeatureProductsDomain
import FeatureReferralDomain
import FeatureSettingsDomain
import Foundation
import ToolKit

final class ReferralsAdapter: ReferralAdapterAPI {
    private let referralService: ReferralServiceAPI
    private let app: AppProtocol

    init(
        referralService: ReferralServiceAPI,
        app: AppProtocol
    ) {
        self.referralService = referralService
        self.app = app
    }

    func externalBrokerageActive() -> AnyPublisher<Bool, Never> {
        app.publisher(for: blockchain.app.is.external.brokerage, as: Bool.self)
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }


    func hasReferral() -> AnyPublisher<Referral?, Never> {
        referralService.fetchReferralCampaign()
            .combineLatest(externalBrokerageActive())
            .map { referral, isEnabled in
                guard isEnabled == false else {
                    return nil
                }
                return referral
            }
            .eraseToAnyPublisher()
    }
}
