//
//  PaxEmptyStateViewModel.swift
//  Blockchain
//
//  Created by Jack on 12/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct PaxEmptyStateViewModel {
    struct Link {
        let text: String
        let action: () -> Void
    }
    
    struct CTAButton {
        let title: String
        let action: () -> Void
    }
    
    let iconImage: UIImage = #imageLiteral(resourceName: "Logo-PAX")
    let title: String
    let subTitle: String
    let link: Link
    let ctaButton: CTAButton
}
