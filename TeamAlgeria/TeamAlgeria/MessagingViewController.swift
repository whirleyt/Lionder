//
//  ChatViewController.swift
//  messaging
//
//  Created by Runwei Wang on 11/15/23.
//

import UIKit
import FirebaseAuth

class MessagingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!

    @IBAction func calendarButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showCalendar", sender: self)
    }
    @IBAction func profileButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showProfile", sender: self)
    }
    
    var chatSessions: [ChatSession] = [
        ChatSession(senderId: "t1", sessionId: "t1", senderName: "Eve", profileImageName: "Eve-0", chatMessages: [ChatMessage(messageId: "m1", senderId: Auth.auth().currentUser?.uid ?? "t1", content: "I've just enrolled in the COMS4995 iOS App Development course. I'm a bit nervous since I don't have much background in programming. Any tips on how to prepare?", timestamp: 1672527600000, isOutgoing: true), ChatMessage(messageId: "m2", senderId: "t2", content: "That's great news! Don't worry too much about your current skill level. These courses are designed to guide you from the basics. However, a little preparation can go a long way. Have you tried any online coding platforms?", timestamp: 1672527610000, isOutgoing: false), ChatMessage(messageId: "m3", senderId: Auth.auth().currentUser?.uid ?? "t1", content: "Not yet. Do you think platforms like Codecademy or Udemy would help?", timestamp: 1672527600000, isOutgoing: true), ChatMessage(messageId: "m4", senderId: "t2", content: "Absolutely! They offer beginner courses in Swift, which is the programming language you'll use for iOS development. Getting a head start in understanding Swift's syntax and basic concepts will make your initial classes much easier.", timestamp: 1672527610000, isOutgoing: false) ] ),
        ]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatSessions.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showChatDetail" {
            if let chatDetailVC = segue.destination as? ChatDetailViewController,
               let selectedChatSession = sender as? ChatSession {
                chatDetailVC.chatSession = selectedChatSession
            }
        }
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTableViewCell", for: indexPath) as! ChatTableViewCell
        let chatSession = chatSessions[indexPath.row]
        
        cell.nameLabel.text = chatSession.senderName
        if let lastMessage = chatSession.chatMessages.last {
            cell.lastMessageLabel.text = lastMessage.content

            let date = Date(timeIntervalSince1970: lastMessage.timestamp / 1000)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy HH:mm"
            cell.timeLabel.text = dateFormatter.string(from: date)
        }
        cell.profileImageView.image = UIImage(named: chatSession.profileImageName)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedChatSession = chatSessions[indexPath.row]
        performSegue(withIdentifier: "showChatDetail", sender: selectedChatSession)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}
