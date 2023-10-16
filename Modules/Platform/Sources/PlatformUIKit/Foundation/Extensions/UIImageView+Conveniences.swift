// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import NukeExtensions
import RxCocoa
import RxSwift

public struct ImageViewContent: Equatable {

    // MARK: - Types

    public enum RenderingMode: Equatable {
        case template(UIColor)
        case normal

        var templateColor: UIColor? {
            switch self {
            case .template(let color):
                return color
            case .normal:
                return nil
            }
        }
    }

    // MARK: - Static Properties

    public static let empty = ImageViewContent()

    // MARK: - Properties

    var templateColor: UIColor? {
        renderingMode.templateColor
    }

    let accessibility: Accessibility
    public let imageResource: ImageLocation?
    let renderingMode: RenderingMode

    public init(
        imageResource: ImageLocation? = nil,
        accessibility: Accessibility = .none,
        renderingMode: RenderingMode = .normal
    ) {
        self.imageResource = imageResource
        self.accessibility = accessibility
        self.renderingMode = renderingMode
    }
}

extension UIImageView {
    public func set(_ content: ImageViewContent?) {
        NukeExtensions.cancelRequest(for: self)
        tintColor = content?.templateColor
        accessibility = content?.accessibility ?? .none

        guard let content else {
            image = nil
            return
        }

        func update(_ image: UIImage?) {
            switch content.renderingMode {
            case .normal:
                self.image = image
            case .template:
                self.image = image?.withRenderingMode(.alwaysTemplate)
            }
        }

        switch content.imageResource {
        case .local(name: let name, bundle: let bundle):
            update(UIImage(named: name, in: bundle, with: nil))
        case .remote(url: let url, fallback: _):
            image = nil
            _ = NukeExtensions.loadImage(with: url, into: self)
        case .systemName(let value):
            update(UIImage(systemName: value))
        case nil:
            image = nil
        }
    }
}

extension Reactive where Base: UIImageView {
    public var content: Binder<ImageViewContent> {
        Binder(base) { imageView, content in
            imageView.set(content)
        }
    }
}
