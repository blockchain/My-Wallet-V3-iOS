//
//  KYCAddressController.swift
//  Blockchain
//
//  Created by Maurice A. on 7/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

class KYCAddressController: UIViewController, KYCOnboardingNavigation {

    // MARK: - Private IBOutlets

    @IBOutlet fileprivate var scrollView: UIScrollView!
    @IBOutlet fileprivate var progressView: UIProgressView!
    @IBOutlet fileprivate var searchBar: UISearchBar!
    @IBOutlet fileprivate var tableView: UITableView!
    @IBOutlet fileprivate var activityIndicator: UIActivityIndicatorView!

    // MARK: Private IBOutlets (ValidationTextField)
    @IBOutlet fileprivate var validationFields: [ValidationTextField]!
    @IBOutlet fileprivate var addressTextField: ValidationTextField!
    @IBOutlet fileprivate var apartmentTextField: ValidationTextField!
    @IBOutlet fileprivate var cityTextField: ValidationTextField!
    @IBOutlet fileprivate var stateTextField: ValidationTextField!
    @IBOutlet fileprivate var postalCodeTextField: ValidationTextField!
    @IBOutlet fileprivate var countryTextField: ValidationTextField!

    // MARK: - Public IBOutlets

    @IBOutlet var primaryButton: PrimaryButton!

    // MARK: - KYCOnboardingNavigation

    weak var searchDelegate: SearchControllerDelegate?
    var segueIdentifier: String? = "showPersonalDetails"

    // MARK: Private Properties
    
    fileprivate var coordinator: LocationSuggestionCoordinator!
    fileprivate var dataProvider: LocationDataProvider!
    fileprivate var keyboard: KeyboardPayload? = nil

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        coordinator = LocationSuggestionCoordinator(self, interface: self)
        dataProvider = LocationDataProvider(with: tableView)
        searchBar.delegate = self
        tableView.delegate = self

        searchBar.barTintColor = .clear

        // TODO: Localize
        searchBar.placeholder = "Your Home Address"
        progressView.tintColor = UIColor.green

        validationFieldsSetup()
        setupNotifications()

        searchDelegate?.onStart()
    }

    fileprivate func validationFieldsSetup() {
        addressTextField.returnKeyType = .next
        apartmentTextField.returnKeyType = .next
        cityTextField.returnKeyType = .next
        stateTextField.returnKeyType = .next
        postalCodeTextField.returnKeyType = .next
        countryTextField.returnKeyType = .done

        addressTextField.validationBlock = { (value) in
            guard value != nil, value?.count != 0 else { return .invalid(nil) }
            return .valid
        }

        addressTextField.returnTappedBlock = { [weak self] in
            self?.apartmentTextField.becomeFocused()
        }
        apartmentTextField.returnTappedBlock = { [weak self] in
            self?.cityTextField.becomeFocused()
        }
        cityTextField.returnTappedBlock = { [weak self] in
            self?.stateTextField.becomeFocused()
        }
        stateTextField.returnTappedBlock = { [weak self] in
            self?.postalCodeTextField.becomeFocused()
        }
        postalCodeTextField.returnTappedBlock = { [weak self] in
            self?.countryTextField.becomeFocused()
        }

        validationFields.forEach { (field) in
            field.becomeFirstResponderBlock = { [weak self] (validationField) in
                guard let this = self else { return }
                guard let keyboardHeight = this.keyboard?.endingFrame.height else { return }
                let insets = UIEdgeInsets(
                    top: 0.0,
                    left: 0.0,
                    bottom: keyboardHeight,
                    right: 0.0
                )
                this.scrollView.contentInset = insets

                let viewSize = CGSize(
                    width: this.scrollView.frame.width,
                    height: this.scrollView.frame.height - keyboardHeight
                )
                let viewableFrame = CGRect(
                    origin: this.scrollView.frame.origin,
                    size: viewSize
                )

                if !viewableFrame.contains(validationField.frame.origin) {
                    this.scrollView.scrollRectToVisible(
                        validationField.frame,
                        animated: true
                    )
                }
            }
        }
    }

    fileprivate func setupNotifications() {
        NotificationCenter.when(NSNotification.Name.UIKeyboardWillHide) { [weak self] _ in
            self?.scrollView.contentInset = .zero
            self?.scrollView.setContentOffset(.zero, animated: true)
        }
        NotificationCenter.when(NSNotification.Name.UIKeyboardWillShow) { [weak self] notification in
            let keyboard = KeyboardPayload(notification: notification)
            self?.keyboard = keyboard
        }
    }

    // MARK: - Actions

    @IBAction func primaryButtonTapped(_ sender: Any) {
        guard let identifier = segueIdentifier else { return }
        performSegue(withIdentifier: identifier, sender: self)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // TODO: implement method body
    }
}

extension KYCAddressController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selection = dataProvider.locationResult.suggestions[indexPath.row]
        coordinator.onSelection(selection)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
}

extension KYCAddressController: LocationSuggestionInterface {
    func addressEntryView(_ visibility: Visibility) {
        scrollView.alpha = visibility.defaultAlpha
    }

    func populateAddressEntryView(_ address: PostalAddress) {
        addressTextField.text = "\(address.street ?? "") \(address.streetNumber ?? "")"
        cityTextField.text = address.city
        stateTextField.text = address.state
        postalCodeTextField.text = address.postalCode
        countryTextField.text = address.country
    }

    func updateActivityIndicator(_ visibility: Visibility) {
        visibility == .hidden ? activityIndicator.stopAnimating() : activityIndicator.startAnimating()
    }

    func primaryButton(_ visibility: Visibility) {
        primaryButton.isEnabled = !visibility.isHidden
    }

    func suggestionsList(_ visibility: Visibility) {
        tableView.alpha = visibility.defaultAlpha
    }

    func searchFieldActive(_ isFirstResponder: Bool) {
        switch isFirstResponder {
        case true:
            searchBar.becomeFirstResponder()
        case false:
            searchBar.resignFirstResponder()
        }
    }

    func searchFieldText(_ value: String?) {
        searchBar.text = value
    }
}

extension KYCAddressController: LocationSuggestionCoordinatorDelegate {
    func coordinator(_ locationCoordinator: LocationSuggestionCoordinator, generated address: PostalAddress) {
        let detailController = KYCAddressDetailViewController.make(address)
        navigationController?.pushViewController(detailController, animated: true)
    }

    func coordinator(_ locationCoordinator: LocationSuggestionCoordinator, updated model: LocationSearchResult) {
        dataProvider.locationResult = model
    }
}

extension KYCAddressController: UISearchBarDelegate {

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }

    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        return true
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchDelegate?.onStart()
        scrollView.setContentOffset(.zero, animated: true)
    }

    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let value = searchBar.text as NSString? {
            let current = value.replacingCharacters(in: range, with: text)
            searchDelegate?.onSearchRequest(current)
        }
        return true
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let value = searchBar.text {
            searchDelegate?.onSearchRequest(value)
        }
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension KYCAddressController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        validationFields.forEach({$0.resignFocus()})
    }
}
