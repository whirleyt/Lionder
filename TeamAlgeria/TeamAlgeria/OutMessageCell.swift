//
//  OutMessageCell.swift
//  TeamAlgeria
//
//  Created by Runwei Wang on 12/1/23.
//

import UIKit

class OutMessageCell: UITableViewCell {
    @IBOutlet weak var messageLabel: UILabel!
    // Add other outlets as necessary

    func configure(with message: ChatMessage) {
        messageLabel.text = message.content
        // Configure other elements if necessary
    }
}
