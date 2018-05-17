//
//  SoundManager.swift
//  Blockchain
//
//  Created by Chris Arriola on 5/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Manager object for playing sounds in the app.
@objc class SoundManager: NSObject {
    static let shared = SoundManager()

    @objc class func sharedInstance() -> SoundManager {
        return shared
    }

    override private init() {
    }

    private lazy var beepSoundID: SystemSoundID? = {
        return systemSoundID(forSoundFileName: "beep")
    }()

    private lazy var alertSoundID: SystemSoundID? = {
        return systemSoundID(forSoundFileName: "alert-received")
    }()

    @objc func playBeep() {
        play(systemSoundID: beepSoundID)
    }

    @objc func playAlert() {
        play(systemSoundID: alertSoundID)
    }

    private func play(systemSoundID: SystemSoundID?) {
        guard let systemSoundID = systemSoundID else {
            print("Cannot play sound with nil SystemSoundID")
            return
        }
        AudioServicesPlaySystemSound(systemSoundID)
    }

    private func systemSoundID(forSoundFileName name: String) -> SystemSoundID? {
        guard let soundPath = Bundle.main.path(forResource: name, ofType: "wav") else {
            print("Could not retrieve file URL path for the sound '\(name).wav'")
            return nil
        }
        var soundID: SystemSoundID = 0
        let soundURL = URL(fileURLWithPath: soundPath)
        AudioServicesCreateSystemSoundID(soundURL as CFURL, &soundID)
        return soundID
    }
}
