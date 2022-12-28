import SwiftUI

/// A TextField that is backed by UIKit that allows us to get/set its first responder state
public struct FocusableTextField: UIViewRepresentable {

    @Binding public var isFirstResponder: Bool
    @Binding public var text: String

    public var configuration = { (_: UITextField) in }
    public var onReturnTapped = {}

    public init(
        text: Binding<String>,
        isFirstResponder: Binding<Bool>,
        configuration: @escaping (UITextField) -> Void = { _ in },
        onReturnTapped: @escaping () -> Void = {}
    ) {
        self.configuration = configuration
        _text = text
        _isFirstResponder = isFirstResponder
        self.onReturnTapped = onReturnTapped
    }

    public func makeUIView(context: Context) -> UITextField {
        let view = UITextField()
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.addTarget(context.coordinator, action: #selector(Coordinator.textViewDidChange), for: .editingChanged)
        view.delegate = context.coordinator
        return view
    }

    public func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        configuration(uiView)
        DispatchQueue.main.async {
            switch isFirstResponder {
            case true:
                uiView.becomeFirstResponder()
            case false:
                uiView.resignFirstResponder()
            }
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator($text, isFirstResponder: $isFirstResponder, onReturnTapped: onReturnTapped)
    }

    public class Coordinator: NSObject, UITextFieldDelegate {
        var text: Binding<String>
        var isFirstResponder: Binding<Bool>
        var onReturnTapped: () -> Void

        init(_ text: Binding<String>, isFirstResponder: Binding<Bool>, onReturnTapped: @escaping () -> Void) {
            self.text = text
            self.isFirstResponder = isFirstResponder
            self.onReturnTapped = onReturnTapped
        }

        @objc public func textViewDidChange(_ textField: UITextField) {
            text.wrappedValue = textField.text ?? ""
        }

        public func textFieldDidBeginEditing(_ textField: UITextField) {
            DispatchQueue.main.async {
                self.isFirstResponder.wrappedValue = true
            }
        }

        public func textFieldDidEndEditing(_ textField: UITextField) {
            DispatchQueue.main.async {
                self.isFirstResponder.wrappedValue = false
            }
        }

        public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            // Dispatching is necessary otherwise the view doesn't update properly
            DispatchQueue.main.async(execute: onReturnTapped)
            return true
        }
    }
}

extension FocusableTextField {
    @ViewBuilder
    public func textFieldStyle(_ textFieldStyle: some TextFieldStyle) -> some View {

        switch textFieldStyle {
        case let style as FormTextFieldStyle:
            textStyle(.formField)
                .padding(style.paddingInsets)
                .overlay(
                    RoundedRectangle(cornerRadius: LayoutConstants.fieldCornerRadious)
                        .stroke(
                            style.isError ?
                                Color.borderError :
                                (isFirstResponder ? Color.borderFocused : Color.borderPrimary),
                            lineWidth: style.borderWidth
                        )
                )
                .background(
                    RoundedRectangle(cornerRadius: LayoutConstants.fieldCornerRadious)
                        .fill(style.isPrefilledAndDisabled ?
                            Color.textFieldPrefilledAndDisabledBackground :
                            Color.viewPrimaryBackground
                        )
                )
                .frame(minHeight: LayoutConstants.fieldMinHeight)
        default:
            self
        }
    }
}

struct FocusableTextField_Previews: PreviewProvider {
    static var previews: some View {
        FocusableTextField(text: .constant("test@example.com"), isFirstResponder: .constant(false))
            .padding()
    }
}
