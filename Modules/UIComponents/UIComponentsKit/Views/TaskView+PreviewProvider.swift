// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary

extension UITaskView_Previews {

    static func payment() -> UITask {
        let header = UITask.group(
            UITask.label("Approve Your Payment")
                .typography(.title3),
            UITask.spacer(4.vmin),
            UITask.group(
                UITask.divider(),
                UITask.row("Payment total", value: "£100.00")
                    .padding([.top, .bottom], 8.pt),
                UITask.divider()
            ),
            UITask.spacer(4.vmin)
        )

        let information = UITask.section(
            header: "Payment Information",
            expandable: true,
            tasks: [
                UITask.row("Bank name", value: "Monzo"),
                UITask.row("Sort Code", value: "04-00-04"),
                UITask.row("Account Number", value: "94936804")
            ]
        )

        return UITask.group(
            header,
            information
        )
    }

    static func safeconnect() -> UITask {
        UITask.group(
            UITask.section(
                header: "Data Sharing",
                expandable: true,
                tasks: [
                    UITask.label("SafeConnect will retrieve your bank data based on your request and provide this information to Blockchain.com")
                ]
            ),
            UITask.section(
                header: "Secure Connection",
                expandable: true,
                tasks: [
                    UITask.label("Data is securely retrieved in read-only format and only for the duration agreed with you. You have the right to withdraw your consent at any time.")
                ]
            ),
            UITask.section(
                header: "FCA Authorisation",
                expandable: true,
                tasks: [
                    .label("Blockchain.com is an agent of SafeConnect Ltd. SafeConnect Ltd is authorised and regulated by the Financial Conduct Authority under the Payment Service Regulations 2017 [827001] for the provision of Account Information and Payment Initiation services."),
                    .label("In order to share your Monzo data with Blockchain.com, you will now be securely redirected to your bank to confirm your consent for SafeConnect to read the following information:\n\n• Identification details\n• Account(s) details")
                ]
            ),
            UITask.section(
                header: "About the access",
                expandable: true,
                tasks: [
                    UITask.label("SafeConnect will then use these details with Blockchain.com solely for the purposes of buying Crypto. This access is valid until Tomorrow, you can cancel consent at any time via the Blockchain.com settings or via your bank. This request is not a one-off, you will continue to receive consent requests as older versions expire.")
                ]
            )
        )
        .typography(.paragraph1)
        .foreground(.textDetail)
    }
}
