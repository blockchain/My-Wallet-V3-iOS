// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

extension View {

    @available(iOS 15.0, *)
    public func synchronize<Value>(
        _ first: Binding<Value>,
        _ second: FocusState<Value>.Binding
    ) -> some View {
        self
            .onChange(of: first.wrappedValue) { second.wrappedValue = $0 }
            .onChange(of: second.wrappedValue) { first.wrappedValue = $0 }
    }
}
