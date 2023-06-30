// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import BlockchainUI
import DIKit
import Examples
import SwiftUI

// swiftlint:disable force_try
public protocol NetworkDebugScreenProvider {
    @ViewBuilder func buildDebugView() -> AnyView
}

struct DebugView: View {

    @BlockchainApp var app

    var window: UIWindow?
    @State var isPresentingPulse: Bool = false
    @State var layoutDirection: LayoutDirection = .leftToRight

    var body: some View {
        PrimaryNavigationView {
            DividedVStack {
                PrimaryNavigationLink(
                    destination: FeatureFlags()
                        .primaryNavigation(title: "⛳️ Feature Flags")
                ) {
                    PrimaryRow(title: "⛳️ Feature Flags")
                }
                PrimaryNavigationLink(
                    destination: Examples.RootView.content
                        .environment(\.layoutDirection, layoutDirection)
                        .primaryNavigation(title: "📚 Component Library") {
                            Button(layoutDirection == .leftToRight ? "➡️" : "⬅️") {
                                layoutDirection = layoutDirection == .leftToRight ? .rightToLeft : .leftToRight
                            }
                        }
                ) {
                    PrimaryRow(title: "📚 Component Library")
                }
                PrimaryRow(title: "🤖 Pulse") {
                    withAnimation {
                        isPresentingPulse = true
                    }
                }
                Spacer()
            }
            .sheet(isPresented: $isPresentingPulse.animation()) {
                Pulse()
                    .ignoresSafeArea()
                    .onDisappear {
                        withAnimation {
                            isPresentingPulse = false
                        }
                    }
            }
            .primaryNavigation(title: "Debug") {
                Button(window?.overrideUserInterfaceStyle == .dark ? "☀️" : "🌑") {
                    if let window {
                        switch window.overrideUserInterfaceStyle {
                        case .dark:
                            window.overrideUserInterfaceStyle = .light
                        default:
                            window.overrideUserInterfaceStyle = .dark
                        }
                    }
                }
            }
        }
    }
}

extension DebugView {

    struct Row: View {

        @BlockchainApp var app

        let key: Tag.Reference
        @State private var json: AnyJSON?
        @State private var isExpanded: Bool = false

        let pasteboard = UIPasteboard.general

        var body: some View {
            TableRow(
                title: {
                    Text(
                        key.string
                            .replacingOccurrences(of: ".", with: " ")
                            .replacingOccurrences(of: "_", with: " ")
                            .replacingOccurrences(of: "[", with: " ")
                            .replacingOccurrences(of: "]", with: " ")
                    )
                    .lineLimit(nil)
                    .typography(.micro.bold())
                },
                trailing: {
                    trailing()
                },
                footer: {
                    VStack {
                        Text(key.in(app).string)
                            .typography(.micro.monospaced())
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        footer()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            )
            .background(Color.semantic.background)
            .contextMenu {
                Button(
                    action: { pasteboard.string = key.string },
                    label: {
                        Label("Copy Name", systemImage: "doc.on.doc.fill")
                    }
                )
                Button(
                    action: {
                        pasteboard.string = try? json?.pretty(using: BlockchainNamespaceDecoder())
                    },
                    label: {
                        Label("Copy JSON", systemImage: "doc.on.doc.fill")
                    }
                )
                if key.tag.is(blockchain.session.state.value) {
                    Button(
                        action: { app.state.clear(key) },
                        label: {
                            Label("Clear", systemImage: "trash.fill")
                        }
                    )
                }
            }
            .bindings {
                subscribe($json, to: key)
            }
        }

        @ViewBuilder func trailing() -> some View {
            switch key {
            case blockchain.db.type.boolean:
                Toggle(isOn: binding(to: Bool.self), label: EmptyView.init)
            case blockchain.db.type.integer:
                Stepper(
                    label: EmptyView.init,
                    onIncrement: { app.state.set(key, to: (try? app.state.get(key, as: Int.self) + 1).or(0).clamped(to: 0...)) },
                    onDecrement: { app.state.set(key, to: (try? app.state.get(key, as: Int.self) - 1).or(0).clamped(to: 0...)) }
                )
            default:
                EmptyView()
            }
        }

        @ViewBuilder func footer() -> some View {
            switch key {
            case blockchain.db.type.boolean:
                EmptyView()
            case blockchain.db.type.string, blockchain.db.type.tag, blockchain.db.type.url:
                TextField(text: binding(to: String.self), label: EmptyView.init)
                    .textFieldStyle(.roundedBorder)
            case blockchain.db.type.enum:
                Picker("Pick a tag", selection: binding(to: Tag.self)) {
                    ForEach(key.tag.descendants().sorted(by: { $0.id < $1.id }), id: \.self) { tag in
                        Do {
                            try Text(tag.idRemainder(after: key.tag))
                        } catch: { _ in
                            Text(tag.id)
                        }
                        .typography(.micro)
                    }
                }
            case blockchain.db.type.number:
                TextField(
                    text: binding(to: Double.self, default: 0).transform(
                        get: { number in String(describing: number) },
                        set: { string in Double(string) ?? 0 }
                    ),
                    label: EmptyView.init
                )
                .textFieldStyle(.roundedBorder)
            case blockchain.db.type.integer:
                TextField(
                    text: binding(to: Int.self, default: 0).transform(
                        get: { number in String(describing: number) },
                        set: { string in Int(string) ?? 0 }
                    ),
                    label: EmptyView.init
                )
                .textFieldStyle(.roundedBorder)
            case blockchain.db.type.date:
                DatePicker(selection: binding(to: Date.self, default: Date()), label: EmptyView.init)
                    .datePickerStyle(CompactDatePickerStyle())
            case blockchain.ui.type.action:
                PrimaryButton(title: "Emit", action: { app.post(event: key) })
            default:
                if let json {
                    Do {
                        try Text(json.pretty(using: BlockchainNamespaceDecoder()))
                            .typography(.micro.monospaced())
                            .foregroundColor(.semantic.title)
                            .lineLimit(isExpanded ? nil : 3)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 16).fill(Color.semantic.light))
                            .onTapGesture {
                                withAnimation {
                                    isExpanded = true
                                }
                            }
                    } catch: { error in
                        Text(String(describing: error))
                            .foregroundColor(.semantic.error)
                            .typography(.micro)
                    }
                }
            }
        }

        func binding<T: Decodable & Equatable & EmptyInit>(to type: T.Type, default defaultValue: T = .init()) -> Binding<T> {
            Binding(
                get: { (try? json?.decode(T.self, using: BlockchainNamespaceDecoder())) ?? defaultValue },
                set: { newValue in Task { try await app.set(key, to: newValue) } }
            )
        }
    }

    struct FeatureFlags: View {

        @BlockchainApp var app
        @State private var observations: [Tag.Reference?] = []

        var body: some View {
            ScrollView {
                LazyVStack {
                    ForEach(observations.compacted().array, id: \.self) { key in
                        Row(key: key)
                        PrimaryDivider()
                    }
                    PrimaryButton(title: "Reset to default") {
                        app.remoteConfiguration.clear()
                    }
                    .padding()
                }
            }
            .bindings {
                subscribe($observations, to: blockchain.app.configuration.debug.observers)
            }
        }
    }
}

struct Pulse: View {
    @Inject var networkDebugScreenProvider: NetworkDebugScreenProvider

    var body: some View {
        networkDebugScreenProvider.buildDebugView()
    }
}

extension Session.RemoteConfiguration {

    func binding(_ event: Tag.Event) -> Binding<Any?> {
        Binding(
            get: { [unowned self] in try? get(event) },
            set: { [unowned self] newValue in override(event, with: newValue as Any) }
        )
    }
}

extension Session.State {

    func binding(_ event: Tag.Event) -> Binding<Any?> {
        Binding(
            get: { [unowned self] in try? get(event) },
            set: { [unowned self] newValue in set(event, to: newValue as Any) }
        )
    }
}
