//
//  BackupVerifyViewController.swift
//  Blockchain
//
//  Created by Sjors Provoost on 19-05-15.
//  Copyright (c) 2015 Blockchain Luxembourg S.A. All rights reserved.
//
// swiftlint:disable line_length

import UIKit

class BackupVerifyViewController: UIViewController, UITextFieldDelegate, SecondPasswordDelegate {
    var wallet: Wallet?
    var isVerifying = false
    var verifyButton: UIButton?
    var randomizedIndexes: [Int] = []
    var indexDictionary = [
		0: NSLocalizedString("first word", comment: ""),
        1: NSLocalizedString("second word", comment: ""),
        2: NSLocalizedString("third word", comment: ""),
        3: NSLocalizedString("fourth word", comment: ""),
        4: NSLocalizedString("fifth word", comment: ""),
        5: NSLocalizedString("sixth word", comment: ""),
        6: NSLocalizedString("seventh word", comment: ""),
        7: NSLocalizedString("eighth word", comment: ""),
        8: NSLocalizedString("ninth word", comment: ""),
        9: NSLocalizedString("tenth word", comment: ""),
        10: NSLocalizedString("eleventh word", comment: ""),
        11: NSLocalizedString("twelfth word", comment: "")
	]

    @IBOutlet weak var instructions: UILabel!
    @IBOutlet weak var word1: UITextField!
    @IBOutlet weak var word2: UITextField!
    @IBOutlet weak var word3: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        if UIScreen.main.bounds.size.height > Constants.Measurements.ScreenHeightIphone4S {
            instructions?.frame = CGRect(x: instructions!.frame.origin.x, y: 16, width: instructions!.frame.size.width, height: instructions!.frame.size.height)
            word1.frame = CGRect(x: word1.frame.origin.x, y: instructions!.frame.origin.y + instructions!.frame.size.height + 8, width: word1.frame.size.width, height: word1.frame.size.height + 16)
            word2.frame = CGRect(x: word2.frame.origin.x, y: word1.frame.origin.y + word1.frame.size.height + 8, width: word2.frame.size.width, height: word2.frame.size.height + 16)
            word3.frame = CGRect(x: word3.frame.origin.x, y: word2.frame.origin.y + word2.frame.size.height + 8, width: word3.frame.size.width, height: word3.frame.size.height + 16)

            word1.font = UIFont(name: "Montserrat-Regular", size: Constants.FontSizes.ExtraLarge)
            word2.font = UIFont(name: "Montserrat-Regular", size: Constants.FontSizes.ExtraLarge)
            word3.font = UIFont(name: "Montserrat-Regular", size: Constants.FontSizes.ExtraLarge)
        }

        instructions.font = UIFont(name: "GillSans", size: Constants.FontSizes.MediumLarge)

        word1.addTarget(self, action: #selector(BackupVerifyViewController.textFieldDidChange), for: .editingChanged)
        word2.addTarget(self, action: #selector(BackupVerifyViewController.textFieldDidChange), for: .editingChanged)
        word3.addTarget(self, action: #selector(BackupVerifyViewController.textFieldDidChange), for: .editingChanged)
        self.navigationController?.navigationBar.tintColor = .white

        if !wallet!.needsSecondPassword() && isVerifying {
            // if you don't need a second password but you are verifying, get recovery phrase
            wallet!.getRecoveryPhrase(nil)
        } else if wallet!.needsSecondPassword() && !isVerifying {
            // do not segue since words vc already asks for second password and gets recovery phrase
        } else if wallet!.needsSecondPassword() {
            // if you need a second password, the second password delegate takes care of getting the recovery phrase
            //: Is this even necessary? Not called if the second password is verified prior to starting the backup
            self.performSegue(withIdentifier: "verifyBackupWithSecondPassword", sender: self)
        }

        randomizeCheckIndexes()
    }

    override func viewDidAppear(_ animated: Bool) {
        verifyButton = UIButton(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 46))
        verifyButton?.setTitle(NSLocalizedString("Verify", comment: ""), for: UIControlState())
        verifyButton?.setTitle(NSLocalizedString("Verify", comment: ""), for: .disabled)
        verifyButton?.backgroundColor = .gray1
        verifyButton?.setTitleColor(UIColor.lightGray, for: .disabled)
        verifyButton?.titleLabel!.font = UIFont(name: "Montserrat-Regular", size: Constants.FontSizes.Medium)

        verifyButton?.isEnabled = true
        verifyButton?.addTarget(self, action: #selector(done), for: .touchUpInside)
        verifyButton?.isEnabled = false
        word1.inputAccessoryView = verifyButton
        word2.inputAccessoryView = verifyButton
        word3.inputAccessoryView = verifyButton
        if randomizedIndexes.count >= 3 {
            word1.placeholder = indexDictionary[randomizedIndexes[0]]
            word2.placeholder = indexDictionary[randomizedIndexes[1]]
            word3.placeholder = indexDictionary[randomizedIndexes[2]]
        }
        word1.becomeFirstResponder()
    }

    func randomizeCheckIndexes() {
        var wordIndexes: [Int] = []
        var index = 0
        for _ in 0..<Constants.Defaults.NumberOfRecoveryPhraseWords {
            wordIndexes.append(index)
            index += 1
        }
        randomizedIndexes = wordIndexes.shuffle()
    }

    @objc func done() {
        checkWords()
    }

    func checkWords() {
        var valid = true
        let words = wallet!.recoveryPhrase.components(separatedBy: " ")
        var randomWord1: String
        var randomWord2: String
        var randomWord3: String

        if randomizedIndexes.count >= 3 {
            randomWord1 = words[randomizedIndexes[0]]
            randomWord2 = words[randomizedIndexes[1]]
            randomWord3 = words[randomizedIndexes[2]]
            if word1.text!.isEmpty || word2.text!.isEmpty || word3.text!.isEmpty {
                valid = false
            } else { // Don't mark words as invalid until the user has entered all three
                if word1.text != randomWord1 {
                    word1.textColor = .error
                    valid = false
                }
                if word2.text != randomWord2 {
                    word2.textColor = .error
                    valid = false
                }
                if word3.text != randomWord3 {
                    word3.textColor = .error
                    valid = false
                }
                if !valid {
                    pleaseTryAgain()
                    return
                }
            }
            if valid {
                let backupNavigation = self.navigationController as? BackupNavigationViewController
                backupNavigation?.busyView?.fadeIn()
                backupNavigation?.markIsVerifying()
                word1.resignFirstResponder()
                word2.resignFirstResponder()
                word3.resignFirstResponder()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.wallet!.markRecoveryPhraseVerified()
                }
            }
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        textField.textColor = .gray5
        return true
    }

    func pleaseTryAgain() {
        let alert = UIAlertController(
            title: NSLocalizedString("Error", comment: ""),
            message: NSLocalizedString("Please try again", comment: ""),
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
        NotificationCenter.default.addObserver(
            alert,
            selector: #selector(UIViewController.autoDismiss),
            name: NSNotification.Name(rawValue: "reloadToDismissViews"),
            object: nil)
        present(alert, animated: true, completion: nil)
    }

    @objc func textFieldDidChange() {
        if !word1.text!.isEmpty && !word2.text!.isEmpty && !word3.text!.isEmpty {
            verifyButton?.backgroundColor = .brandSecondary
            verifyButton?.isEnabled = true
            verifyButton?.setTitleColor(UIColor.white, for: UIControlState())
        } else if word1.text!.isEmpty || word2.text!.isEmpty || word3.text!.isEmpty {
            verifyButton?.backgroundColor = .gray1
            verifyButton?.isEnabled = false
            verifyButton?.setTitleColor(UIColor.lightGray, for: .disabled)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if word1.isFirstResponder {
            textField.resignFirstResponder()
            word2.becomeFirstResponder()
        } else if word2.isFirstResponder {
            textField.resignFirstResponder()
            word3.becomeFirstResponder()
        } else if word3.isFirstResponder {
            checkWords()
        }
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "verifyBackupWithSecondPassword" {
            let navController = segue.destination as! UINavigationController
            let secondPasswordController = SecondPasswordViewController()
            secondPasswordController.delegate = self
            secondPasswordController.wallet = wallet
            navController.viewControllers = [secondPasswordController]
        }
    }

    func didGetSecondPassword(_ password: String) {
        wallet!.getRecoveryPhrase(password)
    }

    internal func returnToRootViewController(_ completionHandler: @escaping () -> Void) {
        self.navigationController?.popToRootViewControllerWithHandler({
            completionHandler()
        })
    }
}

extension Collection where Index == Int {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Iterator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

extension MutableCollection where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 {
            return
        }
        for idx in startIndex..<endIndex - 1 {
            let rand = Int(arc4random_uniform(UInt32(endIndex - idx))) + idx
            guard idx != rand else { continue }
            self.swapAt(idx, rand)
        }
    }
}
