//
//  LastMessage.swift
//  TeamAlgeria
//
//  Created by Runwei Wang on 12/1/23.
//

import Foundation

struct ChatSession {
    let senderId: String
    
    let senderName: String
    let profileImageName: String

    let chatMessages: [ChatMessage]
}
