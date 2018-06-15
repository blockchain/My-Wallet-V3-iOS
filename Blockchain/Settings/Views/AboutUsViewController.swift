//
//  AboutUsViewController.swift
//  Blockchain
//
//  Created by Chris Arriola on 6/15/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@objc class AboutUsViewController: UIViewController {
    @IBOutlet weak var buttonClose: UIButton!
    @IBOutlet weak var labelMain: UILabel!
    @IBOutlet weak var buttonRateUs: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.shared.statusBarStyle = .default

        labelMain.font = UIFont(
            name: Constants.FontNames.montserratRegular,
            size: Constants.FontSizes.Medium)
        labelMain.textColor = Constants.Colors.ColorBrandPrimary
        labelMain.text = """
            Blockchain Wallet \(Bundle.applicationVersion ?? "")
            © 2018 Blockchain Luxembourg S.A.
            \(LocalizationConstants.Settings.allRightsReserved)
        """

        buttonRateUs.setTitleColor(Constants.Colors.ColorBrandPrimary, for: .normal)

        let closeImage = UIImage(named: "close")?.withRenderingMode(.alwaysTemplate)
        buttonClose.setImage(closeImage, for: .normal)
        buttonClose.imageView?.tintColor = Constants.Colors.ColorBrandPrimary
    }

    @IBAction func onCloseTapped(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction func onRateUsTapped(_ sender: Any) {
        UIApplication.shared.rateApp()
    }
}

extension AboutUsViewController {
    /// Presents a new instance of `AboutUsViewController` in `viewController`.
    ///
    /// - Parameter viewController: the UIViewController to present in
    @objc static func present(in viewController: UIViewController) {
        let storyboard = UIStoryboard(name: "AboutUsView", bundle: nil)
        let aboutUsViewController = storyboard.instantiateInitialViewController() as! AboutUsViewController
        viewController.present(aboutUsViewController, animated: true)
    }
}
