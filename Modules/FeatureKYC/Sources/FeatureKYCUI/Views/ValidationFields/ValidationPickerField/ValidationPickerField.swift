// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

/// `ValidationPickerField` is a `ValidationTextField`
/// that presents a `UIPickerPicker` of `PickerItem`s instead of a keyboard.
/// At the moment, the picker only shows one component and the options passed in `options`
class ValidationPickerField: ValidationTextField, UIPickerViewDataSource, UIPickerViewDelegate {

    struct PickerItem: Equatable, Identifiable {
        let id: String
        let title: String
    }

    private lazy var pickerView: UIPickerView = {
        var picker = UIPickerView()
        picker.sizeToFit()
        return picker
    }()

    var onSelection: ((PickerItem?) -> Void)?

    var options: [PickerItem] = [] {
        didSet {
            guard options != oldValue else {
                return
            }
            pickerView.reloadAllComponents()
        }
    }

    var selectedOption: PickerItem? {
        didSet {
            guard selectedOption != oldValue else {
                return
            }
            if let newValue = selectedOption, let index = options.lastIndex(of: newValue) {
                pickerView.selectRow(index, inComponent: 0, animated: false)
                pickerView.delegate?.pickerView?(pickerView, didSelectRow: index, inComponent: 0)
            }
            text = selectedOption?.title
            onSelection?(selectedOption)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        pickerView.delegate = self
        pickerView.reloadAllComponents()
        textFieldInputView = pickerView
        validationBlock = { [weak self] _ in
            guard let self else { return .invalid(.unknown) }
            let hasValidData = !options.isEmpty && selectedOption != nil
            let isOptional = optionalField
            let isValid = hasValidData || isOptional
            return isValid ? .valid : .invalid(.invalidSelection)
        }
    }

    // UITextFieldDelegate

    override func textFieldDidEndEditing(_ textField: UITextField) {
        super.textFieldDidEndEditing(textField)
        pickerView.isHidden = true
    }

    override func textFieldDidBeginEditing(_ textField: UITextField) {
        super.textFieldDidBeginEditing(textField)
        pickerView.isHidden = false
        selectedOption = selectedOption ?? options.first
    }

    override func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        false
    }

    // UIPickerViewDataSource

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        options.count
    }

    // UIPickerViewDelegate

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedOption = options[row]
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        options[row].title
    }
}
