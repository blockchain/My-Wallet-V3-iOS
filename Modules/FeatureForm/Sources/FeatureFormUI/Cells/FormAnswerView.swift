// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import FeatureFormDomain
import Foundation
import SwiftUI

struct FormRecursiveAnswerView<Content: View>: View {

    let title: String
    @Binding var answer: FormAnswer
    @Binding var showAnswerState: Bool
    let fieldConfiguration: PrimaryFormFieldConfiguration
    let content: () -> Content

    var body: some View {
        VStack(spacing: Spacing.padding1) {
            content()

            if answer.checked == true, answer.children?.isEmpty == false {
                FormSingleSelectionAnswersView(
                    title: title,
                    answers: $answer.children ?? [],
                    showAnswersState: $showAnswerState,
                    fieldConfiguration: fieldConfiguration
                )
                .padding([.leading, .vertical], Spacing.padding2)
            }
        }
    }
}

struct FormOpenEndedAnswerView: View {

    @Binding var answer: FormAnswer
    @Binding var showAnswerState: Bool
    @State var isFirstResponder: Bool = false
    let fieldConfiguration: PrimaryFormFieldConfiguration
    var isEnabled: Bool { answer.isEnabled ?? true }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.padding1) {
            if let text = answer.text {
                Text(text)
                    .typography(.paragraph2)
                    .foregroundColor(.semantic.body)
            }
            let fieldConfiguration = fieldConfiguration(answer.id)
            let textBinding = Binding<String>(
                get: {
                    answer.input ?? ""
                },
                set: {
                    answer.input = $0
                    guard let text = fieldConfiguration.onTextChange?($0) else {
                        return
                    }
                    answer.input = text
                }
            )
            Input(
                text: textBinding,
                isFirstResponder: $isFirstResponder,
                shouldResignFirstResponderOnReturn: true,
                placeholder: answer.hint,
                defaultBorderColor: .clear,
                prefix: answer.prefixInputText,
                prefixConfig: fieldConfiguration.inputPrefixConfig,
                state: showAnswerState ? answer.inputState : .default,
                configuration: { textField in
                    let config = fieldConfiguration
                    textField.autocorrectionType = config.textAutocorrectionType
                    textField.keyboardType = config.keyboardType
                    textField.textContentType = config.textContentType
                },
                onFieldTapped: fieldConfiguration.onFieldTapped
            )
            .disabled(!isEnabled)
            .accessibilityIdentifier(answer.id)

            if let bottomButton = fieldConfiguration.bottomButton {
                FormAnswerBottomButtonView(
                    leadingPrefixText: bottomButton.leadingPrefixText,
                    title: bottomButton.title,
                    action: bottomButton.action
                )
                .padding(.top, 12.pt)
            }
        }
    }
}

struct FormAnswerBottomButtonView: View {

    let leadingPrefixText: String?
    let title: String
    let action: () -> Void

    var body: some View {
        HStack(spacing: 2.5.pt) {
            Spacer()
            if let leadingPrefixText {
                Text(leadingPrefixText)
                    .typography(.caption1)
            }
            Button(title, action: action)
                .typography(.caption1)
            Spacer()
        }
    }
}

struct FormSingleSelectionAnswerView: View {

    let title: String
    @Binding var answer: FormAnswer
    @Binding var showAnswerState: Bool
    let fieldConfiguration: PrimaryFormFieldConfiguration

    var body: some View {
        FormRecursiveAnswerView(
            title: title,
            answer: $answer,
            showAnswerState: $showAnswerState,
            fieldConfiguration: fieldConfiguration
        ) {
            HStack(spacing: Spacing.padding1) {
                if let text = answer.text {
                    Text(text)
                        .typography(.paragraph2)
                        .foregroundColor(.semantic.body)
                }

                Spacer()

                Radio(isOn: $answer.checked ?? false)
            }
            .padding(Spacing.padding2)
            .background(
                RoundedRectangle(cornerRadius: Spacing.buttonBorderRadius)
                    .fill(Color.semantic.background)
            )
            .contentShape(Rectangle())
            .onTapGesture {
                answer.checked = true
            }
            .accessibilityIdentifier(answer.id)
            .accessibilityElement(children: .contain)
        }
    }
}

struct FormMultipleSelectionAnswerView: View {

    let title: String
    @Binding var answer: FormAnswer
    @Binding var showAnswerState: Bool
    let fieldConfiguration: PrimaryFormFieldConfiguration

    var body: some View {
        FormRecursiveAnswerView(
            title: title,
            answer: $answer,
            showAnswerState: $showAnswerState,
            fieldConfiguration: fieldConfiguration
        ) {
            HStack(spacing: Spacing.padding1) {
                if let text = answer.text {
                    Text(text)
                        .typography(.paragraph2)
                        .foregroundColor(.semantic.body)
                }

                Spacer()

                Checkbox(isOn: $answer.checked ?? false)
            }
            .padding(Spacing.padding2)
            .background(
                RoundedRectangle(cornerRadius: Spacing.buttonBorderRadius)
                    .fill(Color.semantic.background)
            )
            .contentShape(Rectangle())
            .onTapGesture {
                answer.checked?.toggle()
            }
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier(answer.id)
        }
    }
}

struct FormAnswerView_Previews: PreviewProvider {

    static var previews: some View {
        PreviewHelper(
            answer: FormAnswer(
                id: "a1",
                type: .openEnded,
                text: "Answer 1",
                children: nil,
                input: nil,
                hint: "Placeholder",
                regex: nil,
                checked: nil
            ),
            showAnswerState: false
        )

        PreviewHelper(
            answer: FormAnswer(
                id: "q1-a1",
                type: .openEnded,
                text: "Answer 1",
                children: [
                    FormAnswer(
                        id: "q1-a1-a1",
                        type: .selection,
                        text: "Child Answer 1",
                        children: nil,
                        input: nil,
                        hint: nil,
                        regex: nil,
                        checked: nil
                    ),
                    FormAnswer(
                        id: "q1-a1-a2",
                        type: .selection,
                        text: "Child Answer 2",
                        children: nil,
                        input: nil,
                        hint: nil,
                        regex: nil,
                        checked: nil
                    )
                ],
                input: nil,
                hint: nil,
                regex: nil,
                checked: true
            ),
            showAnswerState: false
        )
    }

    struct PreviewHelper: View {

        @State var answer: FormAnswer
        @State var showAnswerState: Bool

        var body: some View {
            VStack(spacing: Spacing.padding1) {
                FormOpenEndedAnswerView(
                    answer: $answer,
                    showAnswerState: $showAnswerState,
                    fieldConfiguration: defaultFieldConfiguration
                )
                FormSingleSelectionAnswerView(
                    title: "Title",
                    answer: $answer,
                    showAnswerState: $showAnswerState,
                    fieldConfiguration: defaultFieldConfiguration
                )
                FormMultipleSelectionAnswerView(
                    title: "Title",
                    answer: $answer,
                    showAnswerState: $showAnswerState,
                    fieldConfiguration: defaultFieldConfiguration
                )
            }
            .padding()
            .background(Color.semantic.light.ignoresSafeArea())
        }
    }
}

extension FormAnswer {
    var answerBackgroundStrokeColor: Color {
        switch isValid {
        case true:
            return .semantic.medium
        case false:
            return .semantic.error
        }
    }

    fileprivate var inputState: InputState {
        switch isValid {
        case true:
            return .default
        case false:
            return .error
        }
    }
}
