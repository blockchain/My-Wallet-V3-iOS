// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Combine
import Localization
import UIKit

final class QRCodeScannerViewOverlay: UIView {

    private enum Images {
        case cameraRoll
        case connectedDapps
        case flashDisabled
        case flashEnabled
        case target

        private var name: String {
            switch self {
            case .cameraRoll:
                return "camera-roll-button"
            case .connectedDapps:
                return "connectedDappsIcon"
            case .flashDisabled:
                return "flashDisabled"
            case .flashEnabled:
                return "flashEnabled"
            case .target:
                return "target"
            }
        }

        var image: UIImage? {
            UIImage(
                named: name,
                in: .featureQRCodeScannerUI,
                with: nil
            )
        }
    }

    /// The area that the QR code must be within.
    var scannableFrame: CGRect {
        // We want a 280x280 square.
        let halfAxis: CGFloat = 140
        // We have the target coordinate space bounds.
        let targetBounds = targetCoordinateSpace.bounds
        // We create a rect representing a 280x280 square in the middle of target.
        let targetSquare = CGRect(
            x: targetBounds.midX - halfAxis,
            y: targetBounds.midY - halfAxis,
            width: 2 * halfAxis,
            height: 2 * halfAxis
        )
        // We convert the rect from the target coordinate space into ours.
        return convert(targetSquare, from: targetCoordinateSpace)
    }

    private let viewModel: QRCodeScannerOverlayViewModel
    private let scanningViewFinder = UIView()
    private let flashButton = UIButton()
    private let cameraRollButton = UIButton()
    private let connectedDappsButton = UIButton()
    private let subtitleLabel = UILabel()
    private let titleLabel = UILabel()
    private var cancellables = [AnyCancellable]()
    private let targetCoordinateSpace: UICoordinateSpace

    private let cameraRollButtonSubject = PassthroughSubject<Void, Never>()
    private let flashButtonSubject = PassthroughSubject<Void, Never>()

    private let targetImageView = UIImageView(image: Images.target.image)

    init(viewModel: QRCodeScannerOverlayViewModel, targetCoordinateSpace: UICoordinateSpace) {
        self.viewModel = viewModel
        self.targetCoordinateSpace = targetCoordinateSpace
        super.init(frame: .zero)
        setupSubviews()

        viewModel.scanSuccess
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                switch result {
                case .success(let success):
                    self?.setScanningBorder(color: success ? .successBorder : .idleBorder)
                case .failure:
                    self?.setScanningBorder(color: .errorBorder)
                }
            }
            .store(in: &cancellables)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setScanningBorder(color: UIColor) {
        UIView.animate(withDuration: 0.3) {
            self.targetImageView.tintColor = color
        }
    }

    private func setupSubviews() {
        backgroundColor = UIColor.darkFadeBackground.withAlphaComponent(0.9)
        setupButtons()
        setupLabels()
        setupBorderView()
    }

    private func setupLabels() {
        viewModel.titleLabelContent
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.titleLabel.content = $0
            }
            .store(in: &cancellables)

        addSubview(subtitleLabel)
        subtitleLabel.layoutToSuperview(.leading, offset: 24)
        subtitleLabel.layoutToSuperview(.trailing, offset: -24)
        subtitleLabel.layoutToSuperview(.top, offset: 16)
        subtitleLabel.numberOfLines = 0
        viewModel.subtitleLabelContent
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.subtitleLabel.content = $0
            }
            .store(in: &cancellables)
    }

    private func setupButtons() {
        addSubview(flashButton)
        addSubview(cameraRollButton)
        addSubview(targetImageView)
        cameraRollButton.addTarget(self, action: #selector(onCameraRollTap), for: .touchUpInside)
        cameraRollButton.layout(size: .edge(44))
        cameraRollButton.layoutToSuperview(.trailing, offset: -44)
        cameraRollButton.layoutToSuperview(.bottom, offset: -64)

        flashButton.layout(size: .edge(44))
        flashButton.layoutToSuperview(.centerX)
        flashButton.layout(edge: .top, to: .bottom, of: targetImageView, offset: 20)
        flashButton.addTarget(self, action: #selector(onFlashButtonTap), for: .touchUpInside)

        viewModel
            .cameraRollButtonVisibility
            .map(\.isHidden)
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                self?.cameraRollButton.isHidden = $0
            }
            .store(in: &cancellables)

        cameraRollButtonSubject
            .eraseToAnyPublisher()
            .throttle(
                for: .milliseconds(200),
                scheduler: DispatchQueue.global(qos: .background),
                latest: false
            )
            .sink { [weak self] in self?.viewModel.cameraTapRelay.send($0) }
            .store(in: &cancellables)

        viewModel
            .flashEnabled
            .receive(on: RunLoop.main)
            .sink { [weak self] enabled in
                self?.flashButton.isSelected = enabled
            }
            .store(in: &cancellables)

        flashButtonSubject
            .eraseToAnyPublisher()
            .throttle(
                for: .milliseconds(200),
                scheduler: DispatchQueue.global(qos: .background),
                latest: false
            )
            .sink { [weak self] in self?.viewModel.flashTapRelay.send($0) }
            .store(in: &cancellables)

        cameraRollButton.setImage(Images.cameraRoll.image, for: .normal)

        flashButton.setImage(Images.flashDisabled.image, for: .normal)
        flashButton.setImage(Images.flashEnabled.image, for: .selected)
        flashButton.setImage(Images.flashEnabled.image, for: .highlighted)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let scannableFrame = scannableFrame
        setupLayerMask(frame: scannableFrame)
        targetImageView.frame.origin = scannableFrame.origin.applying(CGAffineTransform(translationX: -12, y: -12))
    }

    /// Sets up layers mask given the frame provided.
    private func setupLayerMask(frame: CGRect) {
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        let path = UIBezierPath(rect: bounds)
        path.append(
            .init(
                roundedRect: scannableFrame,
                byRoundingCorners: .allCorners,
                cornerRadii: .edge(8)
            )
        )
        maskLayer.fillRule = .evenOdd
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
    }

    private func setupBorderView() {
        targetImageView.tintColor = .idleBorder
        targetImageView.frame.origin = scannableFrame.origin
    }

    @objc private func onCameraRollTap() {
        cameraRollButtonSubject.send()
    }

    @objc private func onFlashButtonTap() {
        flashButtonSubject.send()
    }
}
