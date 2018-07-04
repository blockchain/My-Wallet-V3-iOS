//
//  SwipeToReceiveAddressView.swift
//  Blockchain
//
//  Created by Chris Arriola on 6/19/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

@objc class SwipeToReceiveAddressView: UIView {

    @IBOutlet private weak var imageViewAsset: UIImageView!
    @IBOutlet private weak var buttonRequest: UIButton!
    @IBOutlet private weak var imageViewQRCode: UIImageView!
    @IBOutlet private weak var labelAddress: UILabel!

    @objc var onRequestAssetTapped: ((String) -> Void)?

    @objc var viewModel: BCSwipeAddressViewModel? {
        didSet {
            guard let viewModel = viewModel else {
                imageViewAsset.image = nil
                buttonRequest.setTitle("", for: .normal)
                return
            }
            imageViewAsset.image = UIImage(named: viewModel.assetImageViewName)?.withRenderingMode(.alwaysTemplate)
            buttonRequest.setTitle(viewModel.action, for: .normal)
            labelAddress.text = viewModel.address
            updateQRCodeAndLabel()
        }
    }

    @objc var address: String? {
        get {
            return viewModel?.address
        }
        set {
            viewModel?.address = newValue
            updateQRCodeAndLabel()
        }
    }

    @objc var pageIndicatorYOrigin: CGFloat {
        return self.buttonRequest.frame.size.height + self.buttonRequest.frame.origin.y + 16
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        imageViewAsset.tintColor = Constants.Colors.ColorGray5

        buttonRequest.titleLabel?.font = UIFont(
            name: Constants.FontNames.montserratLight,
            size: Constants.FontSizes.Small
        )
        buttonRequest.layer.borderWidth = 1.0
        buttonRequest.layer.borderColor = Constants.Colors.ColorBrandSecondary.cgColor
        buttonRequest.layer.cornerRadius = 8.0
        buttonRequest.backgroundColor = Constants.Colors.ColorBrandQuaternary
        buttonRequest.setTitleColor(Constants.Colors.ColorBrandSecondary, for: .normal)

        labelAddress.textColor = Constants.Colors.ColorGray5
        labelAddress.font = UIFont(
            name: Constants.FontNames.montserratRegular,
            size: Constants.FontSizes.ExtraSmall
        )
    }

    @IBAction func onRequestButtonTapped(_ sender: Any) {
        guard let address = address else {
            return
        }
        onRequestAssetTapped?(address)
    }

    private func updateQRCodeAndLabel() {
        guard let viewModel = viewModel, let address = address else {
            imageViewQRCode.isHidden = true
            labelAddress.text = LocalizationConstants.SwipeToReceive.pleaseLoginToLoadMoreAddresses
            return
        }

        guard address != LocalizationConstants.Errors.requestFailedCheckConnection else {
            imageViewQRCode.isHidden = true
            labelAddress.text = address
            return
        }

        let qrCodeGenerator = QRCodeGenerator()
        imageViewQRCode.isHidden = false
        imageViewQRCode.image = viewModel.assetType == .bitcoin ?
            qrCodeGenerator.qrImage(fromAddress: address) :
            qrCodeGenerator.createQRImage(from: address)
        labelAddress.text = viewModel.textAddress
    }
}

extension SwipeToReceiveAddressView {
    @objc static func instanceFromNib() -> SwipeToReceiveAddressView {
        let nib = UINib(nibName: "SwipeToReceiveAddressView", bundle: Bundle.main)
        let contents = nib.instantiate(withOwner: nil, options: nil)
        return contents.first { $0 is SwipeToReceiveAddressView } as! SwipeToReceiveAddressView
    }
}
