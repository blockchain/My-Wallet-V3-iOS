// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AVKit
import CasePaths
import Extensions
import Nuke
import NukeUI
import SwiftUI
import UniformTypeIdentifiers

public typealias Media = NukeUI.Image

@MainActor
public struct AsyncMedia<Content: View>: View {

    private let url: URL?
    private let transaction: Transaction
    private let content: (AsyncPhase<Media>) -> Content

    @Environment(\.resizingMode) var resizingMode

    public init(
        url: URL?,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping (AsyncPhase<Media>) -> Content
    ) {
        self.url = url
        self.transaction = transaction
        self.content = content
    }

    public var body: some View {
        LazyImage(
            url: url,
            content: { state in
                withTransaction(transaction) {
                    which(state)
                }
            }
        )
        .id(url)
    }

    @ViewBuilder
    private func which(_ state: LazyImageState) -> some View {
        if let image: NukeUI.Image = state.image {
            #if os(macOS)
            content(.success(image))
            #else
            content(.success(image.resizingMode(resizingMode.imageResizingMode)))
            #endif
        } else if let error = state.error {
            content(.failure(error))
        } else {
            content(.empty)
        }
    }
}

extension AsyncMedia {

    public init(
        url: URL?,
        transaction: Transaction = Transaction()
    ) where Content == _ConditionalContent<_ConditionalContent<Media, EmptyView>, ProgressView<EmptyView, EmptyView>> {
        self.init(url: url, transaction: transaction, placeholder: { ProgressView() })
    }

    public init<I: View, P: View>(
        url: URL?,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping (Media) -> I,
        @ViewBuilder placeholder: @escaping () -> P
    ) where Content == _ConditionalContent<_ConditionalContent<I, EmptyView>, P> {
        self.init(url: url, transaction: transaction, content: content, failure: { _ in EmptyView() }, placeholder: placeholder)
    }

    public init<I: View, F: View, P: View>(
        url: URL?,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping (Media) -> I,
        @ViewBuilder failure: @escaping (Error) -> F,
        @ViewBuilder placeholder: @escaping () -> P
    ) where Content == _ConditionalContent<_ConditionalContent<I, F>, P> {
        self.init(url: url, transaction: transaction) { phase in
            switch phase {
            case .success(let media):
                content(media)
            case .failure(let error):
                failure(error)
            case .empty:
                placeholder()
            }
        }
    }

    public init<P: View>(
        url: URL?,
        transaction: Transaction = Transaction(),
        @ViewBuilder placeholder: @escaping () -> P
    ) where Content == _ConditionalContent<_ConditionalContent<Media, EmptyView>, P> {
        self.init(
            url: url,
            transaction: transaction,
            content: { phase in
                switch phase {
                case .success(let media):
                    media
                case .failure:
                    EmptyView()
                case .empty:
                    placeholder()
                }
            }
        )
    }

    public init<P: View, F: View>(
        url: URL?,
        transaction: Transaction = Transaction(),
        @ViewBuilder failure: @escaping (Error) -> F,
        @ViewBuilder placeholder: @escaping () -> P
    ) where Content == _ConditionalContent<_ConditionalContent<Media, F>, P> {
        self.init(
            url: url,
            transaction: transaction,
            content: { phase in
                switch phase {
                case .success(let media):
                    media
                case .failure(let error):
                    failure(error)
                case .empty:
                    placeholder()
                }
            }
        )
    }

    public init<F: View>(
        url: URL?,
        transaction: Transaction = Transaction(),
        @ViewBuilder failure: @escaping (Error) -> F
    ) where Content == _ConditionalContent<_ConditionalContent<Media, F>, ProgressView<EmptyView, EmptyView>> {
        self.init(
            url: url,
            transaction: transaction,
            content: { phase in
                switch phase {
                case .success(let media):
                    media
                case .failure(let error):
                    failure(error)
                case .empty:
                    ProgressView()
                }
            }
        )
    }
}

extension URL {

    var uniformTypeIdentifier: UTType? { UTType(filenameExtension: pathExtension) }
}

extension EnvironmentValues {

    public var resizingMode: MediaResizingMode {
        get { self[ImageResizingModeEnvironmentKey.self] }
        set { self[ImageResizingModeEnvironmentKey.self] = newValue }
    }
}

private struct ImageResizingModeEnvironmentKey: EnvironmentKey {
    static var defaultValue = MediaResizingMode.aspectFit
}

extension View {

    @warn_unqualified_access @inlinable
    public func resizingMode(_ resizingMode: MediaResizingMode) -> some View {
        environment(\.resizingMode, resizingMode)
    }
}

public enum MediaResizingMode: String, Codable {
    case fill
    case aspectFit = "aspect_fit"
    case aspectFill = "aspect_fill"
    case center
}

extension MediaResizingMode {

    @usableFromInline var imageResizingMode: ImageResizingMode {
        switch self {
        case .fill: return .fill
        case .aspectFit: return .aspectFit
        case .aspectFill: return .aspectFill
        case .center: return .center
        }
    }
}
