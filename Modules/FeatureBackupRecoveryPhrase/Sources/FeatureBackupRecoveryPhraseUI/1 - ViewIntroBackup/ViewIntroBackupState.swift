import ComposableArchitecture
import SwiftUI

public struct ViewIntroBackupState: Equatable {
    var backupButtonEnabled: Bool { checkBox1IsOn && checkBox2IsOn && checkBox3IsOn }
    @BindingState var checkBox1IsOn: Bool = false
    @BindingState var checkBox2IsOn: Bool = false
    @BindingState var checkBox3IsOn: Bool = false
    @BindingState var skipConfirmShown: Bool = false
    var recoveryPhraseBackedUp: Bool

    public init(recoveryPhraseBackedUp: Bool) {
        self.recoveryPhraseBackedUp = recoveryPhraseBackedUp
    }
}
