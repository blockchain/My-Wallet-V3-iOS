// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Combine
import Foundation
import SwiftUI

#if canImport(UIKit)
import UIKit
typealias UniversalImage = UIImage
private let makeImage = Image.init(uiImage:)
#elseif canImport(AppKit)
import AppKit
typealias UniversalImage = NSImage
private let makeImage = Image.init(nsImage:)
#endif

public struct ImageResourceView<Loading: View, Placeholder: View>: View {

    @StateObject private var loader: ImageLoader

    private let resource: ImageLocation
    private let placeholder: () -> Placeholder
    private let loading: () -> Loading
    fileprivate var configurations: [(Image) -> Image] = []

    public init(
        resource: ImageLocation,
        @ViewBuilder loading: @escaping () -> Loading,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.resource = resource
        self.loading = loading
        self.placeholder = placeholder
        _loader = StateObject(wrappedValue: ImageLoader())
    }

    public var body: some View {
        content
            .onChange(of: resource) { value in
                loader.load(resource: value)
            }
            .onAppear {
                loader.load(resource: resource)
            }
            .id(resource)
    }

    @ViewBuilder private var content: some View {
        if loader.isLoading {
            loading()
        } else if let image = loader.image {
            image.resizable()
        } else {
            placeholder()
        }
    }
}

extension ImageResourceView {
    private func configure(_ block: @escaping (Image) -> Image) -> ImageResourceView {
        var result = self
        result.configurations.append(block)
        return result
    }

    /// Sets the mode by which SwiftUI resizes an image to fit its space.
    /// - Parameters:
    ///   - capInsets: Inset values that indicate a portion of the image that
    ///   SwiftUI doesn't resize.
    ///   - resizingMode: The mode by which SwiftUI resizes the image.
    /// - Returns: An image, with the new resizing behavior set.
    public func resizable(
        capInsets: EdgeInsets = EdgeInsets(),
        resizingMode: Image.ResizingMode = .stretch
    ) -> ImageResourceView {
        configure { $0.resizable(capInsets: capInsets, resizingMode: resizingMode) }
    }

    /// Indicates whether SwiftUI renders an image as-is, or
    /// by using a different mode.
    /// - Parameter renderingMode: The rendering mode
    public func renderingMode(_ renderingMode: Image.TemplateRenderingMode?) -> ImageResourceView {
        configure { $0.renderingMode(renderingMode) }
    }

    /// Specifies the current level of quality for rendering an
    /// image that requires interpolation.
    ///
    /// See the article <doc:Fitting-Images-into-Available-Space> for examples
    /// of using `interpolation(_:)` when scaling an ``Image``.
    /// - Parameter interpolation: The quality level, expressed as a value of
    /// the `Interpolation` type, that SwiftUI applies when interpolating
    /// an image.
    /// - Returns: An image with the given interpolation value set.
    public func interpolation(_ interpolation: Image.Interpolation) -> ImageResourceView {
        configure { $0.interpolation(interpolation) }
    }

    /// Specifies whether SwiftUI applies antialiasing when rendering
    /// the image.
    /// - Parameter isAntialiased: A Boolean value that specifies whether to
    /// allow antialiasing. Pass `true` to allow antialising, `false` otherwise.
    /// - Returns: An image with the antialiasing behavior set.
    public func antialiased(_ isAntialiased: Bool) -> ImageResourceView {
        configure { $0.antialiased(isAntialiased) }
    }
}

extension ImageResourceView {

    public init(
        systemName: String,
        @ViewBuilder loading: @escaping () -> Loading,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.init(resource: .systemName(systemName), loading: loading, placeholder: placeholder)
    }

    public init(
        named name: String,
        in bundle: Bundle,
        @ViewBuilder loading: @escaping () -> Loading,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.init(resource: .local(name: name, bundle: bundle), loading: loading, placeholder: placeholder)
    }

    public init(
        url: URL,
        @ViewBuilder loading: @escaping () -> Loading,
        placeholder: @autoclosure @escaping () -> Placeholder
    ) {
        self.init(resource: .remote(url: url, fallback: nil), loading: loading, placeholder: placeholder)
    }

    public init(
        _ resource: ImageLocation,
        @ViewBuilder loading: @escaping () -> Loading,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.init(resource: resource, loading: loading, placeholder: placeholder)
    }
}

extension ImageResourceView where Loading == ProgressView<EmptyView, EmptyView> {

    public init(
        systemName: String,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.init(.systemName(systemName), placeholder: placeholder)
    }

    public init(
        named name: String,
        in bundle: Bundle,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.init(.local(name: name, bundle: bundle), placeholder: placeholder)
    }

    public init(
        url: URL,
        placeholder: @autoclosure @escaping () -> Placeholder
    ) {
        self.init(.remote(url: url, fallback: nil), placeholder: placeholder)
    }

    public init(
        url: URL,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.init(.remote(url: url, fallback: nil), placeholder: placeholder)
    }

    public init(
        _ resource: ImageLocation,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.init(resource: resource, loading: ProgressView.init, placeholder: placeholder)
    }
}

extension ImageResourceView where Loading == ProgressView<EmptyView, EmptyView>, Placeholder == Color {

    public init(systemName: String) {
        self.init(.systemName(systemName))
    }

    public init(named name: String, in bundle: Bundle) {
        self.init(.local(name: name, bundle: bundle))
    }

    public init(url: URL) {
        self.init(.remote(url: url, fallback: nil))
    }

    public init(_ resource: ImageLocation) {
        self.init(resource: resource, loading: ProgressView.init, placeholder: { Color.gray })
    }
}

private class ImageLoader: ObservableObject {

    @Published var image: Image?

    private(set) var isLoading = false
    private var cancellable: AnyCancellable?

    private static let imageProcessingQueue = DispatchQueue(label: "image-processing")

    init() {}

    deinit {
        cancel()
    }

    func load(resource: ImageLocation) {
        guard !isLoading else { return }

        switch resource {
        case .local(name: let name, bundle: let bundle):
            image = Image(name, bundle: bundle)
            onFinish()
        case .systemName(let name):
            image = Image(systemName: name)
            onFinish()
        case .remote(url: let url, fallback: let fallback):
            cancellable = URLSession.shared.dataTaskPublisher(for: url)
                .map { UniversalImage(data: $0.data) }
                .replaceError(with: nil)
                .handleEvents(
                    receiveSubscription: { [weak self] _ in self?.onStart() },
                    receiveCompletion: { [weak self] _ in self?.onFinish() },
                    receiveCancel: { [weak self] in self?.onFinish() }
                )
                .subscribe(on: Self.imageProcessingQueue)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in self?.image = $0.map(makeImage) }
        }
    }

    func cancel() {
        cancellable?.cancel()
    }

    private func onStart() {
        isLoading = true
    }

    private func onFinish() {
        isLoading = false
    }
}

struct ImageResourceView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ImageResourceView(systemName: "building.columns.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20)
            ImageResourceView(named: "cancel_icon", in: .module)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20)
            ImageResourceView(
                url: URL(string: "https://www.blockchain.com/static/img/home/products/wallet-buy@2x.png")!
            )
            .resizable()
            .aspectRatio(contentMode: .fit)
        }
    }
}
