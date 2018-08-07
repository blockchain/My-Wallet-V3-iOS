//
//  KYCPersonalDetailsController.swift
//  Blockchain
//
//  Created by Maurice A. on 7/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

/// Personal details entry screen in KYC flow
final class KYCPersonalDetailsController: UIViewController, ValidationFormView, ProgressableView {

    var barColor: UIColor = .green
    var startingValue: Float = 0.14

    // MARK: - Public IBOutlets

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var progressView: UIProgressView!

    // MARK: - IBOutlets

    @IBOutlet fileprivate var firstNameField: ValidationTextField!
    @IBOutlet fileprivate var lastNameField: ValidationTextField!
    @IBOutlet fileprivate var birthdayField: ValidationDateField!
    @IBOutlet fileprivate var primaryButton: PrimaryButton!

    // MARK: Public Properties

    var validationFields: [ValidationTextField] {
        get {
            return [firstNameField,
                    lastNameField,
                    birthdayField]
        }
    }

    var keyboard: KeyboardPayload? = nil

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTextFields()
        handleKeyboardOffset()
        setupNotifications()
        setupProgressView()

        validationFields.enumerated().forEach { (index, field) in
            field.returnTappedBlock = { [weak self] in
                guard let this = self else { return }
                this.updateProgress(this.progression())
                guard this.validationFields.count > index + 1 else {
                    field.resignFocus()
                    return
                }
                let next = this.validationFields[index + 1]
                next.becomeFocused()
            }
        }
    }

    // MARK: - Private Methods

    fileprivate func setupTextFields() {
        firstNameField.returnKeyType = .next
        firstNameField.contentType = .name

        lastNameField.returnKeyType = .next
        lastNameField.contentType = .familyName

        birthdayField.validationBlock = { value in
            guard let birthday = value else { return .invalid(nil) }
            guard let date = DateFormatter.birthday.date(from: birthday) else { return .invalid(nil) }
            if date <= Date.eighteenYears {
                return .valid
            } else {
                return .invalid(.minimumDateRequirement)
            }
        }
    }

    fileprivate func setupNotifications() {
        NotificationCenter.when(.UIKeyboardWillHide) { [weak self] _ in
            self?.scrollView.contentInset = .zero
            self?.scrollView.setContentOffset(.zero, animated: true)
        }
        NotificationCenter.when(.UIKeyboardWillShow) { [weak self] notification in
            let keyboard = KeyboardPayload(notification: notification)
            self?.keyboard = keyboard
        }
    }

    fileprivate func progression() -> Float {
        let newProgression: Float = validationFields.map({
            return $0.validate() == .valid ? 0.14 : 0.0
        }).reduce(startingValue, +)
        return max(newProgression, startingValue)
    }

    // MARK: - Actions

    @IBAction func primaryButtonTapped(_ sender: Any) {
        guard checkFieldsValidity() else { return }
        performSegue(withIdentifier: "enterMobileNumber", sender: self)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {}
}

extension KYCPersonalDetailsController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // TODO: May not be necessary. 
        validationFields.forEach({$0.resignFocus()})
    }
}

extension Date {
    static let eighteenYears: Date = Calendar.current.date(
        byAdding: .year,
        value: -18,
        to: Date()) ?? Date()
}
