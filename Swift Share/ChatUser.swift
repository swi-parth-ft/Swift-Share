//
//  ChatUser.swift
//  Swift Share
//
//  Created by Parth Antala on 2023-03-14.
//

import FirebaseFirestoreSwift

struct ChatUser: Codable, Identifiable {
    
    @DocumentID var id: String?
    
    let uid, email, profileImageUrl, name: String
    
//    init(data: [String: Any]) {
//        self.uid = data["uid"] as? String ?? ""
//        self.name = data["name"] as? String ?? ""
//        self.email = data["email"] as? String ?? ""
//        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
//    }
}
