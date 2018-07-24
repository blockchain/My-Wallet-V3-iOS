//
//  KYCCountrySelectionController.swift
//  Blockchain
//
//  Created by Maurice A. on 7/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

/// Country selection screen in KYC flow
class KYCCountrySelectionController: UIViewController, KYCOnboardingNavigation {

    // MARK: - Properties

    var segueIdentifier: String? = "promptForContactDetails"
    var countries: [String]?

    // MARK: - IBOutlets

    @IBOutlet var countryPicker: UIPickerView!
    @IBOutlet var primaryButton: PrimaryButton!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Select Your Country"
    }

    // MARK: - Actions

    @IBAction func primaryButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: segueIdentifier!, sender: self)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}

// MARK: - UIPickerViewDataSource
extension KYCCountrySelectionController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 0
    }
}

// MARK: - UIPickerViewDelegate
extension KYCCountrySelectionController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return nil
    }
}
