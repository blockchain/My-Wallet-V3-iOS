// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import Foundation
import ToolKit

/// Intend for SwiftUI Previews and only available in DEBUG
final class NoOpValidator: SeedPhraseValidatorAPI {
    func validate(phrase: String) -> AnyPublisher<FeatureAuthenticationDomain.MnemonicValidationScore, Never> {
        .just(.valid)
    }
}

final class NoOpSignupCountryService: SignUpCountriesServiceAPI {
    var countries: AnyPublisher<[FeatureAuthenticationDomain.Country], Error> {
        .just([])
    }
}
