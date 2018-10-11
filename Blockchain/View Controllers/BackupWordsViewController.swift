//
//  BackupWordsViewController.swift
//  Blockchain
//
//  Created by Sjors Provoost on 19-05-15.
//  Copyright (c) 2015 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

class BackupWordsViewController: UIViewController, SecondPasswordDelegate, UIScrollViewDelegate {
    @IBOutlet weak var wordsScrollView: UIScrollView?
    @IBOutlet weak var wordsPageControl: UIPageControl!
    @IBOutlet weak var wordsProgressLabel: UILabel!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var previousWordButton: UIButton!
    @IBOutlet weak var nextWordButton: UIButton!
    @IBOutlet var summaryLabel: UILabel!

    var wallet: Wallet?
    var wordLabels: [UILabel]!
    var isVerifying = false

    override func viewDidLoad() {
        super.viewDidLoad()
        previousWordButton.setTitle(NSLocalizedString("PREVIOUS", comment: ""), for: .normal)
        nextWordButton.setTitle(NSLocalizedString("NEXT", comment: ""), for: .normal)

        updatePreviousWordButton()

        setupInstructionLabel()

        setupWordsProgressLabel()

        wallet!.addObserver(self, forKeyPath: "recoveryPhrase", options: .new, context: nil)

        self.navigationController?.navigationBar.tintColor = .white

        wordLabel.text = ""

        updateCurrentPageLabel(0)

        wordsScrollView!.center = CGPoint(x: view.center.x, y: wordsScrollView!.center.y)
        wordsScrollView!.clipsToBounds = true
        let scrollViewWidth = CGFloat(Constants.Defaults.NumberOfRecoveryPhraseWords) * wordLabel.frame.width
        let scrollViewHeight = wordLabel.frame.height
        wordsScrollView!.contentSize = CGSize(width: scrollViewWidth, height: scrollViewHeight)
        wordsScrollView!.isUserInteractionEnabled = false

        wordLabels = [UILabel]()
        wordLabels.insert(wordLabel, at: 0)
        for idx in 1 ..< Constants.Defaults.NumberOfRecoveryPhraseWords {
            let offset: CGFloat = CGFloat(idx) * wordLabel.frame.width
            let posX = wordLabel.frame.origin.x + offset
            let posY = wordLabel.frame.origin.y
            let labelWidth = wordLabel.frame.size.width
            let labelHeight = wordLabel.frame.size.height
            let label = UILabel(frame: CGRect(x: posX, y: posY, width: labelWidth, height: labelHeight))
            label.adjustsFontSizeToFitWidth = true
            label.font = wordLabel.font
            label.textColor = wordLabel.textColor
            label.textAlignment = wordLabel.textAlignment

            wordLabel.superview?.addSubview(label)

            wordLabels.append(label)
        }

        if wallet!.needsSecondPassword() {
            self.performSegue(withIdentifier: "secondPasswordForBackup", sender: self)
        } else {
            wallet!.getRecoveryPhrase(nil)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        var bottomPadding: CGFloat = 0
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            bottomPadding = window?.safeAreaInsets.bottom ?? 0
        }

        UIView .animate(withDuration: 0.3, animations: {
            var posX: CGFloat = 0
            let posY: CGFloat = self.view.frame.size.height - bottomPadding - self.previousWordButton.frame.size.height
            let buttonWidth = (self.view.frame.size.width / 2) - 2
            var buttonHeight = self.previousWordButton.frame.size.height
            self.previousWordButton.frame = CGRect(x: 0, y: posY, width: buttonWidth, height: buttonHeight)
            posX = self.view.frame.size.width - self.previousWordButton.frame.size.width + 2
            buttonHeight = self.previousWordButton.frame.size.height
            self.nextWordButton.frame = CGRect(x: posX, y: posY, width: buttonWidth, height: buttonHeight)
        })
    }

    func setupInstructionLabel() {
        summaryLabel.font = UIFont(name: "GillSans", size: Constants.FontSizes.MediumLarge)
        summaryLabel.text = NSLocalizedString(
            "Write down the following 12 word Recovery Phrase exactly as they appear and in this order:",
            comment: "")
        summaryLabel.center = CGPoint(x: view.center.x, y: summaryLabel.center.y)
    }

    func setupWordsProgressLabel() {
        wordsProgressLabel.font = UIFont(name: "Montserrat-Regular", size: Constants.FontSizes.SmallMedium)
        wordsProgressLabel.center = CGPoint(x: view.center.x, y: wordsProgressLabel.center.y)
        wordsProgressLabel.adjustsFontSizeToFitWidth = true
    }

    func updatePreviousWordButton() {
        if wordsPageControl.currentPage == 0 {
            previousWordButton.isEnabled = false
            previousWordButton.setTitleColor(UIColor.darkGray, for: UIControl.State())
            previousWordButton.backgroundColor = .gray1
        } else {
            previousWordButton.isEnabled = true
            previousWordButton.setTitleColor(UIColor.white, for: UIControl.State())
            previousWordButton.backgroundColor = .brandSecondary
        }
    }

    @IBAction func previousWordButtonTapped(_ sender: UIButton) {
        if wordsPageControl.currentPage > 0 {
            let pagePosition = wordLabel.frame.width * CGFloat(wordsPageControl.currentPage-1)
            let posY = wordsScrollView!.contentOffset.y
            wordsScrollView?.setContentOffset(CGPoint(x: pagePosition, y: posY), animated: true)
        }
    }

    @IBAction func nextWordButtonTapped(_ sender: UIButton) {
        if let count = wordLabels?.count {
            if wordsPageControl.currentPage == count-1 {
                performSegue(withIdentifier: "backupVerify", sender: nil)
            } else if wordsPageControl.currentPage < count-1 {
                let pagePosition = wordLabel.frame.width * CGFloat(wordsPageControl.currentPage+1)
                wordsScrollView?.setContentOffset(
                    CGPoint(x: pagePosition, y: wordsScrollView!.contentOffset.y),
                    animated: true)
            }
        }
    }

    func updateCurrentPageLabel(_ page: Int) {
        let format = NSLocalizedString("Word %@ of %@", comment: "")
        let progressLabelText = String.localizedStringWithFormat(format, String(page + 1), String(Constants.Defaults.NumberOfRecoveryPhraseWords))
        wordsProgressLabel.text = progressLabelText
        if let count = wordLabels?.count {
            if wordsPageControl.currentPage == count-1 {
                nextWordButton.backgroundColor = .brandPrimary
                nextWordButton.setTitleColor(UIColor.white, for: UIControl.State())
                nextWordButton.setTitle(NSLocalizedString("Done", comment: ""), for: UIControl.State())
            } else if wordsPageControl.currentPage == count-2 {
                nextWordButton.backgroundColor = .brandSecondary
                nextWordButton.setTitleColor(UIColor.white, for: UIControl.State())
                nextWordButton.setTitle(NSLocalizedString("NEXT", comment: ""), for: UIControl.State())
            }
            updatePreviousWordButton()
        }
    }

    // MARK: - Words Scrollview
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let fractionalPage = Float(scrollView.contentOffset.x / pageWidth)
        let page = lroundf(fractionalPage)
        wordsPageControl.currentPage = page
        updateCurrentPageLabel(page)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "secondPasswordForBackup" {
            let navController = segue.destination as! UINavigationController
            let storyboard = UIStoryboard(name: "Backup", bundle: nil)
            let secondPasswordController = storyboard.instantiateViewController(
                withIdentifier: "secondPasswordController"
                ) as! SecondPasswordViewController
            secondPasswordController.delegate = self
            secondPasswordController.wallet = wallet
            navController.viewControllers = [secondPasswordController]
        } else if segue.identifier == "backupVerify" {
            let viewController = segue.destination as! BackupVerifyViewController
            viewController.wallet = wallet
            viewController.isVerifying = false
        }
    }

    func didGetSecondPassword(_ password: String) {
        wallet!.getRecoveryPhrase(password)
    }

    internal func returnToRootViewController(_ completionHandler: @escaping () -> Void) {
        self.navigationController?.popToRootViewControllerWithHandler({ () -> () in
            completionHandler()
        })
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        let words = wallet!.recoveryPhrase.components(separatedBy: " ")
        for idx in 0 ..< Constants.Defaults.NumberOfRecoveryPhraseWords {
            wordLabels[idx].text = words[idx]
        }
    }

    deinit {
        wallet!.removeObserver(self, forKeyPath: "recoveryPhrase", context: nil)
    }
}
