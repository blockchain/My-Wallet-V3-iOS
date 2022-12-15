// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import DIKit
import FeatureQRCodeScannerDomain
import Localization
import PlatformKit
import PlatformUIKit
import SwiftUI
import ToolKit
import UIKit

public enum QRCodePresentationType {
    case modal(dismissWithAnimation: Bool)
    case child
}

final class QRCodeScannerViewController: UIViewController, UINavigationControllerDelegate {

    private var targetCoordinateSpace: UICoordinateSpace {
        guard isViewLoaded else {
            fatalError("viewFrame should only be accessed after the view is loaded.")
        }
        guard let window = UIApplication.shared.firstKeyWindow else {
            fatalError("Trying to get key window before it was set!")
        }
        return window.coordinateSpace
    }

    private var scannerView: QRCodeScannerView!

    private let viewModel: QRCodeScannerViewModelProtocol
    private let presentationType: QRCodePresentationType

    private lazy var sheetPresenter = BottomSheetPresenting(ignoresBackgroundTouches: true)

    init(
        presentationType: QRCodePresentationType = .modal(dismissWithAnimation: true),
        viewModel: QRCodeScannerViewModelProtocol
    ) {
        self.presentationType = presentationType
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        switch presentationType {
        case .modal(dismissWithAnimation: let animated):
            modalTransitionStyle = .crossDissolve
            self.viewModel.closeButtonTapped = { [weak self] in
                guard let self else { return }
                self.dismiss(
                    animated: animated,
                    completion: { [weak self] in
                        self?.viewModel.completed(.failure(.dismissed))
                    }
                )
            }
        case .child:
            break
        }

        self.viewModel.scanningStarted = { [weak self] in
            self?.scanDidStart()
            Logger.shared.info("Scanning started")
        }

        self.viewModel.scanningStopped = { [weak self] in
            self?.scanDidStop()
        }

        self.viewModel.scanComplete = { [weak self] result in
            self?.handleScanComplete(with: result)
        }
        self.viewModel.overlayViewModel.cameraButtonTapped = { [weak self] in
            self?.showImagePicker()
        }

        self.viewModel.showInformationSheetTapped = { [weak self] informationalOnly in
            self?.showAllowAccessSheet(informationalOnly: informationalOnly)
        }

        self.viewModel.cameraConfigured = { [weak self] in
            guard let self else { return }
            self.viewModel.startReadingQRCode(from: self.scannerView)
            self.scannerView?.startReadingQRCode()
        }

        self.viewModel.showCameraAccessFailure = { [weak self] title, message in
            self?.showAlert(title: title, message: message)
        }

        self.viewModel.showCameraNotAuthorizedAlert = { [weak self] in
            self?.showNeedsCameraPermissionAlert()
        }
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.darkFadeBackground

        scannerView = QRCodeScannerView(viewModel: viewModel, targetCoordinateSpace: targetCoordinateSpace)
        scannerView.alpha = 1
        view.addSubview(scannerView)
        scannerView.layoutToSuperview(.leading, .trailing, .top, .bottom)

        switch presentationType {
        case .modal:
            title = viewModel.headerText
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(named: "close"),
                style: .plain,
                target: self,
                action: #selector(closeButtonClicked)
            )
        case .child:
            break
        }

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "Info", in: .featureQRCodeScannerUI, with: nil),
            style: .plain,
            target: self,
            action: #selector(informationButtonClicked)
        )
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.viewDidAppear()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.viewWillDisappear()
    }

    @objc func closeButtonClicked(sender: AnyObject) {
        viewModel.closeButtonPressed()
    }

    @objc func informationButtonClicked(sender: AnyObject) {
        viewModel.showInformationSheet()
    }

    private func handleScanComplete(with result: Result<QRCodeScannerResultType, QRCodeScannerResultError>) {
        guard case .success = result else { return }

        switch presentationType {
        case .modal(dismissWithAnimation: let animated):
            presentedViewController?.dismiss(animated: true)
            dismiss(animated: animated) { [weak self] in
                self?.viewModel.completed(result)
            }
        case .child:
            viewModel.completed(result)
        }
    }

    private func scanDidStart() {
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: [.curveEaseIn, .transitionCrossDissolve, .beginFromCurrentState],
            animations: {
                self.scannerView?.alpha = 1
            },
            completion: nil
        )
    }

    private func scanDidStop() {}

    private func showImagePicker() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.mediaTypes = ["public.image"]
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true, completion: nil)
    }

    private func showAllowAccessSheet(informationalOnly: Bool) {
        let environment = AllowAccessEnvironment(
            allowCameraAccess: { [viewModel] in
                viewModel.allowCameraAccess()
            },
            cameraAccessDenied: { [viewModel] in
                viewModel.cameraAccessDenied()
            },
            dismiss: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            },
            showCameraDeniedAlert: { [viewModel] in
                viewModel.showCameraNotAuthorizedAlert?()
            },
            showsWalletConnectRow: { [viewModel] in
                viewModel.showsWalletConnectRow()
            },
            openWalletConnectUrl: { [viewModel] url in
                viewModel.openWalletConnectArticle(url: url)
            }
        )
        let allowAccessStore = Store(
            initialState: AllowAccessState(
                informationalOnly: informationalOnly,
                showWalletConnectRow: true
            ),
            reducer: qrScannerAllowAccessReducer,
            environment: environment
        )
        let view = QRCodeScannerAllowAccessView(store: allowAccessStore)
        let hostingController = UIHostingController(rootView: view)
        hostingController.transitioningDelegate = sheetPresenter
        hostingController.modalPresentationStyle = .custom
        present(hostingController, animated: true, completion: nil)
    }

    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alertController.addAction(
            UIAlertAction(title: LocalizationConstants.okString, style: .cancel)
        )
        if presentedViewController != nil {
            presentedViewController?.dismiss(animated: true) { [weak self] in
                self?.present(alertController, animated: true, completion: nil)
            }
        } else {
            present(alertController, animated: true, completion: nil)
        }
    }

    private func showNeedsCameraPermissionAlert() {
        let alert = UIAlertController(
            title: LocalizationConstants.Errors.cameraAccessDenied,
            message: LocalizationConstants.Errors.cameraAccessDeniedMessage,
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(title: LocalizationConstants.goToSettings, style: .default) { [viewModel] _ in
                viewModel.openAppSettings()
            }
        )
        alert.addAction(
            UIAlertAction(title: LocalizationConstants.cancel, style: .cancel)
        )
        if presentedViewController != nil {
            presentedViewController?.dismiss(animated: true) { [weak self] in
                self?.present(alert, animated: true, completion: nil)
            }
        } else {
            present(alert, animated: true, completion: nil)
        }
    }
}

extension QRCodeScannerViewController: UIImagePickerControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        guard let pickedImage = info[.originalImage] as? UIImage else { return }
        picker.dismiss(animated: true) { [weak self] in
            self?.viewModel.handleSelectedQRImage(pickedImage)
        }
    }
}
