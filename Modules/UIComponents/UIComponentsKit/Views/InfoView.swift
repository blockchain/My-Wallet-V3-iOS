// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

public struct InfoView: View {

    public struct Model: Equatable, Codable {

        public struct Overlay: Equatable, Codable {
            public var media: Media?
            public var progress: Bool?
        }

        public var media: Media
        public var overlay: Overlay?
        public var title: String
        public var subtitle: String
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
    public var bundle: Bundle

    public init(
        _ model: Model,
        layout: Layout = .init(
            media: Size(length: 20.vmin),
            overlay: Size(length: 8.vmin),
            margin: 6.vmin,
            spacing: LayoutConstants.VerticalSpacing.betweenContentGroups.pt
        ),
        in bundle: Bundle = .main
    ) {
        self.model = model
        self.layout = layout
        self.bundle = bundle
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
                in: bundle,
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
                overlayView.frame(
                    width: computed.overlay.width,
                    height: computed.overlay.height
                ),
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
            MediaView(icon, in: bundle, failure: EmptyView.init)
        } else if model.overlay?.progress == true {
            ProgressView(value: 0.25)
                .progressViewStyle(IndeterminateProgressStyle())
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
                    overlay: .init(media: .image(systemName: "building.columns.fill")),
                    title: "Taking you to Monzo",
                    subtitle: "This could take up to 30 seconds. Please do not go back or close the app"
                )
            )
            Spacer()
        }
    }
}
#endif