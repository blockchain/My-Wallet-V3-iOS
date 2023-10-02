// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

extension View {

    public func synchronize<Value>(
        _ first: Binding<Value>,
        _ second: FocusState<Value>.Binding
    ) -> some View {
        onChange(of: first.wrappedValue) { second.wrappedValue = $0 }
            .onChange(of: second.wrappedValue) { first.wrappedValue = $0 }
    }

    public func synchronize<Value: Equatable>(
        _ first: Binding<Value>,
        _ second: Binding<Value>
    ) -> some View {
        onChange(of: first.wrappedValue) { second.wrappedValue = $0 }
            .onChange(of: second.wrappedValue) { first.wrappedValue = $0 }
    }
}

extension FocusState.Binding {

    @inlinable public var binding: SwiftUI.Binding<Value> {
        Binding(
            get: { wrappedValue },
            set: { newValue in wrappedValue = newValue }
        )
    }
}
