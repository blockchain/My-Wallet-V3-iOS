import SwiftUI

public struct Tile<Title: View, Byline: View, Footer: View>: View {

    let title: Title
    let byline: Byline
    let footer: Footer
    let aspectRatio: Double
    let action: () -> Void

    public init(
        @ViewBuilder title: () -> Title,
        @ViewBuilder byline: () -> Byline,
        @ViewBuilder footer: () -> Footer = EmptyView.init,
        aspectRatio: Double = 4 / 3,
        action: @escaping () -> Void
    ) {
        self.title = title()
        self.byline = byline()
        self.footer = footer()
        self.aspectRatio = aspectRatio
        self.action = action
    }

    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
            VStack(alignment: .leading, spacing: 8.pt) {
                title.padding(.bottom, 4.pt)
                byline
                footer
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Spacing.padding2.pt)
        }
        .aspectRatio(aspectRatio, contentMode: .fit)
        .onTapGesture { action() }
    }
}

public struct TitleWithIcon<A: View>: View {

    let icon: URL?
    let title: A

    public var body: some View {
        HStack {
            if let icon {
                AsyncMedia(url: icon)
                    .resizingMode(.aspectFit)
                    .frame(width: 24.pt, height: 24.pt)
            }
            title
        }
    }
}

extension Tile {

    public init<T: View>(
        icon: URL?,
        @ViewBuilder title: () -> T,
        @ViewBuilder byline: () -> Byline,
        @ViewBuilder footer: () -> Footer = EmptyView.init,
        aspectRatio: Double = 4 / 3,
        action: @escaping () -> Void
    ) where Title == TitleWithIcon<T> {
        self.init(
            title: { TitleWithIcon(icon: icon, title: title()) },
            byline: byline,
            footer: footer,
            aspectRatio: aspectRatio,
            action: action
        )
    }
}
