//
//  AddBankInteractor.swift
//  Blockchain
//
//  Created by Daniel on 22/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import DIKit
import PlatformKit
import RxSwift

final class AddBankInteractor: AddSpecificPaymentMethodInteractorAPI {
    
    private let beneficiariesService: BeneficiariesServiceAPI
    private let featureConfiguring: FeatureConfiguring
    private let fiatCurrency: FiatCurrency
    
    var isAbleToAddNew: Observable<Bool> {
        let fiatCurrency = self.fiatCurrency
        let featureConfiguring = self.featureConfiguring
        return beneficiariesService.availableCurrenciesForBankLinkage
            .map { currencies -> Bool in
                if fiatCurrency == .USD {
                    return featureConfiguring.configuration(for: .achSettingsEnabled).isEnabled && currencies.contains(fiatCurrency)
                }
                return currencies.contains(fiatCurrency)
            }
            .catchErrorJustReturn(false)
            .share(replay: 1)
    }
    
    init(beneficiariesService: BeneficiariesServiceAPI,
         fiatCurrency: FiatCurrency,
         featureConfiguring: FeatureConfiguring = resolve()) {
        self.fiatCurrency = fiatCurrency
        self.beneficiariesService = beneficiariesService
        self.featureConfiguring = featureConfiguring
    }
}
