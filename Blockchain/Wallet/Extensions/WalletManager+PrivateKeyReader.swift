//
//  WalletManager+PrivateKeyReader.swift
//  Blockchain
//
//  Created by Maurice A. on 5/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol PrivateKeyReaderDelegate: class {
    func didFinishScanningWithError(_ error: AVCaptureDeviceError)
    func didFinishScanning(_ privateKey: String, for address: AssetAddress)
}

// TODO: move nib file to storyboard
extension WalletManager {

    /// Wallet extension to support private key reading from QR codes
    final class PrivateKeyReader: UIViewController & AVCaptureMetadataOutputObjectsDelegate {

        // MARK: Properties

        private let assetType: AssetType
        private var address: AssetAddress?
        private var captureSession: AVCaptureSession?
        private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
        private var onClose: (() -> Void)?
        private var viewFrame: CGRect {
            guard let window = UIApplication.shared.keyWindow else {
                fatalError("Trying to get key window before it was set!")
            }
            let width = window.bounds.size.width
            let height = window.bounds.size.height - Constants.Measurements.DefaultHeaderHeight
            return CGRect(x: 0, y: 0, width: width, height: height)
        }

        weak var delegate: PrivateKeyReaderDelegate?

        //: Not private so that the same PrivateKeyReader instance can be reused to scan public keys
        var acceptPublicKeys: Bool!

        // MARK: - Initialization

        init(assetType: AssetType = .bitcoin, acceptPublicKeys: Bool = false) {
            self.assetType = assetType
            delegate = nil; captureSession = nil; videoPreviewLayer = nil
            super.init(nibName: nil, bundle: nil)
            self.modalTransitionStyle = .crossDissolve
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // TODO: setup UI in storyboard
        override func viewDidLoad() {
            super.viewDidLoad()

            self.view.frame = viewFrame

            let topBar = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: Constants.Measurements.DefaultHeaderHeight))
            topBar.backgroundColor = Constants.Colors.BlockchainBlue
            self.view.addSubview(topBar)

            let headerLabel = UILabel(frame: CGRect(x: 60, y: 26, width: 200, height: 30))
            headerLabel.font = UIFont(name: Constants.FontNames.montserratRegular, size: Constants.FontSizes.ExtraExtraLarge)
            headerLabel.textColor = UIColor.white
            headerLabel.textAlignment = .center
            headerLabel.adjustsFontSizeToFitWidth = true
            headerLabel.text = LocalizationConstants.scanQRCode
            headerLabel.center = CGPoint(x: topBar.center.x, y: headerLabel.center.y)
            topBar.addSubview(headerLabel)

            let closeButton = UIButton(frame: CGRect(x: self.view.frame.size.width - 80, y: 15, width: 80, height: 51))
            closeButton.imageEdgeInsets = UIEdgeInsets(top: 3, left: 0, bottom: 0, right: 18)
            closeButton.contentHorizontalAlignment = .right
            closeButton.setImage(UIImage(named: "close"), for: .normal)
            closeButton.center = CGPoint(x: closeButton.center.x, y: headerLabel.center.y)
            closeButton.addTarget(self, action: #selector(closeButtonClicked(sender:)), for: .touchUpInside)
            topBar.addSubview(closeButton)
        }

        // MARK: - Private Methods

        @objc private func closeButtonClicked(sender: AnyObject) {
            stopReadingQRCode()
        }

        // MARK: Class Methods

        func startReadingQRCode(for address: AssetAddress) {
            self.address = address
            do {
                let input = try AVCaptureDeviceInput.deviceInputForQRScanner()
                captureSession = AVCaptureSession()
                captureSession?.addInput(input)
            } catch {
                captureSession = nil
                AlertViewPresenter.shared.standardError(message: error.localizedDescription)
                return
            }

            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)

            let queue = DispatchQueue(label: "captureQueue")
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: queue)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]

            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = .resizeAspectFill
            let frame = CGRect(x: viewFrame.origin.x, y: Constants.Measurements.DefaultHeaderHeight, width: viewFrame.width, height: viewFrame.height)
            videoPreviewLayer?.frame = frame
            self.view.layer.addSublayer(videoPreviewLayer!)

            captureSession?.startRunning()
        }

        func stopReadingQRCode() {
            captureSession?.stopRunning()
            videoPreviewLayer?.removeFromSuperlayer()
            self.dismiss(animated: true) {
                guard let handler = self.onClose else { return }
                handler()
            }
        }

        // MARK: - AVCaptureMetadataOutputObjectsDelegate

        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            guard
                let address = address,
                !metadataObjects.isEmpty,
                let metadataObject = metadataObjects.first,
                metadataObject.type == .qr else {
                    return
            }

            DispatchQueue.main.async {
                self.stopReadingQRCode()
                // TODO: check if the busy text needs to be an argument
                LoadingViewPresenter.shared.showBusyView(withLoadingText: LocalizationConstants.AddressAndKeyImport.loadingImportKey)
            }

            let deadlineTime = DispatchTime.now() + Constants.Animation.duration
            DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                let objectDescription = metadataObject.description
                var scannedKey: String? = nil

                if objectDescription.hasPrefix(Constants.Prefixes.bitcoin) {
                    let startIndex = objectDescription.index(objectDescription.startIndex, offsetBy: Constants.Prefixes.bitcoin.count)
                    let description = String(objectDescription[startIndex...])
                    scannedKey = description
                }

                guard let privateKey = scannedKey else {
                    self.onClose = {
                        AlertViewPresenter.shared.standardError(message: LocalizationConstants.AddressAndKeyImport.unknownKeyFormat)
                    }
                    return
                }

                guard let format = shared.wallet.detectPrivateKeyFormat(address.description), format.count > 0 else {
                    LoadingViewPresenter.shared.hideBusyView()
                    if self.acceptPublicKeys {
                        KeyImporter.shared.askUserToAddWatchOnlyAddress(address) {
                            self.delegate?.didFinishScanning(privateKey, for: address)
                        }
                    } else {
                        self.onClose = {
                            AlertViewPresenter.shared.standardError(message: LocalizationConstants.AddressAndKeyImport.unsupportedPrivateKey)
                        }
                    }
                    return
                }
                //: Pass valid address back via success handler
                self.delegate?.didFinishScanning(privateKey, for: address)
            }
        }
    }
}
