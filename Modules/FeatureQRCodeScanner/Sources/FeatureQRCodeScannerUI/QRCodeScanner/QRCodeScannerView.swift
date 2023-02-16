// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

protocol QRCodeScannableArea {
    var area: CGRect { get }
}

final class QRCodeScannerView: UIView, QRCodeScannableArea {

    var area: CGRect {
        overlay.scannableFrame
    }

    private var videoPreviewLayer: CALayer?
    private let viewModel: QRCodeScannerViewModelProtocol
    private let overlay: QRCodeScannerViewOverlay

    init(
        viewModel: QRCodeScannerViewModelProtocol,
        targetCoordinateSpace: UICoordinateSpace
    ) {
        self.viewModel = viewModel
        self.overlay = QRCodeScannerViewOverlay(
            viewModel: viewModel.overlayViewModel,
            targetCoordinateSpace: targetCoordinateSpace
        )
        super.init(frame: .zero)
        setupViewFinder()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViewFinder() {
        addSubview(overlay)
        overlay.fillSuperview()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        videoPreviewLayer?.frame = bounds
    }

    func startReadingQRCode() {
        guard let videoPreviewLayer = viewModel.videoPreviewLayer else { return }

        videoPreviewLayer.frame = frame
        layer.addSublayer(videoPreviewLayer)
        bringSubviewToFront(overlay)

        self.videoPreviewLayer = videoPreviewLayer
    }

    func removePreviewLayer() {
        videoPreviewLayer?.removeFromSuperlayer()
    }
}
