// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Localization
import RxSwift
import ToolKit

enum MemoTextFieldViewModel {

    static func create(
        messageRecorder: MessageRecording
    ) -> TextFieldViewModel {
        TextFieldViewModel(
            with: .memo,
            validator: TextValidationFactory.Send.memo,
            backgroundColor: .semantic.background,
            messageRecorder: messageRecorder
        )
    }
}
