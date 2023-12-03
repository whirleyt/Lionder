//
//  OutMessageCell.swift
//  TeamAlgeria
//
//  Created by Runwei Wang on 12/1/23.
//

import UIKit

class OutMessageCell: UITableViewCell {
    @IBOutlet weak var messageLabel: UILabel!

    func configure(with message: ChatMessage) {
        messageLabel.text = message.content
    }
}
