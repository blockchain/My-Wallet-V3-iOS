//
//  KYCPersonalDetailsController.swift
//  Blockchain
//
//  Created by Maurice A. on 7/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

/// Personal details entry screen in KYC flow
final class KYCPersonalDetailsController: UIViewController {

    // MARK: - Properties

    private let birthdatePicker: UIDatePicker!

    // MARK: - IBOutlets

    @IBOutlet private var firstNameField: UITextField!
    @IBOutlet private var lastNameField: UITextField!
    @IBOutlet private var birthdateField: UITextField!
    @IBOutlet var primaryButton: PrimaryButton!

    override func viewDidLoad() {
        setUpBirthdatePicker()
        birthdateField.inputView = birthdatePicker
    }

    required init?(coder aDecoder: NSCoder) {
        birthdatePicker = UIDatePicker()
        birthdatePicker.datePickerMode = .date
        birthdatePicker.maximumDate = Date()
        super.init(coder: aDecoder)
    }

    // MARK: - Private Methods

    private func setUpBirthdatePicker() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(submitBirthdate))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(hideBirthdatePicker))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        birthdateField.inputAccessoryView = toolBar
    }

    @objc private func submitBirthdate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        birthdateField.text = dateFormatter.string(from: birthdatePicker.date)
        birthdateField.resignFirstResponder()
    }

    @objc private func hideBirthdatePicker() {
        birthdateField.resignFirstResponder()
    }

    // MARK: - Actions

    @IBAction func primaryButtonTapped(_ sender: Any) {
        let dateOfBirth = birthdatePicker.date
        let calendar = Calendar(identifier: .gregorian)
        let age = calendar.dateComponents([.year], from: dateOfBirth, to: Date())
        guard let year = age.year, year >= 18 else {
            AlertViewPresenter.shared.standardNotify(
                message: "You must be at least 18 years old to have your identity verified",
                title: "A bit too young",
                actions: [
                    UIAlertAction(title: "OK, I understand", style: .default, handler: { _ in
                        // TODO: exit KYC flow and send user back to dashboard
                    })
                ],
                in: self
            )
            return
        }
        performSegue(withIdentifier: "enterMobileNumber", sender: self)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let enterPhoneNumberController = segue.destination as? KYCEnterPhoneNumberController else {
            return
        }
        // TODO: pass in actual userID
        enterPhoneNumberController.userId = "userId"
    }
}

extension KYCPersonalDetailsController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case firstNameField: lastNameField.becomeFirstResponder()
        case lastNameField: birthdateField.becomeFirstResponder()
        default: return false
        }
        return false
    }
}
