// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import SwiftUI

public enum Backport {}

extension View {
    public var backport: Backport.ContentView<Self> { Backport.ContentView(content: self) }
}

extension Image: OptionalDataInit {

    public init?(_ data: Data?) {
        #if canImport(AppKit)
        guard let image = data
            .flatMap(NSImage.init(data:))
            .map(Image.init(nsImage:))
        else { return nil }
        #else
        guard let image = data
            .flatMap(UIImage.init(data:))
            .map(Image.init(uiImage:))
        else { return nil }
        #endif
        self = image
    }
}

extension Backport {
    public struct ContentView<Content> where Content: View {
        let content: Content
    }
}

extension Backport.ContentView {
    /// Hides the separator on a `View` that is shown in
    /// a `List`.
    @ViewBuilder public func hideListRowSeparator() -> some View {
        #if os(iOS)
        if #available(iOS 15, *) {
            content
                .listRowSeparator(.hidden)
        } else {
            content
        }
        #else
        content
        #endif
    }

    /// Adds a `PrimaryDivider` at the bottom of the View.
    @ViewBuilder public func addPrimaryDivider() -> some View {
        if #available(iOS 15, *) {
            content
            PrimaryDivider()
        } else {
            content
        }
    }

    /// Hides the separator on a `View` that is shown in
    /// a `List` and adds a `PrimaryDivider` at the bottom of the View.
    @ViewBuilder public func hideListRowSepartorAndAddDivider() -> some View {
        #if os(iOS)
        if #available(iOS 15, *) {
            content
                .listRowSeparator(.hidden)
            PrimaryDivider()
        } else {
            content
        }
        #else
        content
        #endif
    }

    /// Hides the separator on a `View` that is shown in
    /// a `List` and adds a divider without insets at the top of the View.
    @ViewBuilder public func listDivider() -> some View {
        if #available(iOS 15, *) {
            content
                .listRowSeparator(.hidden)
                .overlay(
                    Group {
                        Rectangle()
                            .fill(Color.semantic.light)
                            .frame(height: 1.pt)
                            .frame(maxWidth: .infinity)
                    },
                    alignment: .top
                )
        } else {
            content
        }
    }
}
