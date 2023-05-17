// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureAuthenticationDomain
import Localization
import SwiftUI

public struct PasswordStrengthIndicatorView: View {

    private typealias LocalizedString = LocalizationConstants.FeatureAuthentication.PasswordStrength

    private enum Layout {
        static let animationEaseOutSeconds: Double = 2
        static let verticalScaleFactor: CGFloat = 1.5
        static let fontSize: CGFloat = 12
    }

    @Binding private var passwordStrength: PasswordValidationScore

    private var passwordStrengthProgressValue: CGFloat {
        switch passwordStrength {
        case .none:
            return 0
        case .weak:
            return 1 / 3 * 100
        case .normal:
            return 2 / 3 * 100
        case .strong:
            return 100
        }
    }

    private var passwordStrengthColor: Color {
        switch passwordStrength {
        case .none, .weak:
            return .semantic.error
        case .normal:
            return .semantic.warning
        case .strong:
            return .semantic.success
        }
    }

    private var passwordStrengthLabelString: String {
        switch passwordStrength {
        case .none:
            return ""
        case .weak:
            return LocalizedString.weak
        case .normal:
            return LocalizedString.medium
        case .strong:
            return LocalizedString.strong
        }
    }

    public init(passwordStrength: Binding<PasswordValidationScore>) {
        _passwordStrength = passwordStrength
    }

    public var body: some View {
        Group {
            ProgressView(value: passwordStrengthProgressValue, total: 100)
                .animation(
                    Animation.easeOut(duration: Layout.animationEaseOutSeconds),
                    value: passwordStrengthProgressValue
                )
                .accentColor(passwordStrengthColor)
                .scaleEffect(x: 1, y: Layout.verticalScaleFactor)
            HStack {
                Text(LocalizedString.title)
                    .typography(.caption1)
                    .foregroundColor(.semantic.text)
                Spacer()
                Text(passwordStrengthLabelString)
                    .typography(.caption1)
                    .foregroundColor(passwordStrengthColor)
            }
        }
    }
}

#if DEBUG
private struct PasswordStrengthIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            PasswordStrengthIndicatorView(
                passwordStrength: .constant(.weak)
            )
            PasswordStrengthIndicatorView(
                passwordStrength: .constant(.normal)
            )
            PasswordStrengthIndicatorView(
                passwordStrength: .constant(.strong)
            )
        }
        .padding()
    }
}
#endif
