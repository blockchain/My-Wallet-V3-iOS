import SwiftUI

public struct FormTextFieldGroup<TrailingAccessoryView: View>: View {

    @Binding public var text: String
    @Binding public var isFirstResponder: Bool
    @Binding public var isError: Bool

    private let title: String
    private let footnote: String?
    private let configuration: (UITextField) -> Void

    private let isPrefilledAndDisabled: Bool
    private let errorMessage: String?

    private let onReturnTapped: () -> Void
    private let onPaddingTapped: () -> Void
    private let trailingAccessoryView: TrailingAccessoryView

    public init(
        text: Binding<String>,
        isFirstResponder: Binding<Bool>,
        isError: Binding<Bool>,
        title: String,
        footnote: String? = nil,
        configuration: @escaping (UITextField) -> Void = { _ in },
        isPrefilledAndDisabled: Bool = false,
        errorMessage: String? = nil,
        onPaddingTapped: @escaping () -> Void = {},
        onReturnTapped: @escaping () -> Void = {},
        @ViewBuilder trailingAccessoryView: () -> TrailingAccessoryView
    ) {
        _text = text
        _isFirstResponder = isFirstResponder
        _isError = isError
        self.isPrefilledAndDisabled = isPrefilledAndDisabled
        self.configuration = configuration
        self.title = title
        self.footnote = footnote
        self.errorMessage = errorMessage
        self.onPaddingTapped = onPaddingTapped
        self.onReturnTapped = onReturnTapped
        self.trailingAccessoryView = trailingAccessoryView()
    }

    public var body: some View {
        VStack(
            alignment: .leading,
            spacing: LayoutConstants.VerticalSpacing.withinFormGroup
        ) {
            Text(title)
                .textStyle(.body)
            ZStack(alignment: .trailing) {
                FocusableTextField(
                    text: $text,
                    isFirstResponder: $isFirstResponder,
                    configuration: {
                        $0.isEnabled = !isPrefilledAndDisabled
                        configuration($0)
                    },
                    onReturnTapped: onReturnTapped
                )
                .textFieldStyle(
                    FormTextFieldStyle(
                        isFirstResponder: $isFirstResponder,
                        isError: $isError,
                        isPrefilledAndDisabled: isPrefilledAndDisabled
                    )
                )

                trailingAccessoryView
                    .padding(.trailing, 15)
            }
            if let footnote {
                Text(footnote)
                    .textStyle(.subheading)
            }
            if let error = errorMessage, isError {
                Text(error)
                    .font(Font(weight: .medium, size: 14))
                    .foregroundColor(Color.textError)
            }
        }
    }
}

extension FormTextFieldGroup where TrailingAccessoryView == EmptyView {
    public init(
        text: Binding<String>,
        isFirstResponder: Binding<Bool>,
        isError: Binding<Bool>,
        title: String,
        footnote: String? = nil,
        configuration: @escaping (UITextField) -> Void = { _ in },
        isPrefilledAndDisabled: Bool = false,
        errorMessage: String? = nil,
        onPaddingTapped: @escaping () -> Void = {},
        onReturnTapped: @escaping () -> Void = {}
    ) {
        self.init(
            text: text,
            isFirstResponder: isFirstResponder,
            isError: isError,
            title: title,
            footnote: footnote,
            configuration: configuration,
            isPrefilledAndDisabled: isPrefilledAndDisabled,
            errorMessage: errorMessage,
            onPaddingTapped: onPaddingTapped,
            onReturnTapped: onReturnTapped,
            trailingAccessoryView: { EmptyView() }
        )
    }
}

#if DEBUG
struct FormTextFieldGroupDemoView: View {

    @State private var isPasswordVisible: Bool = false

    var body: some View {
        VStack {
            FormTextFieldGroup(
                text: .constant("test@example.com"),
                isFirstResponder: .constant(false),
                isError: .constant(false),
                title: "Email",
                configuration: {
                    $0.textContentType = .emailAddress
                    $0.autocorrectionType = .no
                    $0.autocapitalizationType = .none
                }
            )
            FormTextFieldGroup(
                text: .constant("password1234"),
                isFirstResponder: .constant(false),
                isError: .constant(false),
                title: "Password",
                configuration: {
                    $0.isSecureTextEntry = true
                    $0.textContentType = .password
                    $0.autocorrectionType = .no
                    $0.autocapitalizationType = .none
                },
                trailingAccessoryView: {
                    PasswordEyeSymbolButton(isPasswordVisible: $isPasswordVisible)
                }
            )
            FormTextFieldGroup(
                text: .constant("editing with footnote"),
                isFirstResponder: .constant(true),
                isError: .constant(false),
                title: "Example Text",
                footnote: "Example Footnote"
            )
        }
        .padding()
    }
}

struct FormTextFieldGroup_Previews: PreviewProvider {
    static var previews: some View {
        FormTextFieldGroupDemoView()
            .preferredColorScheme(.light)
        FormTextFieldGroupDemoView()
            .preferredColorScheme(.dark)
    }
}
#endif
