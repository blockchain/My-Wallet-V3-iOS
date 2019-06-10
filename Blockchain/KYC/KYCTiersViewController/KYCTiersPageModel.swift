//
//  KYCTiersPageModel.swift
//  Blockchain
//
//  Created by AlexM on 12/11/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

struct KYCTiersPageModel {
    let header: KYCTiersHeaderViewModel
    let cells: [KYCTierCellModel]
}

extension KYCTiersPageModel {
    var disclaimer: String? {
        guard let tierTwo = cells.filter({ $0.tier == .tier2 }).first else { return nil }
        guard tierTwo.status != .rejected else { return nil }
        let hasLargeBacklog = AppFeatureConfigurator.shared.configuration(for: .stellarLargeBacklog).isEnabled
        if tierTwo.status == KYCTierCellModel.ApprovalStatus.inReview && hasLargeBacklog {
            return LocalizationConstants.KYC.airdropLargeBacklogNotice
        } else {
            return LocalizationConstants.KYC.completingTierTwoAutoEligible
        }
    }
    
    func trackPresentation() {
        let metadata = cells.map({ return ($0.tier, $0.status) })
        guard let tier1 = metadata.filter({ $0.0 == .tier1 }).first else { return }
        guard let tier2 = metadata.filter({ $0.0 == .tier2 }).first else { return }
        let tierOneStatus = tier1.1
        let tierTwoStatus = tier2.1
        
        switch (tierOneStatus, tierTwoStatus) {
        case (.none, .none):
            AnalyticsService.shared.trackEvent(title: KYCTier.lockedAnalyticsKey)
        case (.approved, .none):
            AnalyticsService.shared.trackEvent(title: tier1.0.completionAnalyticsKey)
        case (_, .inReview),
             (_, .approved):
            AnalyticsService.shared.trackEvent(title: tier2.0.completionAnalyticsKey)
        default:
            break
        }
    }
}
