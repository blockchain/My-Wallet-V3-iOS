//
//  KYCApplicationCompleteController.swift
//  Blockchain
//
//  Created by Maurice A. on 8/23/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

final class KYCApplicationCompleteController: KYCBaseViewController, ProgressableView {

    // MARK: - ProgressableView

    @IBOutlet var progressView: UIProgressView!
    var barColor: UIColor = .green
    var startingValue: Float = 1.0

    override class func make(with coordinator: KYCCoordinator) -> KYCApplicationCompleteController {
        let controller = makeFromStoryboard()
        controller.coordinator = coordinator
        controller.pageType = .applicationComplete
        return controller
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupProgressView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        BlockchainSettings.App.shared.shouldShowKYCAnnouncementCard = false
    }

    // MARK: - IBActions

    @IBAction private func primaryButtonTapped(_ sender: Any) {
        coordinator.presentAccountStatusView(for: .pending, in: self)
    }
}
