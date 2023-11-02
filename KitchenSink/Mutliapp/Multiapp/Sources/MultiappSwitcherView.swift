//
//  MultiappSwitcherView.swift
//  MultiappExample
//
//  Created by Dimitris Chatzieleftheriou on 22/09/2022.
//

import BlockchainComponentLibrary
import SwiftUI

// Needs to be combined with current mode...
enum Mode: Equatable {
    case trading
    case defi

    var isTrading: Bool {
        self == .trading
    }

    var isDefi: Bool {
        self == .defi
    }

    var backgroundGradient: [Color] {
        switch self {
        case .trading:
            [Color(hex: "#FF0297"), Color(hex: "#AE22AD")]
        case .defi:
            [Color(hex: "#6B39BD"), Color(hex: "#2878D4")]
        }
    }

    var title: String {
        switch self {
        case .trading:
            "Trading"
        case .defi:
            "DeFi"
        }
    }
}

struct MutliappSwitcherView: View {
    @Binding var currentSelection: Mode

    var body: some View {
        HStack(spacing: 32) {
            MutliappModeButton(
                mode: .trading,
                isSelected: .constant(currentSelection.isTrading),
                action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        currentSelection = .trading
                    }
                }
            )
            MutliappModeButton(
                mode: .defi,
                isSelected: .constant(currentSelection.isDefi),
                action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        currentSelection = .defi
                    }
                }
            )
        }
        .padding(.bottom, Spacing.padding1)
        .overlayPreferenceValue(MultiappModePreferenceKey.self) { preferences in
            GeometryReader { proxy in
                if let selected = preferences.first(where: { $0.mode == currentSelection }) {
                    let frame = proxy[selected.anchor]

                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .frame(width: 16, height: 4)
                        .position(x: frame.midX, y: frame.maxY)
                        .foregroundColor(.white)
                        .padding(.top, 4)
                }
            }
        }
    }
}

struct MultiappModePreferences: Equatable {
    let mode: Mode
    let anchor: Anchor<CGRect>
}

struct MultiappModePreferenceKey: PreferenceKey {
    static let defaultValue = [MultiappModePreferences]()
    static func reduce(
        value: inout [MultiappModePreferences],
        nextValue: () -> [MultiappModePreferences]
    ) {
        value.append(contentsOf: nextValue())
    }
}

struct MutliappModeButton: View {

    let mode: Mode
    @Binding var isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Text(mode.title)
                .typography(.title3)
                .foregroundColor(.white)
                .bold()
                .opacity(isSelected ? 1.0 : 0.5)
        }
        .accessibilityElement()
        .anchorPreference(
            key: MultiappModePreferenceKey.self,
            value: .bounds,
            transform: { anchor in
                [MultiappModePreferences(mode: mode, anchor: anchor)]
            }
        )
        .accessibilityIdentifier(mode.title)
    }
}

struct TotalBalanceView: View {
    let balance: String
    var body: some View {
        HStack {
            Text("Total Balance")
                .typography(.paragraph1)
                .opacity(0.8)
            Text(balance)
                .typography(.paragraph2)
        }
        .foregroundColor(.white)
        .padding(.vertical, Spacing.padding1 * 0.5)
        .padding(.horizontal, Spacing.padding1)
        .overlay(
            Capsule()
                .stroke(.white, lineWidth: 1)
                .opacity(0.4)
        )
    }
}
