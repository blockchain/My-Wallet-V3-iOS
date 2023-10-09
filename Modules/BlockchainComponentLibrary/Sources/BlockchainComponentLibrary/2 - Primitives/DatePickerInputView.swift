#if canImport(UIKit)
import Extensions
import SwiftUI
import UIKit

public let shortDateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .none
    return formatter
}()

public struct DatePickerInputView: UIViewRepresentable {

    @Binding private var date: Date?
    private let placeholder: String
    private let dateFormatter = shortDateFormatter

    public init(
        _ placeholder: String,
        date: Binding<Date?>
    ) {
        _date = date
        self.placeholder = placeholder
    }

    public func updateUIView(_ view: DatePickerTextField, context: Context) {
        view.placeholder = placeholder
        view.text = date.map(dateFormatter.string(from:))
    }

    public func makeUIView(context: Context) -> DatePickerTextField {
        let view = DatePickerTextField(date: $date)
        view.placeholder = placeholder
        view.text = date.map(dateFormatter.string(from:))
        return view
    }
}

public final class DatePickerTextField: UITextField {

    @Binding private var date: Date?
    private let datePicker = UIDatePicker()

    public init(date: Binding<Date?>, frame: CGRect = .zero) {
        self._date = date
        super.init(frame: frame)
        inputView = datePicker
        let imageView = UIImageView(image: UIImage(named: "Calendar", in: .componentLibrary, compatibleWith: nil)); do {
            imageView.contentMode = .scaleAspectFit
        }
        rightViewMode = .always
        rightView = imageView
        datePicker.addTarget(self, action: #selector(datePickerDidSelect(_:)), for: .valueChanged)
        datePicker.datePickerMode = .date
        let toolBar = UIToolbar(); do {
            toolBar.sizeToFit()
            toolBar.setItems(
                [
                    UIBarButtonItem(
                        barButtonSystemItem: .flexibleSpace,
                        target: nil,
                        action: nil
                    ),
                    UIBarButtonItem(
                        title: NSLocalizedString("Done", comment: "Done"),
                        style: .plain,
                        target: self,
                        action: #selector(dismissTextField)
                    )
                ],
                animated: false
            )
        }
        inputAccessoryView = toolBar
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func datePickerDidSelect(_ sender: UIDatePicker) {
        date = sender.date
    }

    @objc private func dismissTextField() {
        resignFirstResponder()
    }

    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        CGRectInset(bounds, 10, 0)
    }

    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        CGRectInset(bounds, 10, 0)
    }

    public override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.rightViewRect(forBounds: bounds)
        rect.origin.x -= 10
        return rect
    }
}
#else

public struct DatePickerInputView: View {

    private let dateFormatter = DateFormatter.shortWithoutYear

    @Binding private var date: Date = Date()
    private let placeholder: String

    public init(
        _ placeholder: String,
        date: Binding<Date?>
    ) {
        _date = date
        self.placeholder = placeholder
    }

    var body: some View {
        TextField(placeholder, text: binding)
    }

    var binding: Binding<String> {
        Binding(
            get: { dateFormatter.string(from: date) },
            set: { newValue in date = dateFormatter.date(from: newValue) ?? Date() }
        )
    }
}

#endif
