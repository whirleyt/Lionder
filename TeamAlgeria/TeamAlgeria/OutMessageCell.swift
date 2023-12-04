//
//  OutMessageCell.swift
//  TeamAlgeria
//
//  Created by Runwei Wang on 12/1/23.
//

import UIKit

class OutMessageCell: UITableViewCell {
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var bubbleBackgroundView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        bubbleBackgroundView.backgroundColor = UIColor.systemBlue
        contentView.sendSubviewToBack(bubbleBackgroundView)
        
        bubbleBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            // Assuming messageLabel has leading, trailing, top, and bottom constraints set
            bubbleBackgroundView.topAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -14),
            bubbleBackgroundView.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 14),
            bubbleBackgroundView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: -14),
            bubbleBackgroundView.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 14)
        ])

        // Round the corners of the bubble
        bubbleBackgroundView.layer.cornerRadius = 15
        bubbleBackgroundView.clipsToBounds = true
    }
    
    func configure(with message: ChatMessage) {
        messageLabel.text = message.content
        messageLabel.textColor = .white
    }
}
