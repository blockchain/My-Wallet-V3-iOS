//
//  AlwaysValidValidator.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 09/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxRelay
import RxSwift

/// A validator that is always valid
final class AlwaysValidValidator: TextValidating {
    
    // MARK: - TextValidating Properties
    
    let valueRelay = BehaviorRelay<String>(value: "")
    var validationState: Observable<TextValidationState> {
        .just(.valid)
    }
}

