// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformUIKit

extension CheckboxViewModel {
    private typealias LocalizationIds = LocalizationConstants.Transaction.Transfer

    static var termsCheckboxViewModel: CheckboxViewModel {
        CheckboxViewModel(
            inputs: [
                .text(string: LocalizationIds.ToS.prefix + " "),
                .url(
                    string: LocalizationIds.ToS.privacyPolicy,
                    url: "https://blockchain.com/legal/privacy"
                ),
                .text(string: " & "),
                .url(
                    string: LocalizationIds.ToS.termsOfService,
                    url: "https://www.blockchain.com/legal"
                )
            ]
        )
    }
}
