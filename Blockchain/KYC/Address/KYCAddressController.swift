//
//  KYCAddressController.swift
//  Blockchain
//
//  Created by Maurice A. on 7/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

class KYCAddressController: UIViewController {

    // MARK: - Private IBOutlets

    @IBOutlet fileprivate var textFieldSeparator: UIView!
    @IBOutlet fileprivate var addressTextField: UITextField!
    @IBOutlet fileprivate var tableView: UITableView!
    @IBOutlet fileprivate var activityIndicator: UIActivityIndicatorView!

    // MARK: - Public IBOutlets

    @IBOutlet var primaryButton: PrimaryButton!

    // MARK: - KYCOnboardingNavigation

    weak var searchDelegate: SearchControllerDelegate?
    var segueIdentifier: String? = "showPersonalDetails"

    // MARK: Private Properties

    fileprivate var coordinator: LocationSuggestionCoordinator!
    fileprivate var dataProvider: LocationDataProvider!

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        textFieldSeparator.backgroundColor = .gray1
        coordinator = LocationSuggestionCoordinator(self, interface: self)
        dataProvider = LocationDataProvider(with: tableView)
        addressTextField.delegate = self
        tableView.delegate = self

        addressTextField.placeholder = "Enter Address"

        searchDelegate?.onStart()
    }

    // MARK: - Actions

    @IBAction func primaryButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "showPersonalDetails", sender: self)
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
        addressTextField.resignFirstResponder()
    }
}

extension KYCAddressController: LocationSuggestionInterface {
    func updateActivityIndicator(_ visibility: Visibility) {
        visibility == .hidden ? activityIndicator.stopAnimating() : activityIndicator.startAnimating()
    }


    func primaryButton(_ visibility: Visibility) {
        primaryButton.alpha = visibility.defaultAlpha
    }

    func suggestionsList(_ visibility: Visibility) {
        tableView.alpha = visibility.defaultAlpha
    }

    func searchFieldActive(_ isFirstResponder: Bool) {
        switch isFirstResponder {
        case true:
            addressTextField.becomeFirstResponder()
        case false:
            addressTextField.resignFirstResponder()
        }
    }

    func searchFieldText(_ value: String?) {
        addressTextField.text = value
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

extension KYCAddressController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let value = textField.text as NSString? {
            let current = value.replacingCharacters(in: range, with: string)
            searchDelegate?.onSearchRequest(current)
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), text.isEmpty == false else {
            return false
        }

        searchDelegate?.onSearchRequest(text)
        textField.resignFirstResponder()
        return true
    }
}
