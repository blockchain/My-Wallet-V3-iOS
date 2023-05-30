// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureKYCDomain
import Localization
import PlatformUIKit
import UIKit

class KYCMoreInformationController: KYCBaseViewController {

    @IBOutlet private var labelHeader: UILabel!
    @IBOutlet private var labelSubHeader: UILabel!
    @IBOutlet private var buttonNotNow: UIButton!
    @IBOutlet private var primaryButtonNext: PrimaryButtonContainer!

    // MARK: Factory

    override class func make(with coordinator: KYCRouter) -> KYCMoreInformationController {
        let controller = makeFromStoryboard(in: .module)
        controller.router = coordinator
        controller.pageType = .verifyIdentity
        return controller
    }

    // MARK: View Controller Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.semantic.light
        labelHeader.text = LocalizationConstants.KYC.moreInfoNeededHeaderText
        labelHeader.textColor = UIColor.semantic.title
        labelSubHeader.text = LocalizationConstants.KYC.moreInfoNeededSubHeaderText
        labelSubHeader.textColor = UIColor.semantic.body
        buttonNotNow.setTitle(LocalizationConstants.KYC.notNow, for: .normal)
        primaryButtonNext.actionBlock = { [unowned self] in
            router.handle(event: .nextPageFromPageType(pageType, nil))
        }
    }

    // MARK: IBActions

    @IBAction func onNotNowTapped(_ sender: UIButton) {
        router.finish()
    }
}
