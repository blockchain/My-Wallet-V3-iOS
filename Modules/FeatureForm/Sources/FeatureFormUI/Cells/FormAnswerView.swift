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
                .padding([.leading], Spacing.padding2)
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
                onFieldTapped: fieldConfiguration.onFieldTapped
            )
            .disabled(!isEnabled)
            .accessibilityIdentifier(answer.id)
            .autocorrectionDisabled(fieldConfiguration.textAutocorrectionType == .no)
            .keyboardType(fieldConfiguration.keyboardType)
            .textContentType(fieldConfiguration.textContentType)

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
            HStack {
                Radio(isOn: $answer.checked ?? false)
                if let text = answer.text {
                    Text(text)
                        .typography(.paragraph2)
                        .foregroundColor(.semantic.title)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
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

struct FormMultipleSelectionAnswerSingleTileView: View {

    let title: String
    @Binding var answer: FormAnswer
    @Binding var showAnswerState: Bool
    let fieldConfiguration: PrimaryFormFieldConfiguration

    var body: some View {
       Group {
           if let text = answer.text {
               if answer.checked == true {
                   Text(text).typography(.paragraph2).foregroundColor(.white)
               } else {
                   Text(text).typography(.paragraph2).foregroundColor(.semantic.primary)
               }
           }
       }
       .padding(8.pt)
       .background(
           Group {
               let background = RoundedRectangle(cornerRadius: 4)
               if answer.checked == true {
                   background.fill(Color.semantic.primary)
               } else {
                   background.fill(Color.semantic.background)
               }
           }
       )
       .contentShape(Rectangle())
       .onTapGesture  {
           answer.checked = !answer.checked.or(default: false)
       }
       .accessibilityElement(children: .combine)
       .accessibilityIdentifier(answer.id)
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
            HStack {
                Checkbox(isOn: $answer.checked ?? false)
                if let text = answer.text {
                    Text(text)
                        .typography(.paragraph2)
                        .foregroundColor(.semantic.title)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
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

struct FormAnswerView_Previews: PreviewProvider {

    static var previews: some View {
        FormOpenEndedAnswerView(
            answer: .constant(
                FormAnswer(
                    id: "a1",
                    type: .openEnded,
                    text: "Answer 1",
                    children: nil,
                    input: nil,
                    hint: "Placeholder",
                    regex: nil,
                    checked: nil
                )
            ),
            showAnswerState: .constant(false),
            fieldConfiguration: defaultFieldConfiguration
        )

        PreviewHelper(
            showAnswerState: false
        )
    }

    struct PreviewHelper: View {

        @State var answer1 = FormAnswer(
            id: "a1",
            type: .openEnded,
            text: "Answer 1",
            children: nil,
            input: nil,
            hint: "Placeholder",
            regex: nil,
            checked: nil
        )

        @State var answer2 = FormAnswer(
            id: "q1-a2",
            type: .openEnded,
            text: "Answer 2",
            children: [
                FormAnswer(
                    id: "q1-a2-a1",
                    type: .selection,
                    text: "Child Answer 2.1",
                    children: nil,
                    input: nil,
                    hint: nil,
                    regex: nil,
                    checked: nil
                ),
                FormAnswer(
                    id: "q1-a2-a2",
                    type: .selection,
                    text: "Child Answer 2.2",
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
        )

        @State var answer3 = FormAnswer(
            id: "q1-a3",
            type: .selection,
            text: "Answer 3",
            children: [
                FormAnswer(
                    id: "q1-a3-a1",
                    type: .selection,
                    text: "Child Answer 3.1",
                    children: nil,
                    input: nil,
                    hint: nil,
                    regex: nil,
                    checked: nil
                ),
                FormAnswer(
                    id: "q1-a3-a2",
                    type: .selection,
                    text: "Child Answer 3.2",
                    children: nil,
                    input: nil,
                    hint: nil,
                    regex: nil,
                    checked: nil
                ),
                FormAnswer(
                    id: "q1-a3-a3",
                    type: .selection,
                    text: "3.3",
                    children: nil,
                    input: nil,
                    hint: nil,
                    regex: nil,
                    checked: nil
                ),
                FormAnswer(
                    id: "q1-a3-a4",
                    type: .selection,
                    text: "Answer 3.4",
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
        )

        @State var showAnswerState: Bool

        var body: some View {
            VStack(spacing: Spacing.padding1) {
                FormOpenEndedAnswerView(
                    answer: $answer1,
                    showAnswerState: $showAnswerState,
                    fieldConfiguration: defaultFieldConfiguration
                )
                FormSingleSelectionAnswerView(
                    title: "Title",
                    answer: $answer2,
                    showAnswerState: $showAnswerState,
                    fieldConfiguration: defaultFieldConfiguration
                )
                FormMultipleSelectionAnswersView(
                    title: answer3.text ?? "Title",
                    answers: $answer3.children.or(default: []),
                    showAnswersState: $showAnswerState,
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
