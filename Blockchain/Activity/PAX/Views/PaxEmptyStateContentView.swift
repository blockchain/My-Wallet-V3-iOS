//
//  PaxEmptyStateContentView.swift
//  Blockchain
//
//  Created by Jack on 12/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit
import PlatformUIKit

class PaxEmptyStateContentView: UIStackView {
    
    private var iconImageView: UIImageView!
    private var titleLabel: UILabel!
    private var subTitleLabel: UILabel!
    private var learnMoreButton: UIButton!
    
    private var action: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func configure(with viewModel: PaxEmptyStateViewModel) {
        iconImageView.image = viewModel.iconImage
        titleLabel.text = viewModel.title
        subTitleLabel.text = viewModel.subTitle
        
        let buttonFont = Font(
            .branded(.montserratSemiBold),
            size: .custom(14.0)
        ).result
        let buttonAttributedTitle = NSAttributedString(
            string: viewModel.link.text,
            attributes: [
                .font: buttonFont,
                .foregroundColor: UIColor.brandSecondary
            ]
        )
        learnMoreButton.setAttributedTitle(buttonAttributedTitle, for: .normal)
        
        action = viewModel.link.action
    }
    
    private func setup() {
        axis = .vertical
        distribution = .fill
        alignment = .center
        spacing = 12.0
        
        iconImageView = UIImageView()
        addArrangedSubview(iconImageView)
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 49.0),
            iconImageView.heightAnchor.constraint(equalToConstant: 49.0)
            ])
        
        if #available(iOS 11.0, *) {
            setCustomSpacing(24.0, after: iconImageView)
        } else {
            let spacerView = UIView()
            spacerView.backgroundColor = UIColor.clear
            spacerView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                spacerView.widthAnchor.constraint(equalToConstant: 1.0),
                spacerView.heightAnchor.constraint(equalToConstant: 1.0)
                ])
            addArrangedSubview(spacerView)
        }
        
        titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.textColor = .brandPrimary
        titleLabel.font = UIFont(
            name: Constants.FontNames.montserratSemiBold,
            size: Constants.FontSizes.Medium
        )
        addArrangedSubview(titleLabel)
        
        subTitleLabel = UILabel()
        subTitleLabel.numberOfLines = 0
        subTitleLabel.textAlignment = .center
        subTitleLabel.textColor = .gray5
        subTitleLabel.font = UIFont(
            name: Constants.FontNames.montserratSemiBold,
            size: Constants.FontSizes.ExtraExtraSmall
        )
        addArrangedSubview(subTitleLabel)
        
        learnMoreButton = UIButton()
        learnMoreButton.setTitleColor(.brandSecondary, for: .normal)
        learnMoreButton.addTarget(
            self,
            action: #selector(learnMoreAction),
            for: .touchUpInside
        )
        addArrangedSubview(learnMoreButton)
        
        learnMoreButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            learnMoreButton.heightAnchor.constraint(equalToConstant: 44.0)
        ])
    }
    
    @objc func learnMoreAction() {
        action?()
    }
}
