//
//  PrivateKeyReader.swift
//  Blockchain
//
//  Created by Maurice A. on 5/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol PrivateKeyReaderDelegate: class {
    func didFinishScanning(_ privateKey: String, for address: AssetAddress?)
    func didFinishScanningWithError(_ error: PrivateKeyReaderError)
}

// TODO: remove once AccountsAndAddresses and SendBitcoinViewController are migrated to Swift
@objc protocol LegacyPrivateKeyDelegate: class {
    func didFinishScanning(_ privateKey: String)
    func didFinishScanningWithError(_ error: PrivateKeyReaderError)
}

@objc enum PrivateKeyReaderError: Int {
    case badMetadataObject
    case unknownKeyFormat
    case unsupportedPrivateKey
}

@objc
final class PrivateKeyReader: UIViewController & AVCaptureMetadataOutputObjectsDelegate {

    // MARK: Properties

    private let assetType: AssetType?

    //: Temporary bridging asset type
    @objc private let legacyAssetType: LegacyAssetType
    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var viewFrame: CGRect {
        guard let window = UIApplication.shared.keyWindow else {
            fatalError("Trying to get key window before it was set!")
        }
        let width = window.bounds.size.width
        let height = window.bounds.size.height - Constants.Measurements.DefaultHeaderHeight
        return CGRect(x: 0, y: 0, width: width, height: height)
    }

    weak var delegate: PrivateKeyReaderDelegate?

    //: Legacy Objc delegate to support Legacy asset types
    @objc weak var legacyDelegate: LegacyPrivateKeyDelegate?

    @objc var acceptPublicKeys = false

    @objc var publicKey: String?

    @objc var loadingText: String

    // MARK: - Initialization

    /// - Parameters:
    ///   - assetType: the asset type used in the key import context
    ///   - publicKey: the public key used for scanning the respective private key
    init?(assetType: AssetType, publicKey: String? = nil) {
        self.assetType = assetType
        legacyAssetType = LegacyAssetType.bitcoin
        self.publicKey = publicKey
        loadingText = LocalizationConstants.AddressAndKeyImport.loadingImportKey
        super.init(nibName: nil, bundle: nil)
        self.modalTransitionStyle = .crossDissolve
        guard let deviceInput = getDeviceInput() else { return nil }
        captureSession = AVCaptureSession()
        captureSession?.addInput(deviceInput)
    }

    // TODO: remove once AccountsAndAddresses and SendBitcoinViewController are migrated to Swift
    @objc init?(assetType: LegacyAssetType, publicKey: String? = nil) {
        legacyAssetType = assetType
        self.assetType = nil
        self.publicKey = publicKey
        loadingText = LocalizationConstants.AddressAndKeyImport.loadingImportKey
        super.init(nibName: nil, bundle: nil)
        self.modalTransitionStyle = .crossDissolve
        guard let deviceInput = getDeviceInput() else { return nil }
        captureSession = AVCaptureSession()
        captureSession?.addInput(deviceInput)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Check if the device input is accessible for scanning QR codes
    private func getDeviceInput() -> AVCaptureDeviceInput? {
        do {
            let input = try AVCaptureDeviceInput.deviceInputForQRScanner()
            return input
        } catch let error as AVCaptureDeviceError {
            switch error.type {
            case .failedToRetrieveDevice:
                AlertViewPresenter.shared.standardError(message: error.localizedDescription)
            case .inputError:
                AlertViewPresenter.shared.standardError(message: error.localizedDescription)
            case .notAuthorized:
                AlertViewPresenter.shared.showNeedsCameraPermissionAlert()
            }
        } catch {
            AlertViewPresenter.shared.standardError(message: error.localizedDescription)
        }
        return nil
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

    @objc func closeButtonClicked(sender: AnyObject) {
        captureSession?.stopRunning()
        videoPreviewLayer?.removeFromSuperlayer()
        self.dismiss(animated: true)
    }

    // MARK: Class Methods

    @objc func startReadingQRCode() {
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

    // MARK: - AVCaptureMetadataOutputObjectsDelegate

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard
            !metadataObjects.isEmpty,
            let metadataObject = metadataObjects.first,
            metadataObject.type == .qr,
            let codeObject = metadataObject as? AVMetadataMachineReadableCodeObject,
            let stringValue = codeObject.stringValue else {
                delegate?.didFinishScanningWithError(.badMetadataObject)
                // TODO: remove once LegacyPrivateKeyDelegate is deprecated
                legacyDelegate?.didFinishScanningWithError(.badMetadataObject)
                return
        }

        self.captureSession?.stopRunning()
        self.videoPreviewLayer?.removeFromSuperlayer()
        LoadingViewPresenter.shared.showBusyView(withLoadingText: self.loadingText)

        self.dismiss(animated: true) {
            let deadlineTime = DispatchTime.now() + Constants.Animation.duration
            DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                let scheme = "\(Constants.Schemes.bitcoin):"
                var scannedKey = stringValue
                //: strip scheme if applicable
                if stringValue.hasPrefix(scheme) {
                    let startIndex = stringValue.index(stringValue.startIndex, offsetBy: scheme.count)
                    let description = String(stringValue[startIndex...])
                    scannedKey = description
                }
                //: Check if the scanned key is a private key, otherwise try public key if accepted
                guard let format = WalletManager.shared.wallet.detectPrivateKeyFormat(scannedKey), format.count > 0 else {
                    LoadingViewPresenter.shared.hideBusyView()
                    if self.acceptPublicKeys {
                        guard let address = BitcoinAddress(string: scannedKey) else {
                            self.delegate?.didFinishScanningWithError(.unknownKeyFormat)
                            // TODO: remove once LegacyPrivateKeyDelegate is deprecated
                            self.legacyDelegate?.didFinishScanningWithError(.unknownKeyFormat)
                            return
                        }
                        WalletManager.shared.askUserToAddWatchOnlyAddress(address) {
                            self.delegate?.didFinishScanning(scannedKey, for: address)
                            // TODO: remove once LegacyPrivateKeyDelegate is deprecated
                            self.legacyDelegate?.didFinishScanning(scannedKey)
                        }
                    } else {
                        self.delegate?.didFinishScanningWithError(.unsupportedPrivateKey)
                        // TODO: remove once LegacyPrivateKeyDelegate is deprecated
                        self.legacyDelegate?.didFinishScanningWithError(.unsupportedPrivateKey)
                    }
                    return
                }
                //: Pass valid private key back via success handler
                self.delegate?.didFinishScanning(scannedKey, for: nil)
                // TODO: remove once LegacyPrivateKeyDelegate is deprecated
                self.legacyDelegate?.didFinishScanning(scannedKey)
            }
        }
    }
}
