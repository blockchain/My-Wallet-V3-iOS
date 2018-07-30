//
//  KYCCountrySelectionController.swift
//  Blockchain
//
//  Created by Maurice A. on 7/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

/// Country selection screen in KYC flow
final class KYCCountrySelectionController: UIViewController, KYCOnboardingNavigation {

    // MARK: - Properties

    var segueIdentifier: String? = "promptForContactDetails"

    // MARK: - IBOutlets

    @IBOutlet fileprivate var countryPicker: UIPickerView!
    @IBOutlet var primaryButton: PrimaryButton!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        countryPicker.dataSource = KYCCountrySelectionDataSource.dataSource
        navigationItem.title = NSLocalizedString(
            "Select Your Country",
            comment: "The title of the navigation item in the country selection screen."
        )
    }

    // MARK: - Actions

    @IBAction func primaryButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: segueIdentifier!, sender: self)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // TODO: implement method body
    }
}

// MARK: - UIPickerViewDelegate
extension KYCCountrySelectionController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // TODO: implement method body
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let dataSource = countryPicker.dataSource as? KYCCountrySelectionDataSource,
            let country = dataSource.countries?[row].name else {
                return nil
        }
        return country
    }
}
