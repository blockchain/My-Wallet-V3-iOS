//
//  CountrySelectionController.swift
//  Blockchain
//
//  Created by Maurice A. on 7/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

/// Country selection screen in KYC flow
open class CountrySelectionController: UIViewController & OnboardingNavigation {

    // MARK: - Properties

    public var segueIdentifier: String? = "promptForContactDetails"
    var countries: [String]?

    // MARK: - IBOutlets

    @IBOutlet var countryPicker: UIPickerView!
    @IBOutlet public var primaryButton: PrimaryButton!

    // MARK: - View Lifecycle

    override open func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Select Your Country"
    }

    // MARK: - Actions

    @IBAction public func primaryButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: segueIdentifier!, sender: self)
    }

    // MARK: - Navigation

    override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}

// MARK: - UIPickerViewDataSource
extension CountrySelectionController: UIPickerViewDataSource {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 0
    }
}

// MARK: - UIPickerViewDelegate
extension CountrySelectionController: UIPickerViewDelegate {
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

    }

    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return nil
    }
}
