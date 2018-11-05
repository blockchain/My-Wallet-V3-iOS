//
//  InformationViewController.swift
//  Blockchain
//
//  Created by kevinwu on 11/1/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

typealias InformationViewButtonAction = (UIViewController) -> Void

class InformationViewController: UIViewController {
    @IBOutlet private var textView: UITextView!
    @IBOutlet private var button: UIButton!

    private var bodyAttributedText: NSAttributedString?
    private var buttonTitle: String?
    private var buttonAction: InformationViewButtonAction?

    // MARK: Factory

    static func make(viewModel: InformationViewModel) -> InformationViewController {
        let controller = InformationViewController.makeFromStoryboard()
        controller.bodyAttributedText = viewModel.informationText
        controller.buttonTitle = viewModel.buttonTitle
        controller.buttonAction = viewModel.buttonAction
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.attributedText = bodyAttributedText
        button.setTitle(buttonTitle, for: .normal)
        button.layer.cornerRadius = Constants.Measurements.buttonCornerRadius
    }

    @IBAction private func buttonTapped(_ sender: Any) {
        guard let action = buttonAction else { return }
        action(self)
    }
}

struct InformationViewModel {
    let informationText: NSAttributedString?
    let buttonTitle: String
    let buttonAction: InformationViewButtonAction?
}
