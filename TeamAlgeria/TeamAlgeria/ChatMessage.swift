//
//  ChatMessage.swift
//  messaging
//
//  Created by Runwei Wang on 11/16/23.
//

import Foundation
import FirebaseDatabase

struct ChatMessage: Codable {
    var messageId: String?
    let senderId: String
    let content: String
    let timestamp: TimeInterval
    var isOutgoing: Bool?

    enum CodingKeys: String, CodingKey {
        case messageId
        case senderId
        case content
        case timestamp
    }
}


extension ChatMessage {
    init?(snapshot: DataSnapshot, currentUserId: String) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let senderId = value["senderId"] as? String,
            let content = value["content"] as? String,
            let timestamp = value["timestamp"] as? TimeInterval else {
            return nil
        }

        self.messageId = snapshot.key
        self.senderId = senderId
        self.content = content
        self.timestamp = timestamp
        self.isOutgoing = senderId == currentUserId
    }
}




