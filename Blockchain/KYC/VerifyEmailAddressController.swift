//
//  VerifyEmailAddressController.swift
//  BlockchainKYC
//
//  Created by Maurice A. on 7/19/18.
//  Copyright © 2018 Blockchain. All rights reserved.
//

import UIKit

class VerifyEmailAddressController: UIViewController & OnboardingNavigation {

    // MARK: - Properties

    var segueIdentifier: String? = "verifyPhoneNumber"

    @IBOutlet var primaryButton: PrimaryButton!

    @IBAction func primaryButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: segueIdentifier!, sender: self)
    }


    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
