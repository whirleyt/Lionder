//
//  ChatTableViewCell.swift
//  messaging
//
//  Created by Runwei Wang on 11/16/23.
//

import UIKit

class ChatTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    
    func configure(with chatSession: ChatSession) {
        nameLabel.text = chatSession.senderName
        lastMessageLabel.text = chatSession.chatMessages.last?.content

        if let lastMessage = chatSession.chatMessages.last {
            lastMessageLabel.text = lastMessage.content

            let date = Date(timeIntervalSince1970: lastMessage.timestamp / 1000)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy HH:mm"
            timeLabel.text = dateFormatter.string(from: date)
        }
        profileImageView.image = UIImage(named: chatSession.profileImageName)
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
    }
}
