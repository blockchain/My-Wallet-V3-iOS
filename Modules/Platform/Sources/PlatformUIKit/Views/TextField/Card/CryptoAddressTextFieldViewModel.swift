// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Localization
import RxSwift
import ToolKit

public final class CryptoAddressTextFieldViewModel: TextFieldViewModel {

    // MARK: - Setup

    public init(
        validator: TextValidating,
        messageRecorder: MessageRecording
    ) {
        super.init(
            with: .cryptoAddress,
            validator: validator,
            backgroundColor: .semantic.background,
            messageRecorder: messageRecorder
        )

        // BadgeImageViewModel
        accessoryContentTypeRelay.accept(.badgeImageView(badgeImageViewModel))
    }

    private var badgeImageViewModel: BadgeImageViewModel {
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
