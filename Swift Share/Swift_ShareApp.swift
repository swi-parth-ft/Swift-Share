//
//  Swift_ShareApp.swift
//  Swift Share
//
//  Created by Parth Antala on 2023-03-13.
//

import SwiftUI

@main
struct Swift_ShareApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    let loginSignup = LoginSignup()
    var body: some Scene {
        WindowGroup {
            MainMessagesView()
                .environmentObject(loginSignup)
        }
    }
}
