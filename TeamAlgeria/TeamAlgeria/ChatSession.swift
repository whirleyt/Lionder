//
//  LastMessage.swift
//  TeamAlgeria
//
//  Created by Runwei Wang on 12/1/23.
//

import Foundation
import FirebaseDatabase

struct ChatSession: Codable {
    let senderId: String
    let sessionId: String
    let senderName: String
    let profileImageName: String
    var chatMessages: [ChatMessage]

    enum CodingKeys: String, CodingKey {
        case senderId
        case sessionId
        case senderName
        case profileImageName
        case chatMessages
    }
}

extension ChatSession {
    func asDictionary() -> [String: Any] {
        let data = try! JSONEncoder().encode(self)
        let dictionary = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
        return dictionary
    }
}

extension ChatSession {
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let jsonData = try? JSONSerialization.data(withJSONObject: value),
            let session = try? JSONDecoder().decode(ChatSession.self, from: jsonData)
        else {
            return nil
        }
        self = session
    }
}
