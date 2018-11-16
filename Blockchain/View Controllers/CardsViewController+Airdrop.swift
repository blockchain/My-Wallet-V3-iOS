//
//  CardsViewController+Airdrop.swift
//  Blockchain
//
//  Created by Chris Arriola on 10/31/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

extension CardsViewController {
    @objc func reloadAllCards() {
        // Ignoring the disposable here since it can't be stored in CardsViewController.m/.h
        // since RxSwift doesn't work in Obj-C.
        _ = BlockchainDataRepository.shared.nabuUser
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] nabuUser in
                guard let strongSelf = self else { return }
                let didShowAirdropAndKycCards = strongSelf.showAirdropAndKycCards(nabuUser: nabuUser)
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

    private func showAirdropAndKycCards(nabuUser: NabuUser) -> Bool {
        let airdropConfig = AppFeatureConfigurator.shared.configuration(for: .stellarAirdrop)
        let appSettings = BlockchainSettings.App.shared
        let onboardingSettings = BlockchainSettings.Onboarding.shared

        let shouldShowStellarAirdropCard = airdropConfig.isEnabled &&
            !onboardingSettings.hasSeenAirdropJoinWaitlistCard &&
            !appSettings.didTapOnAirdropDeepLink
        let shouldShowContinutKYCAnnouncementCard = appSettings.isCompletingKyc
        let shouldShowAirdropPending = airdropConfig.isEnabled &&
            appSettings.didTapOnAirdropDeepLink &&
            nabuUser.status == .approved &&
            !appSettings.didSeeAirdropPending

        if shouldShowAirdropPending {
            showAirdropPending()
            return true
        } else if shouldShowContinutKYCAnnouncementCard {
            showContinueKycCard()
            return true
        } else if shouldShowStellarAirdropCard {
            showStellarAirdropCard()
            return true
        }
        return false
    }

    private func showAirdropPending() {
        let model = AnnouncementCardViewModel.airdropOnItsWay(action: {}, onClose: { [weak self] in
            BlockchainSettings.App.shared.didSeeAirdropPending = true
            self?.animateHideCards()
        })
        showSingleCard(with: model)
    }

    private func showStellarAirdropCard() {
        let model = AnnouncementCardViewModel.joinAirdropWaitlist(action: {
            UIApplication.shared.openWebView(
                url: Constants.Url.airdropWaitlist,
                title: LocalizationConstants.Stellar.claimYourFreeXLMNow,
                presentingViewController: AppCoordinator.shared.tabControllerManager
            )
        }, onClose: { [weak self] in
            BlockchainSettings.Onboarding.shared.hasSeenAirdropJoinWaitlistCard = true
            self?.animateHideCards()
        })
        showSingleCard(with: model)
    }

    private func showContinueKycCard() {
        let appSettings = BlockchainSettings.App.shared
        let didTapAirdrop = appSettings.didTapOnAirdropDeepLink
        let model = AnnouncementCardViewModel.continueWithKYC(isAirdropUser: didTapAirdrop, action: {
            KYCCoordinator.shared.start(from: AppCoordinator.shared.tabControllerManager)
        }, onClose: { [weak self] in
            appSettings.isCompletingKyc = false
            self?.animateHideCards()
        })
        showSingleCard(with: model)
    }
}
