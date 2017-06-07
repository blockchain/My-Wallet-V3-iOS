//
//  BackupWordsViewController.swift
//  Blockchain
//
//  Created by Sjors Provoost on 19-05-15.
//  Copyright (c) 2015 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

class BackupWordsViewController: UIViewController, SecondPasswordDelegate, UIScrollViewDelegate {

	@IBOutlet weak var wordsScrollView: UIScrollView!
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

		self.navigationController?.navigationBar.tintColor = UIColor.white

		wordLabel.text = ""

		updateCurrentPageLabel(0)

		wordsScrollView.center = CGPoint(x: view.center.x, y: wordsScrollView.center.y)
		wordsScrollView.clipsToBounds = true
		wordsScrollView.contentSize = CGSize(width: CGFloat(Constants.Defaults.NumberOfRecoveryPhraseWords) * wordLabel.frame.width, height: wordLabel.frame.height)
		wordsScrollView.isUserInteractionEnabled = false

		wordLabels = [UILabel]()
		wordLabels.insert(wordLabel, at: 0)
		for i in 1 ..< Constants.Defaults.NumberOfRecoveryPhraseWords {
			let offset: CGFloat = CGFloat(i) * wordLabel.frame.width
			let x: CGFloat = wordLabel.frame.origin.x + offset
			let label = UILabel(frame: CGRect(x: x, y: wordLabel.frame.origin.y, width: wordLabel.frame.size.width, height: wordLabel.frame.size.height))
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

		UIView .animate(withDuration: 0.3, animations: { () -> Void in
			self.previousWordButton.frame = CGRect(x: 0,y: self.view.frame.size.height-self.previousWordButton.frame.size.height, width:self.view.frame.size.width/2 - 2, height: self.previousWordButton.frame.size.height)
			self.nextWordButton.frame = CGRect(x: self.view.frame.size.width-self.previousWordButton.frame.size.width + 2, y: self.view.frame.size.height-self.previousWordButton.frame.size.height, width:self.view.frame.size.width/2 - 2, height: self.previousWordButton.frame.size.height)
		})
	}

	func setupInstructionLabel() {
		summaryLabel.font = UIFont(name: "GillSans", size: Constants.FontSizes.MediumLarge)
		summaryLabel.text = NSLocalizedString("Write down the following 12 word Recovery Phrase exactly as they appear and in this order:", comment:"")
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
			previousWordButton.setTitleColor(UIColor.darkGray, for: UIControlState())
			previousWordButton.backgroundColor = Constants.Colors.DisabledGray
		} else {
			previousWordButton.isEnabled = true
			previousWordButton.setTitleColor(UIColor.white, for: UIControlState())
			previousWordButton.backgroundColor = Constants.Colors.BlockchainLightBlue
		}
	}

	@IBAction func previousWordButtonTapped(_ sender: UIButton) {
		if wordsPageControl.currentPage > 0 {
			let pagePosition = wordLabel.frame.width * CGFloat(wordsPageControl.currentPage-1)
			wordsScrollView.setContentOffset(CGPoint(x: pagePosition, y: wordsScrollView.contentOffset.y), animated: true)
		}
	}

	@IBAction func nextWordButtonTapped(_ sender: UIButton) {
		if let count = wordLabels?.count {
			if wordsPageControl.currentPage == count-1 {
				performSegue(withIdentifier: "backupVerify", sender: nil)
			} else if wordsPageControl.currentPage < count-1 {
				let pagePosition = wordLabel.frame.width * CGFloat(wordsPageControl.currentPage+1)
				wordsScrollView.setContentOffset(CGPoint(x: pagePosition, y: wordsScrollView.contentOffset.y), animated: true)
			}
		}
	}

	func updateCurrentPageLabel(_ page: Int) {
		wordsProgressLabel.text = NSLocalizedString(NSString(format: "Word %@ of %@", String(page + 1), String((Constants.Defaults.NumberOfRecoveryPhraseWords))) as String, comment: "")
		if let count = wordLabels?.count {
			if wordsPageControl.currentPage == count-1 {
				nextWordButton.backgroundColor = Constants.Colors.BlockchainBlue
				nextWordButton.setTitleColor(UIColor.white, for: UIControlState())
				nextWordButton.setTitle(NSLocalizedString("Done", comment: ""), for: UIControlState())
			} else if wordsPageControl!.currentPage == count-2 {
				nextWordButton.backgroundColor = Constants.Colors.BlockchainLightBlue
				nextWordButton.setTitleColor(UIColor.white, for: UIControlState())
				nextWordButton.setTitle(NSLocalizedString("NEXT", comment: ""), for: UIControlState())
			}
			updatePreviousWordButton()
		}
	}

	// MARK: - Words Scrollview
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		// Determine page number:
		let pageWidth = scrollView.frame.size.width
		let fractionalPage = Float(scrollView.contentOffset.x / pageWidth)
		let page: Int = lroundf(fractionalPage)

		wordsPageControl.currentPage = page

		updateCurrentPageLabel(page)
	}

	// MARK: - Navigation

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "secondPasswordForBackup" {
			let vc = segue.destination as! SecondPasswordViewController
			vc.delegate = self
			vc.wallet = wallet
		} else if segue.identifier == "backupVerify" {
			let vc = segue.destination as! BackupVerifyViewController
			vc.wallet = wallet
			vc.isVerifying = false
		}
	}

	func didGetSecondPassword(_ password: String) {
		wallet!.getRecoveryPhrase(password)
	}

	internal func returnToRootViewController(_ completionHandler: @escaping () -> Void ) {
		self.navigationController?.popToRootViewControllerWithHandler({ () -> () in
			completionHandler()
		})
	}

	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
		let words = wallet!.recoveryPhrase.components(separatedBy: " ")
		for i in 0 ..< Constants.Defaults.NumberOfRecoveryPhraseWords {
			wordLabels[i].text = words[i]
		}
	}

	deinit {
		wallet!.removeObserver(self, forKeyPath: "recoveryPhrase", context: nil)
	}
}
