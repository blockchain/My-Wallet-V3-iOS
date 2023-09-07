// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Localization
import RxSwift
import ToolKit

enum CryptoAddressTextFieldViewModel {

    static func create(
        validator: TextValidating,
        messageRecorder: MessageRecording
    ) -> TextFieldViewModel {
        TextFieldViewModel(
            with: .cryptoAddress,
            validator: validator,
            backgroundColor: .semantic.background,
            accessoryContent: .badgeImageView(badgeImageViewModel),
            messageRecorder: messageRecorder
        )
    }

    private static var badgeImageViewModel: BadgeImageViewModel {
        let content = ImageViewContent(
            imageResource: .local(
                name: Icon.qrCodev2.name,
                bundle: .componentLibrary
            )
        )
        let theme = BadgeImageViewModel.Theme(
            backgroundColor: .semantic.background,
            cornerRadius: .roundedLow,
            imageViewContent: content,
            marginOffset: 0,
            sizingType: .constant(CGSize(width: 24, height: 24))
        )
        return BadgeImageViewModel(
            theme: theme
        )
    }
}
