//
//  ChatMessage.swift
//  Swift Share
//
//  Created by Parth Antala on 2023-03-22.
//

import Foundation
import FirebaseFirestoreSwift

struct ChatMessage: Codable, Identifiable {
    @DocumentID var id: String?
    let fromId, toId: String
    let timestamp: Date
    let text: URL
}
