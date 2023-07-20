// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import SwiftUI

#if canImport(UIKit)
import UIKit

struct InputExamples: View {
    @State var firstResponder: Field? = .email

    @State var text: String = ""

    @State var password: String = ""
    @State var hidePassword: Bool = true

    @State var number: String = ""

    enum Field {
        case email
        case password
        case number
    }

    var showPasswordError: Bool {
        !password.isEmpty && password.count < 5
    }

    var body: some View {
        VStack {
            // Text
            Input(
                text: $text,
                isFirstResponder: firstResponderBinding(for: .email),
                subTextStyle: .default,
                placeholder: "Email Address",
                prefix: nil,
                state: .default,
                onReturnTapped: {
                    firstResponder = .password
                }
            )
            .keyboardType(.emailAddress)
            .textContentType(.emailAddress)
            .submitLabel(.next)

            // Password
            Input(
                text: $password,
                isFirstResponder: firstResponderBinding(for: .password),
                subText: showPasswordError ? "Password too short" : nil,
                subTextStyle: showPasswordError ? .error : .default,
                placeholder: "Password",
                state: showPasswordError ? .error : .default,
                isSecure: !hidePassword,
                trailing: {
                    if hidePassword {
                        IconButton(icon: .visibilityOn) {
                            hidePassword = false
                        }
                    } else {
                        IconButton(icon: .visibilityOff) {
                            hidePassword = true
                        }
                    }
                },
                onReturnTapped: {
                    firstResponder = .number
                }
            )
            .textContentType(.password)
            .submitLabel(.next)

            // Number
            Input(
                text: $number,
                isFirstResponder: firstResponderBinding(for: .number),
                label: "Purchase amount",
                placeholder: "0",
                prefix: "USD"
            )
            .keyboardType(.decimalPad)
            .submitLabel(.done)

            Spacer()
        }
        .padding()
    }

    func firstResponderBinding(for field: Field) -> Binding<Bool> {
        Binding(
            get: { firstResponder == field },
            set: { newValue in
                if newValue {
                    firstResponder = field
                } else if firstResponder == field {
                    firstResponder = nil
                }
            }
        )
    }
}

struct InputExamples_Previews: PreviewProvider {
    static var previews: some View {
        InputExamples()
    }
}
#else

struct InputExamples: View {

    var body: some View {
        Text("Not supported on macOS")
    }
}

#endif
