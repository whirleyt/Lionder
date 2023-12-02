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
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.clipsToBounds = true
        profileImageView.image = UIImage(named: chatSession!.profileImageName)
        // profile image
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
        let messagesRef = Database.database().reference().child("chatSessions").child(sessionId).child("messages")

        messagesRef.observe(.value, with: { snapshot in
            var newMessages: [ChatMessage] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let message = ChatMessage(snapshot: snapshot, currentUserId: currentUserId) {
                    newMessages.append(message)
                }
            }
            self.chatSession?.chatMessages = newMessages.sorted(by: { $0.timestamp < $1.timestamp })
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

        let messageData: [String: Any] = [
            "senderId": senderId,
            "content": messageText,
            "timestamp": Date().timeIntervalSince1970
        ]

        // Reference to the Firebase database location where messages are stored
        let messagesRef = Database.database().reference()
            .child("chatSessions")
            .child(sessionId)
            .child("messages")

        // Create a new child with a unique key (message ID)
        let newMessageRef = messagesRef.childByAutoId()
        
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


