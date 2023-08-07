// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Extensions
import FeatureFormDomain
import Localization
import SwiftUI

public enum PrimaryFormSubmitButtonMode {
    case onlyEnabledWhenAllAnswersValid
    case submitButtonAlwaysEnabled // open ended answers are validated and shown in red if not valid
}

public enum SubmitButtonLocation {
    case inTheEndOfTheForm // only visible when user scrolls to the end of form
    case attachedToBottomOfScreen(footerText: String? = nil, hasDivider: Bool = false) // always visible in the bottom of screen
}

public typealias PrimaryFormFieldConfiguration = (String) -> FieldConfiguation
public let defaultFieldConfiguration: PrimaryFormFieldConfiguration = { _ in .init() }

public struct PrimaryForm<Header: View>: View {

    @TransactionBinding private var form: FeatureFormDomain.Form
    private let my: FeatureFormDomain.Form

    private let submitActionTitle: String
    private let submitActionLoading: Bool
    private let submitAction: () -> Void
    private let submitButtonMode: PrimaryFormSubmitButtonMode
    private let submitButtonLocation: SubmitButtonLocation
    private let headerIcon: () -> Header
    private let fieldConfiguration: PrimaryFormFieldConfiguration

    public init(
        form: Binding<FeatureFormDomain.Form>,
        submitActionTitle: String,
        submitActionLoading: Bool,
        submitAction: @escaping () -> Void,
        submitButtonMode: PrimaryFormSubmitButtonMode = .onlyEnabledWhenAllAnswersValid,
        submitButtonLocation: SubmitButtonLocation = .inTheEndOfTheForm,
        fieldConfiguration: @escaping PrimaryFormFieldConfiguration = defaultFieldConfiguration,
        @ViewBuilder headerIcon: @escaping () -> Header
    ) {
        my = form.wrappedValue
        _form = form.transaction()
        self.submitActionTitle = submitActionTitle
        self.submitActionLoading = submitActionLoading
        self.submitAction = submitAction
        self.submitButtonMode = submitButtonMode
        self.submitButtonLocation = submitButtonLocation
        self.fieldConfiguration = fieldConfiguration
        self.headerIcon = headerIcon
    }

    @State var page: Int = 0

    public var body: some View {
        TabView(selection: $page) {
            ForEach(my.pages) { page in
                let id = my.pages.firstIndex(of: page)!
                let next = my.pages.index(after: id)
                let isLastPage = next == my.pages.endIndex
                PrimaryFormPage<Header>(
                    form: $form.pages[id],
                    submitActionTitle: isLastPage ? submitActionTitle : LocalizationConstants.next,
                    submitActionLoading: submitActionLoading,
                    submitAction: {
                        if isLastPage {
                            $form.commit()
                            submitAction()
                        } else {
                            withAnimation { self.page = next }
                        }
                    },
                    submitButtonMode: submitButtonMode,
                    submitButtonLocation: submitButtonLocation,
                    headerIcon: headerIcon
                )
                .tag(id)
            }
        }
        .findScrollView { scrollView in
            scrollView.isScrollEnabled = false
        }
        .background(Color.semantic.light)
        .tabViewStyle(.page(indexDisplayMode: .never))
        .onChange(of: my) { pages in form = pages }
    }
}

public struct PrimaryFormPage<Header: View>: View {

    @Binding private var form: FeatureFormDomain.FormPage
    @State private var showAnswersState: Bool = false

    private let submitActionTitle: String
    private let submitActionLoading: Bool
    private let submitAction: () -> Void
    private let submitButtonMode: PrimaryFormSubmitButtonMode
    private let submitButtonLocation: SubmitButtonLocation
    private let headerIcon: () -> Header
    private let fieldConfiguration: PrimaryFormFieldConfiguration

    public init(
        form: Binding<FeatureFormDomain.FormPage>,
        submitActionTitle: String,
        submitActionLoading: Bool,
        submitAction: @escaping () -> Void,
        submitButtonMode: PrimaryFormSubmitButtonMode = .onlyEnabledWhenAllAnswersValid,
        submitButtonLocation: SubmitButtonLocation = .inTheEndOfTheForm,
        fieldConfiguration: @escaping PrimaryFormFieldConfiguration = defaultFieldConfiguration,
        @ViewBuilder headerIcon: @escaping () -> Header
    ) {
        _form = form
        self.submitActionTitle = submitActionTitle
        self.submitActionLoading = submitActionLoading
        self.submitAction = submitAction
        self.submitButtonMode = submitButtonMode
        self.submitButtonLocation = submitButtonLocation
        self.fieldConfiguration = fieldConfiguration
        self.headerIcon = headerIcon
    }

    public var body: some View {
        let isSubmitButtonDisabled: Bool = {
            switch submitButtonMode {
            case .onlyEnabledWhenAllAnswersValid:
                return !form.nodes.isValidForm
            case .submitButtonAlwaysEnabled:
                return false
            }
        }()
        ScrollView {
            VStack(spacing: Spacing.padding4) {
                if let header = form.header {
                    VStack(spacing: Spacing.padding3) {
                        headerIcon()
                        if header.title.isNotEmpty {
                            Text(header.title)
                                .typography(.title3)
                        }
                        if header.description.isNotEmpty {
                            Text(header.description)
                                .typography(.body1)
                                .foregroundColor(.semantic.body)
                        }
                    }
                    .multilineTextAlignment(.center)
                    .foregroundColor(.semantic.title)
                }

                ForEach($form.nodes) { question in
                    FormQuestionView(
                        question: question,
                        showAnswersState: .constant(false),
                        fieldConfiguration: fieldConfiguration
                    )
                }
                if case .inTheEndOfTheForm = submitButtonLocation {
                    primaryButton
                        .disabled(isSubmitButtonDisabled)
                }
            }
            .padding(Spacing.padding3)
            .contentShape(Rectangle())
            .onTapGesture {
                stopEditing()
            }
        }
        if case .attachedToBottomOfScreen(let footerText, let hasDivider) = submitButtonLocation {
            VStack(spacing: Spacing.padding2) {
                if hasDivider {
                    Divider()
                }
                VStack(spacing: Spacing.padding2) {
                    if let footerText {
                        Text(footerText)
                            .multilineTextAlignment(.center)
                            .typography(.paragraph1)
                            .foregroundColor(.semantic.text)
                            .padding(.bottom, Spacing.textSpacing)
                    }

                    primaryButton
                        .disabled(isSubmitButtonDisabled)
                }
                .padding([.horizontal])
            }
            .frame(alignment: .bottom)
            .padding([.bottom])
            .backgroundWithWhiteShadow
        }
    }

    private var primaryButton: some View {
        PrimaryButton(
            title: submitActionTitle,
            isLoading: submitActionLoading,
            action: {
                switch submitButtonMode {
                case .onlyEnabledWhenAllAnswersValid:
                    submitAction()
                case .submitButtonAlwaysEnabled:
                    showAnswersState = true
                    if form.nodes.isValidForm {
                        submitAction()
                    }
                }
            }
        )
    }
}

extension PrimaryForm where Header == EmptyView {

    public init(
        form: Binding<FeatureFormDomain.Form>,
        submitActionTitle: String,
        submitActionLoading: Bool,
        submitAction: @escaping () -> Void
    ) {
        self.init(
            form: form,
            submitActionTitle: submitActionTitle,
            submitActionLoading: submitActionLoading,
            submitAction: submitAction,
            headerIcon: EmptyView.init
        )
    }
}

struct PrimaryForm_Previews: PreviewProvider {

    static var form: FeatureFormDomain.Form {
        let jsonData = formPreviewJSON.data(using: .utf8)!
        // swiftlint:disable:next force_try
        do {
            return try JSONDecoder().decode(FeatureFormDomain.Form.self, from: jsonData)
        } catch {
            fatalError("\(error)")
        }
    }

    static var previews: some View {
        PreviewHelper(form: form)
    }

    struct PreviewHelper: View {

        @State var form: FeatureFormDomain.Form

        var body: some View {
            PrimaryForm(
                form: $form,
                submitActionTitle: "Submit",
                submitActionLoading: false,
                submitAction: { print("Submit") },
                headerIcon: {}
            )
        }
    }
}

#if canImport(UIKit)
import UIKit
extension View {

    func stopEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#else
extension View {

    func stopEditing() {
        // out of luck
    }
}
#endif
