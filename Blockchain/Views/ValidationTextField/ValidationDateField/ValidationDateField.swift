//
//  ValidationDateField.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/7/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

/// `ValidationDateField` is a `ValidationTextField`
/// that presents a `UIDatePicker` instead of a keyboard.
/// It does not support manual date entry.
/// Ideally this would be a `UIPickerView` with its own dataSource
/// but due to time constraints I am using a `UIDatePicker`.
class ValidationDateField: ValidationTextField {

    lazy var pickerView: UIDatePicker = {
        let picker = UIDatePicker(frame: .zero)
        return picker
    }()

    var selectedDate: Date {
        get {
            return pickerView.date
        }
        set {
            pickerView.date = newValue
            datePickerUpdated(pickerView)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        pickerView.datePickerMode = .date
        pickerView.maximumDate = Date()
        textFieldInputView = pickerView
        pickerView.addTarget(self, action: #selector(datePickerUpdated(_:)), for: .valueChanged)
    }
    
    @objc func datePickerUpdated(_ sender: UIDatePicker) {
        text = DateFormatter.medium.string(from: sender.date)
    }

    override func textFieldDidEndEditing(_ textField: UITextField) {
        super.textFieldDidEndEditing(textField)
        pickerView.isHidden = true
    }

    override func textFieldDidBeginEditing(_ textField: UITextField) {
        super.textFieldDidBeginEditing(textField)
        pickerView.isHidden = false
    }

    override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
}
