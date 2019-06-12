//
//  PaxEmptyStateView.swift
//  Blockchain
//
//  Created by Jack on 12/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit
import PlatformUIKit

// TODO:
// * This View and accompanying ViewModel can easyly be made generic, ticket:
//   https://blockchain.atlassian.net/browse/IOS-2292

class PaxEmptyStateView: UIView {
    
    private var emptyStateContentView: PaxEmptyStateContentView!
    private var callToActionButton: UIButton!
    
    private var action: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func configure(with viewModel: PaxEmptyStateViewModel) {
        let buttonFont = Font(
            .branded(.montserratSemiBold),
            size: .custom(18.0)
        ).result
        let buttonAttributedTitle = NSAttributedString(
            string: viewModel.ctaButton.title,
            attributes: [
                .font: buttonFont,
                .foregroundColor: UIColor.white
            ]
        )
        callToActionButton.setAttributedTitle(buttonAttributedTitle, for: .normal)
        action = viewModel.ctaButton.action
        emptyStateContentView.configure(with: viewModel)
    }
    
    private func setup() {
        emptyStateContentView = PaxEmptyStateContentView(frame: CGRect.zero)
        emptyStateContentView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateContentView.setContentHuggingPriority(.required, for: .vertical)
        emptyStateContentView.setContentHuggingPriority(.required, for: .horizontal)
        addSubview(emptyStateContentView)
        
        callToActionButton = UIButton()
        callToActionButton.backgroundColor = UIColor.brandSecondary
        callToActionButton.layer.cornerRadius = Constants.Measurements.buttonCornerRadius
        callToActionButton.setTitleColor(.brandSecondary, for: .normal)
        callToActionButton.addTarget(
            self,
            action: #selector(callToActionButtonAction),
            for: .touchUpInside
        )
        callToActionButton.translatesAutoresizingMaskIntoConstraints = false
        callToActionButton.setContentHuggingPriority(.required, for: .vertical)
        callToActionButton.setContentCompressionResistancePriority(.required, for: .vertical)
        callToActionButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        addSubview(callToActionButton)
        
        NSLayoutConstraint.activate([
            emptyStateContentView.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyStateContentView.centerYAnchor.constraint(equalTo: centerYAnchor),
            emptyStateContentView.leadingAnchor.constraint(
                greaterThanOrEqualTo: leadingAnchor,
                constant: 16.0
            ),
            emptyStateContentView.trailingAnchor.constraint(
                lessThanOrEqualTo: trailingAnchor,
                constant: -16.0
            ),
            emptyStateContentView.topAnchor.constraint(
                greaterThanOrEqualTo: topAnchor
            )
        ])
        
        NSLayoutConstraint.activate([
            callToActionButton.heightAnchor.constraint(
                equalToConstant: Constants.Measurements.buttonHeightLarge
            ),
            callToActionButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            callToActionButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            callToActionButton.topAnchor.constraint(
                greaterThanOrEqualTo: emptyStateContentView.bottomAnchor,
                constant: 24.0
            ),
            callToActionButton.bottomAnchor.constraint(
                lessThanOrEqualTo: bottomAnchor
            )
        ])
    }
    
    @objc func callToActionButtonAction() {
        action?()
    }
}
