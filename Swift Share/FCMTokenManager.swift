//
//  FCMTokenManager.swift
//  Swift Share
//
//  Created by Parth Antala on 2023-03-22.
//

import Foundation
class FCMTokenManager {

    static let shared = FCMTokenManager()

    private enum UserDefaultKey: String {
        case fcmToken
    }

    var currentToken: String? {
        get {
            UserDefaults.standard.string(forKey: UserDefaultKey.fcmToken.rawValue)
        }

        set {
            UserDefaults.standard.setValue(newValue, forKey: UserDefaultKey.fcmToken.rawValue)
        }
    }
}
