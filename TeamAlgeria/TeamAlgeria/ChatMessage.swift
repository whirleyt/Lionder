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
    func asDictionary() -> [String: Any] {
        do {
            let data = try JSONEncoder().encode(self)
            guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
                return [:]
            }
            return dictionary
        } catch {
            print("Error encoding ChatMessage: \(error)")
            return [:]
        }
    }
}

extension ChatMessage {
    init?(snapshot: DataSnapshot, currentUserId: String) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let jsonData = try? JSONSerialization.data(withJSONObject: value),
            var message = try? JSONDecoder().decode(ChatMessage.self, from: jsonData)
        else {
            return nil
        }
        message.messageId = snapshot.key
        message.isOutgoing = message.senderId == currentUserId
        self = message
    }
}




