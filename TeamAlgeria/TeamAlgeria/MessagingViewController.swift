//
//  ChatViewController.swift
//  messaging
//
//  Created by Runwei Wang on 11/15/23.
//

import UIKit

class MessagingViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!

    @IBAction func calendarButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showCalendar", sender: self)
    }
    @IBAction func profileButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showProfile", sender: self)
    }
    
    var chatMessages: [ChatMessage] = [
        ChatMessage(name: "Eve", lastMessage: "Check out this new app!", time: "08:45 PM", profileImageName: "Eve-0"),
        ChatMessage(name: "Frank", lastMessage: "Started watching that new series yet?", time: "08:30 PM", profileImageName: "Frank-0"),
        ChatMessage(name: "Grace", lastMessage: "Thanks for the birthday wishes!", time: "07:25 PM", profileImageName: "Grace-0"),
        ChatMessage(name: "Henry", lastMessage: "Is our meeting still on for tomorrow?", time: "07:10 PM", profileImageName: "Henry-0"),
        ChatMessage(name: "Liam", lastMessage: "Did you get my last email about the trip?", time: "06:50 PM", profileImageName: "Liam-0"),
        ChatMessage(name: "Mia", lastMessage: "That's a great idea! I'll look into it.", time: "06:35 PM", profileImageName: "Mia-0"),
        ChatMessage(name: "Noah", lastMessage: "I'll be there in 10 minutes.", time: "06:20 PM", profileImageName: "Noah-0"),
        ChatMessage(name: "Olivia", lastMessage: "Happy Anniversary!", time: "05:50 PM", profileImageName: "Olivia-0"),
        ChatMessage(name: "Parker", lastMessage: "Can you please share the playlist from last night?", time: "05:45 PM", profileImageName: "Parker-0"),
        ChatMessage(name: "Quinn", lastMessage: "The meeting is rescheduled to next week.", time: "05:30 PM", profileImageName: "Quinn-0"),
        ChatMessage(name: "Riley", lastMessage: "I've left the keys at the reception for you.", time: "05:15 PM", profileImageName: "Riley-0"),
        ChatMessage(name: "Sophia", lastMessage: "Can't wait to see you this weekend!", time: "05:00 PM", profileImageName: "Sophia-0"),
        ChatMessage(name: "Tyler", lastMessage: "The gym session was intense today!", time: "04:45 PM", profileImageName: "Tyler-0"),
        ChatMessage(name: "Uma", lastMessage: "The book you recommended was fantastic!", time: "04:30 PM", profileImageName: "Uma-0"),
        ChatMessage(name: "Victor", lastMessage: "The project deadline is approaching fast.", time: "04:15 PM", profileImageName: "Victor-0"),
        ChatMessage(name: "Wendy", lastMessage: "Let's plan for the reunion.", time: "04:00 PM", profileImageName: "Wendy-0"),
        ChatMessage(name: "Xavier", lastMessage: "I've sent you the directions on the map.", time: "03:45 PM", profileImageName: "Xavier-0"),
        ChatMessage(name: "Yara", lastMessage: "The photos from our trip have been uploaded.", time: "03:30 PM", profileImageName: "Yara-0"),
        ChatMessage(name: "Zane", lastMessage: "Could you review my latest draft when you have time?", time: "03:15 PM", profileImageName: "Zane-0"),
        ChatMessage(name: "Alice", lastMessage: "Hey, how's it going?", time: "10:30 AM", profileImageName: "Alice-0"),
        ChatMessage(name: "Bob", lastMessage: "Got the notes?", time: "09:15 AM", profileImageName: "Bob-0"),
        ChatMessage(name: "Dana", lastMessage: "Can't believe what happened in the game!", time: "Yesterday", profileImageName: "Dana-0"),
        ChatMessage(name: "Charlie", lastMessage: "Let's catch up over coffee?", time: "Yesterday", profileImageName: "Charlie-0"),
        ChatMessage(name: "Jake", lastMessage: "That new restaurant was amazing!", time: "Monday", profileImageName: "Jake-0"),
        ChatMessage(name: "Ivy", lastMessage: "Don't forget to send me the report.", time: "Monday", profileImageName: "Ivy-0"),
        
        // Add more messages
        ]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        // Use dummy data
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCalendar" {
            // Pass data to the Calendar view controller if needed
        } else if segue.identifier == "showProfile" {
            // Pass data to the Profile view controller if needed
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTableViewCell", for: indexPath) as! ChatTableViewCell
        let message = chatMessages[indexPath.row]
        cell.nameLabel.text = message.name
        cell.lastMessageLabel.text = message.lastMessage
        cell.timeLabel.text = message.time
        cell.profileImageView.image = UIImage(named: message.profileImageName)
        return cell
     }
    
}
