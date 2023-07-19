// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import RxDataSources

struct AddNewPaymentMethodCellSectionModel: Equatable {
    var items: [AddNewPaymentMethodCellViewModelItem]
}

extension AddNewPaymentMethodCellSectionModel: SectionModelType {
    typealias Item = AddNewPaymentMethodCellViewModelItem

    init(original: AddNewPaymentMethodCellSectionModel, items: [AddNewPaymentMethodCellViewModelItem]) {
        self = original
        self.items = items
    }
}

enum AddNewPaymentMethodCellViewModelItem: Equatable {
    case paymentMethodTypeView(PaymentMethodTypeView)
    case suggestedPaymentMethod(ExplainedActionViewModel)
}
