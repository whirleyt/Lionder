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
    
    private func formatTimestamp(_ timestamp: TimeInterval) -> String {
        let messageDate = Date(timeIntervalSince1970: timestamp)
        let dateFormatter = DateFormatter()
        let calendar = Calendar.current

        if calendar.isDateInToday(messageDate) {
            dateFormatter.dateFormat = "HH:mm"
        } else if isDateInThisWeek(messageDate, using: calendar) {
            dateFormatter.dateFormat = "EEEE" // Day of the week
        } else {
            dateFormatter.dateFormat = "MM/dd" // Month and day
        }

        return dateFormatter.string(from: messageDate)
    }

    private func isDateInThisWeek(_ date: Date, using calendar: Calendar) -> Bool {
        return calendar.isDate(date, equalTo: Date(), toGranularity: .weekOfYear)
    }
}
