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
    
    func configure(with message: ChatMessage) {
        nameLabel.text = message.name
        lastMessageLabel.text = message.lastMessage
        timeLabel.text = message.time
        profileImageView.image = UIImage(named: message.profileImageName)
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
    }
}
