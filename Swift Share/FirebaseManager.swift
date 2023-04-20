//
//  FirebaseManager.swift
//  Swift Share
//
//  Created by Parth Antala on 2023-03-13.
//

import Foundation
import Firebase
import FirebaseStorage

class FirebaseManager: NSObject {
    
    let auth: Auth
    let storage: Storage
    let firestore: Firestore
    
    var currentUser: ChatUser?
    
    static let shared = FirebaseManager()
    
    override init() {
        
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.firestore = Firestore.firestore()
        super.init()
    }
}
