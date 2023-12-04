//
//  ChatDetailedViewController.swift
//  TeamAlgeria
//
//  Created by Runwei Wang on 12/1/23.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ChatDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageInputField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    let currentUserId = Auth.auth().currentUser?.uid

    var chatSession: ChatSession?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        setupProfileImageView()
        
        fetchMessages()
    }

    private func setupProfileImageView() {
        profileImageView.image = UIImage(named: "defaultProfilePic")
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatSession?.chatMessages.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let message = chatSession?.chatMessages[indexPath.row],
              let currentUserId = Auth.auth().currentUser?.uid else {
            return UITableViewCell() // Return an empty cell in case of an error
        }

        let isOutgoing = message.senderId == currentUserId
        let cellIdentifier = isOutgoing ? "OutMessageCell" : "InMessageCell"
        
        if isOutgoing {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! OutMessageCell
            cell.configure(with: message)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! InMessageCell
            cell.configure(with: message)
            return cell
        }
    }

    
    private func fetchMessages() {
        guard let sessionId = chatSession?.sessionId,
              let currentUserId = Auth.auth().currentUser?.uid else { return }

        // Reference to the Firebase database location where chatMessages are stored
        let messagesRef = Database.database().reference()
            .child("chatSessions")
            .child(sessionId)
            .child("chatMessages")

        messagesRef.observe(.value, with: { snapshot in
            var newMessages: [ChatMessage] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let message = ChatMessage(snapshot: snapshot, currentUserId: currentUserId) {
                    newMessages.append(message)
                }
            }

            // Sorting messages by timestamp
            self.chatSession?.chatMessages = newMessages.sorted(by: { $0.timestamp < $1.timestamp })

            // Reload the tableView and scroll to the latest message
            self.tableView.reloadData()
            self.scrollToBottom()
        })
    }
    
    private func scrollToBottom() {
        let lastRow = (self.chatSession?.chatMessages.count ?? 0) - 1
        if lastRow > 0 {
            let indexPath = IndexPath(row: lastRow, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }


    @IBAction func sendButtonTapped(_ sender: UIButton) {
        guard let messageText = messageInputField.text, !messageText.isEmpty,
              let sessionId = chatSession?.sessionId,
              let senderId = Auth.auth().currentUser?.uid else {
            return
        }

        // Reference to the Firebase database location where messages are stored
        let messagesRef = Database.database().reference()
            .child("chatSessions")
            .child(sessionId)
            .child("chatMessages")

        // Create a new child with a unique key (message ID)
        let newMessageRef = messagesRef.childByAutoId()
        
        // Include the unique messageId in the message data
        let messageData: [String: Any] = [
            "messageId": newMessageRef.key!,  // Using the auto-generated key as messageId
            "senderId": senderId,
            "content": messageText,
            "timestamp": Date().timeIntervalSince1970
        ]

        // Save the message to Firebase
        newMessageRef.setValue(messageData) { error, _ in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            } else {
                self.messageInputField.text = nil
            }
        }
    }
    





}


