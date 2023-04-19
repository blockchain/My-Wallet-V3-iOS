// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AVKit
import Combine
import DIKit
import FeatureQRCodeScannerDomain
import Localization
import PlatformKit
import PlatformUIKit

final class QRCodeScanner: NSObject, QRCodeScannerProtocol {

    static var defaultSessionQueue: DispatchQueue {
        DispatchQueue(label: "com.blockchain.Blockchain.qrCodeScanner.sessionQueue", qos: .background)
    }

    static var defaultCaptureQueue: DispatchQueue {
        DispatchQueue(label: "com.blockchain.Blockchain.qrCodeScanner.captureQueue")
    }

    weak var delegate: QRCodeScannerDelegate?

    let videoPreviewLayer: CALayer

    var captureVideoPreviewLayer: AVCaptureVideoPreviewLayer {
        videoPreviewLayer as! AVCaptureVideoPreviewLayer
    }

    private let captureSession: CaptureSessionProtocol
    private let captureMetadataOutput: AVCaptureMetadataOutput = .init()
    private let sessionQueue: DispatchQueue
    private let qrCodePublisherSubject = PassthroughSubject<Result<String, QRScannerError>, Never>()

    var qrCodePublisher: AnyPublisher<Result<String, QRScannerError>, Never> {
        qrCodePublisherSubject.eraseToAnyPublisher()
    }

    init(
        captureSession: CaptureSessionProtocol = AVCaptureSession(),
        sessionQueue: DispatchQueue = QRCodeScanner.defaultSessionQueue
    ) {
        captureSession.sessionPreset = .high
        self.captureSession = captureSession
        self.sessionQueue = sessionQueue

        let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession.current!)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        self.videoPreviewLayer = videoPreviewLayer

        super.init()
    }

    func configure(with deviceInput: CaptureInputProtocol) {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            guard captureSession.canAdd(input: deviceInput) else {
                return
            }
            captureSession.add(input: deviceInput)
            guard captureSession.canAdd(output: captureMetadataOutput) else {
                return
            }
            captureSession.add(output: captureMetadataOutput)

            let captureQueue = QRCodeScanner.defaultCaptureQueue
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: captureQueue)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        }
    }

    func startReadingQRCode(from scannableArea: QRCodeScannableArea) {
        let frame = scannableArea.area
        sessionQueue.async { [weak self] in
            self?.captureSession.current?.commitConfiguration()
            self?.captureSession.startRunning()
            let rectOfInterest = self?.captureVideoPreviewLayer
                .metadataOutputRectConverted(fromLayerRect: frame) ?? .zero
            self?.captureMetadataOutput.rectOfInterest = rectOfInterest

            DispatchQueue.main.async {
                self?.delegate?.didStartScanning()
            }
        }
    }

    func restartScanning() {
        sessionQueue.async { [weak self] in
            self?.captureSession.startRunning()
        }
    }

    func stopReadingQRCode(complete: (() -> Void)? = nil) {
        sessionQueue.async { [weak self] in
            self?.captureSession.stopRunning()

            DispatchQueue.main.async {
                self?.delegate?.didStopScanning()
                complete?()
            }
        }
    }

    func handleSelectedQRImage(_ image: UIImage) {
        guard let cgImage = image.cgImage else {
            handleQRImageSelectionError()
            return
        }
        let ciImage = CIImage(cgImage: cgImage)
        let detector = CIDetector(
            ofType: CIDetectorTypeQRCode,
            context: CIContext(),
            options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        )
        let stringValue = detector?.features(in: ciImage).compactMap { feature in
            (feature as? CIQRCodeFeature)?.messageString
        }.first
        guard let value = stringValue else {
            handleQRImageSelectionError()
            return
        }
        stopReadingQRCode { [weak self] in
            self?.qrCodePublisherSubject.send(.success(value))
        }
    }

    // MARK: - Private methods

    private func handleQRImageSelectionError() {
        delegate?.scanComplete?(.failure(.scannerError(.unknown)))
    }
}

extension QRCodeScanner: AVCaptureMetadataOutputObjectsDelegate {

    // MARK: - AVCaptureMetadataOutputObjectsDelegate

    public func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard !metadataObjects.isEmpty,
              let metadataObject = metadataObjects.first,
              metadataObject.type == .qr,
              let codeObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let stringValue = codeObject.stringValue
        else {
            qrCodePublisherSubject.send(.failure(QRScannerError.badMetadataObject))
            return
        }
        stopReadingQRCode { [weak self] in
            self?.qrCodePublisherSubject.send(.success(stringValue))
        }
    }
}
