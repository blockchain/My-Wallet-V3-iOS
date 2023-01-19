// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension Accessibility.Identifier {
    public enum Settings {
        private static let prefix = "Settings."

        public enum SettingsCell {
            private static let prefix = "\(Settings.prefix)SettingsCell."
            public static let titleLabelFormat = "\(prefix)titleLabel."
            public static let badgeView = "\(prefix)badgeView."

            public enum Common {
                public static let title = "\(SettingsCell.prefix)Plain"
                public static let titleLabelFormat = ".\(title)titleLabel."
            }

            public enum Email {
                public static let title = "\(SettingsCell.prefix)Email"
            }

            public enum BackupPhrase {
                public static let title = "\(SettingsCell.prefix)BackupPhrase"
            }

            public enum BioAuthentication {
                public static let title = "\(SettingsCell.prefix)BioAuthentication"
            }

            public enum SmallBalance {
                public static let title = "\(SettingsCell.prefix)SmallBalance"
            }

            public enum AccountLimits {
                public static let title = "\(SettingsCell.prefix)AccountLimits"
            }

            public enum Mobile {
                public static let title = "\(SettingsCell.prefix)Mobile"
            }

            public enum EmailNotifications {
                public static let title = "\(SettingsCell.prefix)EmailNotifications"
            }

            public enum ExchangeConnect {
                public static let title = "\(SettingsCell.prefix)ExchangeConnect"
            }

            public enum Currency {
                public static let title = "\(SettingsCell.prefix)PreferredCurrency"
            }

            public enum TwoStepVerification {
                public static let title = "\(SettingsCell.prefix)TwoStepVerification"
            }

            public enum CloudBackup {
                public static let title = "\(SettingsCell.prefix)CloudBackup"
            }

            public enum Referral {
                public static let title = "\(SettingsCell.prefix)Referral"
            }

            public enum CryptoDomains {
                public static let title = "\(SettingsCell.prefix)CryptoDomains"
            }
        }

        public enum LinkedCardCell {
            private static let prefix = "\(Settings.prefix)LinkedCardCell."
            public static let view = "\(prefix)view"
            public static let expiration = "\(prefix)expiration"
            public static let badgeView = "\(prefix)badgeView"
            public static let cardPrefix = "\(prefix)cardPrefix"
        }

        public enum ReferralCell {
            private static let prefix = "\(Settings.prefix)ReferralCell."
            public static let view = "\(prefix)view"
        }

        public enum AddPaymentMethodCell {
            private static let prefix = "\(Settings.prefix)AddCardCell."
            public static let disclaimer = "\(prefix)disclaimer"
        }

        public enum SwitchView {
            private static let prefix = "\(Settings.prefix)SwitchView."
            public static let SMSSwitchView = "\(prefix)SMSSwitchView"
            public static let BioSwitchView = "\(prefix)BioSwitchView"
            public static let twoFactorSwitchView = "\(prefix)twoFactorSwitchView"
            public static let cloudBackup = "\(prefix)cloudBackup"
        }

        public enum ChangePassword {
            private static let prefix = "ChangePasswordScreen."
            public static let descriptionLabel = "\(prefix)descriptionLabel"
            public static let currentPasswordTextField = "\(prefix)currentPasswordTextField"
            public static let newPasswordTextField = "\(prefix)newPasswordTextField"
            public static let confirmPasswordTextField = "\(prefix)confirmPasswordTextField"
            public static let changePasswordButton = "\(prefix)changePasswordButton"
        }

        public enum UpdateEmail {
            private static let prefix = "UpdateEmailScreen."
            public static let titleLabel = "\(prefix)titleLabel"
            public static let descriptionLabel = "\(prefix)descriptionLabel"
            public static let emailTextField = "\(prefix)emailTextField"
            public static let updateEmailButton = "\(prefix)updateEmailButton"
            public static let resendEmailButton = "\(prefix)resendEmailButton"
        }

        public enum UpdateMobile {
            private static let prefix = "UpdateMobileScreen."
            public static let descriptionLabel = "\(prefix)descriptionLabel"
            public static let disable2FALabel = "\(prefix)disable2FALabel"
            public static let textField = "\(prefix)textField"
            public static let continueButton = "\(prefix)continueButton"
            public static let updateButton = "\(prefix)updateButton"
        }

        public enum MobileCodeEntry {
            private static let prefix = "MobileCodeEntryScreen."
            public static let descriptionLabel = "\(prefix)descriptionLabel"
            public static let codeEntryField = "\(prefix)codeEntryField"
            public static let changeNumberButton = "\(prefix)changeNumberButton"
            public static let resendCodeButton = "\(prefix)resendCodeButton"
            public static let confirmButton = "\(prefix)confirmButton"
        }

        public enum WebLogin {
            private static let prefix = "WebLoginScreen."
            public static let notice = "\(prefix)notice"
            public static let showQRCodeButton = "\(prefix)securityAlertBottomLabel"
        }

        public enum About {
            private static let prefix = "AboutFooterView."
            public static let versionLabel = "\(prefix)versionLabel"
            public static let copyrightLabel = "\(prefix)copyrightLabel"
        }

        public enum RemovePaymentMethodScreen {
            private static let prefix = "RemovePaymentMethodScreen."
            public static let title = "\(prefix)titleLabel"
            public static let badge = "\(prefix)badgeImageView"
            public static let description = "\(prefix)descriptionLabel"
            public static let button = "\(prefix)button"
        }
    }
}
