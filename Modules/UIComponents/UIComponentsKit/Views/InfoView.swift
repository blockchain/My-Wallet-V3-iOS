// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Extensions
import SwiftUI

// TODO: @paulo: move to FeatureOpenBankingUI

public struct InfoView: View {

    public struct Model: Equatable, Codable {

        public struct Overlay: Equatable, Codable {
            public var media: Media?
            public var progress: Bool?

            public init(media: Media? = nil, progress: Bool? = nil) {
                self.media = media
                self.progress = progress
            }
        }

        public var media: Media
        public var overlay: Overlay?
        public var title: String
        public var subtitle: String

        public init(media: Media, overlay: InfoView.Model.Overlay? = nil, title: String, subtitle: String) {
            self.media = media
            self.overlay = overlay
            self.title = title
            self.subtitle = subtitle
        }

        public init(media: Media, overlay: Media, title: String, subtitle: String) {
            self.media = media
            self.overlay = .init(media: overlay)
            self.title = title
            self.subtitle = subtitle
        }
    }

    public struct Layout: Equatable, Codable {

        public var media: Size
        public var overlay: Size
        public var margin: Length
        public var spacing: Length

        public init(
            media: Size,
            overlay: Size,
            margin: Length,
            spacing: Length
        ) {
            self.media = media
            self.overlay = overlay
            self.margin = margin
            self.spacing = spacing
        }
    }

    public var model: Model
    public var layout: Layout

    public init(
        _ model: Model,
        layout: Layout = .init(
            media: Size(length: 20.vmin),
            overlay: Size(length: 7.5.vmin),
            margin: 6.vmin,
            spacing: LayoutConstants.VerticalSpacing.betweenContentGroups.pt
        )
    ) {
        self.model = model
        self.layout = layout
    }

    private struct ComputedLayout: Equatable {
        var media: CGSize = .zero
        var overlay: CGSize = .zero
        var margin: CGFloat = .zero
        var spacing: CGFloat = .zero
    }

    @State private var computed: ComputedLayout = .init()

    public var body: some View {
        VStack(spacing: computed.spacing) {
            MediaView(
                model.media,
                failure: {
                    Color.red
                        .opacity(0.25)
                        .clipShape(Circle())
                        .overlay(
                            Image(systemName: "nosign")
                                .resizable()
                                .padding(computed.overlay.height / 2)
                                .foregroundColor(Color.white)
                        )
                }
            )
            .frame(
                width: computed.media.width
                    + computed.overlay.height / 2,
                height: computed.media.height
                    + computed.overlay.height / 2
            )
            .padding(
                EdgeInsets(
                    top: computed.overlay.height / 2,
                    leading: computed.overlay.width / 2,
                    bottom: computed.overlay.height / 2,
                    trailing: computed.overlay.width / 2
                )
            )
            .overlay(
                ZStack {
                    if model.overlay != nil {
                        Circle()
                            .foregroundColor(.semantic.background)
                            .scaleEffect(1.3)
                        overlayView
                    }
                }
                .frame(
                    width: computed.overlay.width,
                    height: computed.overlay.height
                )
                .offset(x: -7.5, y: 7.5),
                alignment: .topTrailing
            )
            VStack {
                Text(model.title)
                    .textStyle(.title)
                Text(model.subtitle)
                    .textStyle(.body)
            }
            .multilineTextAlignment(.center)
            .padding([.leading, .trailing], computed.margin)
        }.background(
            GeometryReader { proxy in
                Color.clear.onAppear {
                    computed = .init(
                        media: layout.media.in(proxy),
                        overlay: layout.overlay.in(proxy),
                        margin: layout.margin.in(proxy),
                        spacing: layout.spacing.in(proxy)
                    )
                }
            }
        )
    }

    @ViewBuilder var overlayView: some View {
        if let icon = model.overlay?.media {
            MediaView(icon, failure: Color.clear)
        } else if model.overlay?.progress == true {
            ProgressView(value: 0.25)
                .progressViewStyle(.indeterminate)
        } else {
            EmptyView()
        }
    }
}

#if DEBUG
struct InfoView_Previews: PreviewProvider {

    static var previews: some View {
        VStack {
            Spacer()
            InfoView(
                .init(
                    media: .image(systemName: "building.columns.fill"),
                    overlay: .init(progress: true),
                    title: "Taking you to Monzo",
                    subtitle: "This could take up to 30 seconds. Please do not go back or close the app"
                )
            )
            Spacer()
        }
    }
}
#endif
