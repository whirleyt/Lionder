//
//  ChatViewController.swift
//  messaging
//
//  Created by Runwei Wang on 11/15/23.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class MessagingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!

    @IBAction func calendarButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showCalendar", sender: self)
    }
    @IBAction func profileButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showProfile", sender: self)
    }
    var emailForDB: String?
    var chatSessions: [ChatSession] = []
    var userNames: [String: String] = [:]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        //var currentUserId = Auth.auth().currentUser?.uid
        //print(currentUserId ?? "noid")
        
        if let currentUserEmail = Auth.auth().currentUser?.email {
            // Replace characters as needed to comply with Firebase key constraints
            // For example, replacing '.' with '_'
            emailForDB = currentUserEmail.replacingOccurrences(of: ".", with: "_dot_")

            print("Current User Email: \(emailForDB ?? "NA")")
            fetchChatSessions()
        } else {
            print("No user email found")
        }
        
        initializeDummyData()
        //fetchChatSessions()
    }

    
    private func initializeDummyData() {
        //guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        // let testUser1Id = "user1@gmail_dot_com" // user1
        let testUser2Id = "user2@gmail_dot_com" // user2
        let testUser3Id = "user3@gmail_dot_com" // user3
        let testUser4Id = "user4@gmail_dot_com" // user4
        
        let session1: [String: Any] = [
            "sessionId": "session1",
            "user1Id": emailForDB ?? "NA",
            "user2Id": testUser2Id,
            "chatMessages": []
        ]

        let session2: [String: Any] = [
            "sessionId": "session2",
            "user1Id": emailForDB ?? "NA",
            "user2Id": testUser3Id,
            "chatMessages": []
        ]
        let session3: [String: Any] = [
            "sessionId": "session3",
            "user1Id": emailForDB ?? "NA",
            "user2Id": testUser4Id,
            "chatMessages": []
        ]
        
        chatSessions = [
            ChatSession(sessionId: "session1", user1Id: emailForDB, user2Id: testUser2Id, chatMessages: []),
            ChatSession(sessionId: "session2", user1Id: emailForDB, user2Id: testUser3Id, chatMessages: []),
            ChatSession(sessionId: "session3", user1Id: emailForDB, user2Id: testUser4Id, chatMessages: [])
        ]

        // Reference to the Firebase database location where chat sessions are stored
        let sessionsRef = Database.database().reference().child("chatSessions")

        // Uploading dummy data to Firebase
        sessionsRef.child("session1").setValue(session1)
        sessionsRef.child("session2").setValue(session2)
        sessionsRef.child("session3").setValue(session3)

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    private func fetchUserName(email: String, completion: @escaping (String?) -> Void) {
        let usersRef = Database.database().reference().child("user").child(email)
        usersRef.observeSingleEvent(of: .value, with: { snapshot in
            print("User data snapshot for email: \(email): \(snapshot)")

            if let userData = snapshot.value as? [String: Any],
               let userName = userData["name"] as? String {
                completion(userName)
            } else {
                completion(nil)
            }
        })
    }

    private func fetchChatSessions() {
        
        guard let emailForDB = emailForDB else {
            print("User email is not available.")
            return
        }
        
        let sessionsRef = Database.database().reference().child("chatSessions")
        sessionsRef.observe(.value, with: { [weak self] snapshot in
            var newChatSessions: [ChatSession] = []

            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot {
                    // Debugging: Print out the raw snapshot value
                    print("Session Snapshot: \(snapshot)")

                    if let chatSession = ChatSession(snapshot: snapshot),
                       chatSession.user1Id == emailForDB || chatSession.user2Id == emailForDB {
                        newChatSessions.append(chatSession)
                    }
                }
            }

            DispatchQueue.main.async {
                self?.chatSessions = newChatSessions
                self?.tableView.reloadData()
            }
        })
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatSessions.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showChatDetail",
           let chatDetailVC = segue.destination as? ChatDetailViewController,
           let selectedChatSession = sender as? ChatSession {
            chatDetailVC.chatSession = selectedChatSession
        }
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTableViewCell", for: indexPath) as! ChatTableViewCell
        let chatSession = chatSessions[indexPath.row]
        
        let otherUserEmail = (chatSession.user1Id == emailForDB ? chatSession.user2Id : chatSession.user1Id)!

        
        fetchUserName(email: otherUserEmail) { userName in
            DispatchQueue.main.async {
                if let name = userName {
                    cell.nameLabel.text = name
                    cell.nameLabel.textColor = .label
                } else {
                    cell.nameLabel.text = "Unknown User"
                }
            }
        }

        if let lastMessage = chatSession.chatMessages.last {
            cell.lastMessageLabel.text = lastMessage.content
            cell.lastMessageLabel.textColor = .gray
            cell.lastMessageLabel.font = UIFont.systemFont(ofSize: 17)
            cell.lastMessageLabel.textAlignment = .left
            cell.lastMessageLabel.alpha = 1.0
            cell.timeLabel.text = formatTimestamp(lastMessage.timestamp)
            cell.timeLabel.textColor = .gray
            cell.timeLabel.font = UIFont.systemFont(ofSize: 17)
        } else {
            cell.lastMessageLabel.text = "Start texting!"
            cell.lastMessageLabel.textColor = .gray
            cell.lastMessageLabel.font = UIFont.italicSystemFont(ofSize: 17)
            cell.lastMessageLabel.textAlignment = .left
            cell.lastMessageLabel.alpha = 0.5
            cell.timeLabel.text = "time"
            cell.timeLabel.textColor = .systemBackground
            cell.timeLabel.font = UIFont.systemFont(ofSize: 17)
        }
        
        cell.profileImageView.image = UIImage(named: "defaultProfilePic")
        cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.size.width / 2
        cell.profileImageView.clipsToBounds = true

        return cell
    }
    
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedChatSession = chatSessions[indexPath.row]
        performSegue(withIdentifier: "showChatDetail", sender: selectedChatSession)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}
