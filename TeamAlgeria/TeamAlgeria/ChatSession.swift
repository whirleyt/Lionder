//
//  LastMessage.swift
//  TeamAlgeria
//
//  Created by Runwei Wang on 12/1/23.
//

import Foundation
import FirebaseDatabase

struct ChatSession: Codable {
    let sessionId: String?
    let user1Id: String?
    let user2Id: String?
    var chatMessages: [ChatMessage]

    enum CodingKeys: String, CodingKey {
        case sessionId
        case user1Id
        case user2Id
        case chatMessages
    }
}

extension ChatSession {
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let sessionId = value["sessionId"] as? String,
            let user1Id = value["user1Id"] as? String,
            let user2Id = value["user2Id"] as? String else {
            return nil
        }

        self.sessionId = sessionId
        self.user1Id = user1Id
        self.user2Id = user2Id

        var messages = [ChatMessage]()
        let messagesSnapshot = snapshot.childSnapshot(forPath: "chatMessages")
        for child in messagesSnapshot.children {
            if let messageSnapshot = child as? DataSnapshot,
               let message = ChatMessage(snapshot: messageSnapshot, currentUserId: user1Id) {
                messages.append(message)
            }
        }
        self.chatMessages = messages
    }
}






