import SwiftUI

public struct FormTextFieldStyle: TextFieldStyle {

    let paddingInsets = EdgeInsets(
        top: 12,
        leading: 12,
        bottom: 12,
        trailing: 12
    )
    let borderWidth: CGFloat = 1
    let isPrefilledAndDisabled: Bool

    @Binding var isFirstResponder: Bool
    @Binding var isError: Bool

    public init(
        isFirstResponder: Binding<Bool>,
        isError: Binding<Bool>,
        isPrefilledAndDisabled: Bool
    ) {
        // required for exposing the view to the external world
        _isFirstResponder = isFirstResponder
        _isError = isError
        self.isPrefilledAndDisabled = isPrefilledAndDisabled
    }

    public func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .textStyle(.formField)
            .padding(paddingInsets)
            .overlay(
                RoundedRectangle(cornerRadius: LayoutConstants.fieldCornerRadious)
                    .stroke(
                        isError ?
                            Color.borderError :
                            (isFirstResponder ? Color.borderFocused : Color.borderPrimary),
                        lineWidth: borderWidth
                    )
            )
            .background(
                RoundedRectangle(cornerRadius: LayoutConstants.fieldCornerRadious)
                    .fill(isPrefilledAndDisabled ?
                        Color.textFieldPrefilledAndDisabledBackground :
                        Color.viewPrimaryBackground
                    )
            )
            .frame(minHeight: LayoutConstants.fieldMinHeight)
    }
}

#if DEBUG
struct FormTextFieldStyleDemoView: View {

    var body: some View {
        VStack {
            TextField("Placeholder", text: .constant("Lorem ipsum"))
                .textFieldStyle(
                    FormTextFieldStyle(
                        isFirstResponder: .constant(false),
                        isError: .constant(false),
                        isPrefilledAndDisabled: false
                    )
                )
            TextField("Placeholder", text: .constant("Editing"))
                .textFieldStyle(
                    FormTextFieldStyle(
                        isFirstResponder: .constant(true),
                        isError: .constant(false),
                        isPrefilledAndDisabled: false
                    )
                )
            TextField("Placeholder", text: .constant("Error"))
                .textFieldStyle(
                    FormTextFieldStyle(
                        isFirstResponder: .constant(false),
                        isError: .constant(true),
                        isPrefilledAndDisabled: false
                    )
                )
            TextField("Placeholder", text: .constant("Prefilled and Disabled"))
                .textFieldStyle(
                    FormTextFieldStyle(
                        isFirstResponder: .constant(false),
                        isError: .constant(false),
                        isPrefilledAndDisabled: true
                    )
                )
        }
        .padding()
    }
}

struct FormTextFieldStyle_Previews: PreviewProvider {
    static var previews: some View {
        FormTextFieldStyleDemoView()
            .preferredColorScheme(.light)
        FormTextFieldStyleDemoView()
            .preferredColorScheme(.dark)
    }
}
#endif
