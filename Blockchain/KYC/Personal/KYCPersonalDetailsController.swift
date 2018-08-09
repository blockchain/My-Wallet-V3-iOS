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

    // MARK: - ProgressableView

    var barColor: UIColor = .green
    var startingValue: Float = 0.14

    @IBOutlet var progressView: UIProgressView!

    // MARK: - IBOutlets

    @IBOutlet fileprivate var firstNameField: ValidationTextField!
    @IBOutlet fileprivate var lastNameField: ValidationTextField!
    @IBOutlet fileprivate var birthdayField: ValidationDateField!
    @IBOutlet fileprivate var primaryButton: PrimaryButton!

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

    fileprivate var coordinator: PersonalDetailsCoordinator!
    fileprivate var nextBarButton: UIBarButtonItem!
    fileprivate var barButtonActivityIndicator: UIActivityIndicatorView!

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        coordinator = PersonalDetailsCoordinator(interface: self)
        setupTextFields()
        handleKeyboardOffset()
        setupNotifications()
        setupProgressView()

        nextBarButton = UIBarButtonItem(
            title: "Next",
            style: .plain,
            target: self,
            action: #selector(primaryButtonTapped(_:))
        )

        nextBarButton.tintColor = .white
        navigationItem.rightBarButtonItem = nextBarButton

        barButtonActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)

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

    // MARK: - Actions

    @IBAction func primaryButtonTapped(_ sender: Any) {
        guard checkFieldsValidity() else { return }
        guard let email = WalletManager.shared.wallet.getEmail() else { return }

        let details = PersonalDetails(
            identifier: "",
            firstName: firstNameField.text ?? "",
            lastName: lastNameField.text ?? "",
            email: email,
            birthday: birthdayField.selectedDate
        )
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
    func primaryButtonEnabled(_ enabled: Bool) {
        primaryButton.isEnabled = enabled
    }

    func nextPage() {
        performSegue(withIdentifier: "enterMobileNumber", sender: self)
    }

    func rightBarButton(_ visibility: Visibility) {
        switch visibility {
        case .hidden:
            navigationItem.rightBarButtonItem = nil
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: barButtonActivityIndicator)
        case .visible:
            navigationItem.rightBarButtonItem = nextBarButton
        }
    }

    func updateBarButtonActivityIndicator(_ visibility: Visibility) {
        scrollView.isUserInteractionEnabled = visibility == .hidden
        guard navigationItem.rightBarButtonItem != nextBarButton else { return }
        switch visibility {
        case .visible:
            barButtonActivityIndicator.startAnimating()
        case .hidden:
            barButtonActivityIndicator.stopAnimating()
        }
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
