//
//  CardsViewController+KYC.swift
//  Blockchain
//
//  Created by Chris Arriola on 10/31/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit
import PlatformUIKit

extension CardsViewController {
    @objc func tearDownNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func registerForNotifications() {
        NotificationCenter.when(Constants.NotificationKeys.walletSetupViewControllerDismissed) { [weak self] _ in
            guard let self = self else { return }

            let hasSeenXLMModal = BlockchainSettings.Onboarding.shared.hasSeenGetFreeXlmModal
            guard !hasSeenXLMModal else {
                return
            }

            let didDeepLink = BlockchainSettings.App.shared.didTapOnAirdropDeepLink
            guard !didDeepLink else {
                return
            }

            let isPopUpEnabled = AppFeatureConfigurator.shared.configuration(for: .stellarAirdropPopup).isEnabled
            guard isPopUpEnabled else {
                return
            }

            self.showStellarModalPromptForKyc()
        }
    }
    
    @objc func reloadAllCards() {
        // Ignoring the disposable here since it can't be stored in CardsViewController.m/.h
        // since RxSwift doesn't work in Obj-C.
        guard WalletManager.shared.wallet.isInitialized() == true else { return }
        let user = BlockchainDataRepository.shared.nabuUser
        let tiers = BlockchainDataRepository.shared.tiers
        let hasExecutedTrades = ExchangeService.shared.hasExecutedTrades().asObservable()
        _ = Observable.zip(user, tiers, hasExecutedTrades)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] nabuUser, tiers, hasTrades in
                guard let strongSelf = self else { return }
                let canShowSwapCTA = nabuUser.swapApproved()
                let shouldHideSwapCTA = BlockchainSettings.App.shared.shouldHideSwapCard
                
                /// We display the `Swap` card if the user has not submitted a trade,
                /// has not hidden the card before, and if the user is at least tier1 approved.
                let displaySwapCTA = (hasTrades == false && shouldHideSwapCTA == false && canShowSwapCTA)
                if displaySwapCTA {
                    strongSelf.showSwapCTA()
                }
                
                /// If the user has traded before we need to set this flag as this is the only way
                /// `CardsViewController` can determine if it needs to show the `Swap` card.
                if hasTrades == true {
                    BlockchainSettings.App.shared.shouldHideSwapCard = true
                }
                
                let didShowAirdropAndKycCards = strongSelf.showAirdropAndKycCards(nabuUser: nabuUser, tiersResponse: tiers)
                if !didShowAirdropAndKycCards {
                    strongSelf.reloadWelcomeCards()
                }
                strongSelf.dashboardScrollView.contentSize = CGSize(
                    width: strongSelf.view.frame.size.width,
                    height: strongSelf.dashboardContentView.frame.size.height + strongSelf.cardsViewHeight
                )
            }, onError: { [weak self] error in
                guard let strongSelf = self else { return }
                Logger.shared.error("Failed to get nabu user")
                strongSelf.reloadWelcomeCards()
                strongSelf.dashboardScrollView.contentSize = CGSize(
                    width: strongSelf.view.frame.size.width,
                    height: strongSelf.dashboardContentView.frame.size.height + strongSelf.cardsViewHeight
                )
            })
    }

    private func showAirdropAndKycCards(nabuUser: NabuUser, tiersResponse: KYCUserTiersResponse) -> Bool {
        // appSettings.isPinSet needs to be checked in order to prevent
        // showing AlertView sheets over the PIN screen when creating a wallet
        let appSettings = BlockchainSettings.App.shared
        guard appSettings.isPinSet == true else { return false }

        let airdropConfig = AppFeatureConfigurator.shared.configuration(for: .stellarAirdrop)
        let stellarPopupConfig = AppFeatureConfigurator.shared.configuration(for: .stellarAirdropPopup)
        let coinifyConfig = AppFeatureConfigurator.shared.configuration(for: .notifyCoinifyUserToKyc)
        let kycSettings = KYCSettings.shared
        let onboardingSettings = BlockchainSettings.Onboarding.shared

        let shouldShowStellarAirdropCard = airdropConfig.isEnabled &&
            !onboardingSettings.hasSeenAirdropJoinWaitlistCard &&
            !appSettings.didTapOnAirdropDeepLink &&
            stellarPopupConfig.isEnabled
        let shouldShowContinueKYCAnnouncementCard = kycSettings.isCompletingKyc
        let shouldShowStellarView = airdropConfig.isEnabled &&
            !appSettings.didTapOnAirdropDeepLink &&
            tiersResponse.canCompleteTier2
        let shouldShowCoinifyKycModal = coinifyConfig.isEnabled &&
            tiersResponse.canCompleteTier2 &&
            WalletManager.shared.wallet.isCoinifyTrader() &&
            !didShowCoinifyKycModal
        let hasSeenStellarRegistrationAlert = onboardingSettings.hasSeenStellarAirdropRegistrationAlert
        let shouldShowStellarModalPromptForAirdropRegistration =
            nabuUser.isSunriverAirdropRegistered == false &&
            (tiersResponse.isTier2Pending || tiersResponse.isTier2Verified) &&
            hasSeenStellarRegistrationAlert == false

        if shouldShowCoinifyKycModal {
            showCoinifyKycModal()
            return true
        } else if nabuUser.needsDocumentResubmission != nil {
            showUploadDocumentsCard()
            return true
        } else if shouldShowContinueKYCAnnouncementCard {
            showContinueKycCard(isAirdropUser: nabuUser.isSunriverAirdropRegistered)
            return true
        } else if shouldShowStellarView {
            let hasDismissedProfileCard = onboardingSettings.hasDismissedCompleteYourProfileCard
            if onboardingSettings.hasSeenGetFreeXlmModal == true,
                hasDismissedProfileCard == false {
                showCompleteYourProfileCard()
            }
            return true
        } else if shouldShowStellarModalPromptForAirdropRegistration {
            showStellarModalPromptForAirdropRegistration()
            return true
        } else if shouldShowStellarAirdropCard {
            showStellarAirdropCard()
            return true
        }
        return false
    }

    private func showStellarAirdropCard() {
        let model = AnnouncementCardViewModel.joinAirdropWaitlist(action: {
            self.stellarAirdropCardActionTapped()
        }, onClose: { [weak self] in
            BlockchainSettings.Onboarding.shared.hasSeenAirdropJoinWaitlistCard = true
            self?.animateHideCards()
        })
        showSingleCard(with: model)
    }
    
    private func showSwapCTA() {
        let model = AnnouncementCardViewModel.swapCTA(action: {
            let tabController = AppCoordinator.shared.tabControllerManager
            tabController.swapTapped(nil)
        }) { [weak self] in
            BlockchainSettings.App.shared.shouldHideSwapCard = true
            self?.animateHideCards()
        }
        showSingleCard(with: model)
    }

    private func showContinueKycCard(isAirdropUser: Bool) {
        let kycSettings = KYCSettings.shared
        let model = AnnouncementCardViewModel.continueWithKYC(isAirdropUser: isAirdropUser, action: { [unowned self] in
            self.continueKyc()
        }, onClose: { [weak self] in
            kycSettings.isCompletingKyc = false
            self?.animateHideCards()
        })
        showSingleCard(with: model)
    }

    private func continueKyc() {
        // Ignoring the disposable here since it can't be stored in CardsViewController.m/.h
        // since RxSwift doesn't work in Obj-C.
        _ = BlockchainDataRepository.shared.fetchNabuUser()
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] user in
                guard self != nil else {
                    return
                }
                let tier = user.tiers?.selected ?? .tier1
                KYCCoordinator.shared.start(from: AppCoordinator.shared.tabControllerManager, tier: tier)
            })
    }

    private func showCoinifyKycModal() {
        didShowCoinifyKycModal = true

        let updateNow = AlertAction(style: .confirm(LocalizationConstants.beginNow))
        let learnMore = AlertAction(style: .default(LocalizationConstants.AnnouncementCards.learnMore))
        let alertModel = AlertModel(
            headline: LocalizationConstants.AnnouncementCards.bottomSheetCoinifyInfoTitle,
            body: LocalizationConstants.AnnouncementCards.bottomSheetCoinifyInfoDescription,
            actions: [updateNow, learnMore],
            image: UIImage(named: "Icon-Information"),
            dismissable: true,
            style: .sheet
        )
        let alert = AlertView.make(with: alertModel) { action in
            switch action.style {
            case .confirm:
                self.coinifyKycActionTapped()
            case .default:
                UIApplication.shared.openSafariViewController(
                    url: Constants.Url.requiredIdentityVerificationURL,
                    presentingViewController: AppCoordinator.shared.tabControllerManager.tabViewController)
            case .dismiss:
                break
            }
        }
        alert.show()
    }

    private func showUploadDocumentsCard() {
        let model = AnnouncementCardViewModel.resubmitDocuments(action: { [unowned self] in
            self.continueKyc()
        }, onClose: { [weak self] in
            self?.animateHideCards()
        })
        showSingleCard(with: model)
    }

    private func showStellarModalPromptForKyc() {
        let getFreeXlm = AlertAction(style: .confirm(LocalizationConstants.AnnouncementCards.bottomSheetPromptForKycAction))
        let alertModel = AlertModel(
            headline: LocalizationConstants.AnnouncementCards.bottomSheetPromptForKycTitle,
            body: LocalizationConstants.AnnouncementCards.bottomSheetPromptForKycDescription,
            actions: [getFreeXlm],
            image: UIImage(named: "symbol-xlm"),
            imageTintColor: AssetType.stellar.brandColor,
            dismissable: true,
            style: .sheet
        )
        let alert = AlertView.make(with: alertModel) { action in
            switch action.style {
            case .confirm:
                BlockchainSettings.Onboarding.shared.hasSeenGetFreeXlmModal = true
                self.stellarAirdropCardActionTapped()
            case .default,
                 .dismiss:
                BlockchainSettings.Onboarding.shared.hasSeenGetFreeXlmModal = true
            }
        }
        alert.show()
    }

    private func showStellarModalPromptForAirdropRegistration() {
        let getFreeXlm = AlertAction(style: .confirm(LocalizationConstants.AnnouncementCards.bottomSheetPromptForAirdropRegistrationAction))
        let dismiss = AlertAction(style: .default(LocalizationConstants.AnnouncementCards.bottomSheetPromptForAirdropRegistrationCancel))
        let alertModel = AlertModel(
            headline: LocalizationConstants.AnnouncementCards.bottomSheetPromptForAirdropRegistrationTitle,
            body: LocalizationConstants.AnnouncementCards.bottomSheetPromptForAirdropRegistrationDescription,
            actions: [getFreeXlm, dismiss],
            image: UIImage(named: "Icon-Verified"),
            dismissable: true,
            style: .sheet
        )
        let alert = AlertView.make(with: alertModel) { action in
            BlockchainSettings.Onboarding.shared.hasSeenStellarAirdropRegistrationAlert = true
            switch action.style {
            case .confirm:
                self.stellarModalPromptForAirdropRegistrationActionTapped()
            case .default,
                 .dismiss:
                break
            }
        }
        alert.show()
    }

    private func showCompleteYourProfileCard() {
        let onboardingSettings = BlockchainSettings.Onboarding.shared
        let model = AnnouncementCardViewModel.completeYourProfile(action: { [unowned self] in
            onboardingSettings.hasDismissedCompleteYourProfileCard = true
            self.stellarAirdropCardActionTapped()
        }, onClose: { [weak self] in
            onboardingSettings.hasDismissedCompleteYourProfileCard = true
            self?.animateHideCards()
        })
        showSingleCard(with: model)
    }
}
