//
//  KYCPersonalDetailsController.swift
//  Blockchain
//
//  Created by Maurice A. on 7/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

/// Personal details entry screen in KYC flow
final class KYCPersonalDetailsController: KYCBaseViewController, ValidationFormView, ProgressableView {

    // MARK: - ProgressableView

    var barColor: UIColor = .green
    var startingValue: Float = 0.14

    @IBOutlet var progressView: UIProgressView!

    // MARK: - IBOutlets

    @IBOutlet fileprivate var firstNameField: ValidationTextField!
    @IBOutlet fileprivate var lastNameField: ValidationTextField!
    @IBOutlet fileprivate var birthdayField: ValidationDateField!
    @IBOutlet fileprivate var primaryButtonContainer: PrimaryButtonContainer!

    // MARK: ValidationFormView

    @IBOutlet var scrollView: UIScrollView!

    var validationFields: [ValidationTextField] {
        get {
            return [firstNameField,
                    lastNameField,
                    birthdayField]
        }
    }

    var keyboard: KeyboardPayload? = nil

    // MARK: Public Properties

    weak var delegate: PersonalDetailsDelegate?

    // MARK: Private Properties

    fileprivate var detailsCoordinator: PersonalDetailsCoordinator!

    // MARK: Overrides

    override class func make(with coordinator: KYCCoordinator) -> KYCPersonalDetailsController {
        let storyboard = UIStoryboard(name: "KYCPersonalDetails", bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as! KYCPersonalDetailsController
        controller.coordinator = coordinator
        controller.pageType = .profile
        return controller
    }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        detailsCoordinator = PersonalDetailsCoordinator(interface: self)
        setupTextFields()
        handleKeyboardOffset()
        setupNotifications()
        setupProgressView()

        primaryButtonContainer.actionBlock = { [weak self] in
            guard let this = self else { return }
            this.primaryButtonTapped()
        }

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

        delegate?.onStart()
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

    fileprivate func primaryButtonTapped() {
        guard checkFieldsValidity() else { return }
        guard let email = WalletManager.shared.wallet.getEmail() else { return }
        validationFields.forEach({$0.resignFocus()})

        guard let details = PersonalDetails(
            id: "",
            first: firstNameField.text,
            last: lastNameField.text,
            email: email,
            birthday: birthdayField.selectedDate
            ) else { return }
        
        delegate?.onSubmission(details)
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

extension KYCPersonalDetailsController: PersonalDetailsInterface {
    func primaryButtonActivityIndicator(_ visibility: Visibility) {
        primaryButtonContainer.isLoading = visibility == .visible
    }

    func primaryButtonEnabled(_ enabled: Bool) {
        primaryButtonContainer.isEnabled = enabled
    }

    func nextPage() {
        performSegue(withIdentifier: "enterMobileNumber", sender: self)
    }

    func populatePersonalDetailFields(_ details: PersonalDetails) {
        firstNameField.text = details.firstName
        lastNameField.text = details.lastName
        let birthday = DateFormatter.birthday.string(from: details.birthday)
        birthdayField.text = birthday
    }
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
