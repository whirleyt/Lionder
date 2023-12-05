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
    var chatSessions: [ChatSession] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        var currentUserId = Auth.auth().currentUser?.uid
        print(currentUserId ?? "noid")
        //initializeDummyData()
        fetchChatSessions()
    }

    
    private func initializeDummyData() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        // let testUser1Id = "zacAGjInpgTMBzhz5vpNUY63E2k2" // user1
        let testUser2Id = "qVF8ba0f4VhoWI8vN42zB7OL6QS2" // user2
        let testUser3Id = "4gYJvxirqzSw1UwmgxvxI4qCcHh1" // user3
        let testUser4Id = "ojwEdxSkLTfeHIFPppfyBibLDlx2" // user4
    

        let session1: [String: Any] = [
            "sessionId": "session1",
            "user1Id": currentUserId,
            "user2Id": testUser2Id,
            "chatMessages": []
        ]

        let session2: [String: Any] = [
            "sessionId": "session2",
            "user1Id": currentUserId,
            "user2Id": testUser3Id,
            "chatMessages": []
        ]
        let session3: [String: Any] = [
            "sessionId": "session3",
            "user1Id": currentUserId,
            "user2Id": testUser4Id,
            "chatMessages": []
        ]
        
        chatSessions = [
            ChatSession(sessionId: "session1", user1Id: currentUserId, user2Id: testUser2Id, chatMessages: []),
            ChatSession(sessionId: "session2", user1Id: currentUserId, user2Id: testUser3Id, chatMessages: []),
            ChatSession(sessionId: "session3", user1Id: currentUserId, user2Id: testUser4Id, chatMessages: [])
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



    
    private func fetchChatSessions() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }

        let sessionsRef = Database.database().reference().child("chatSessions")
        sessionsRef.observe(.value, with: { [weak self] snapshot in
            var newChatSessions: [ChatSession] = []

            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot {
                    // Debugging: Print out the raw snapshot value
                    print("Session Snapshot: \(snapshot)")

                    if let chatSession = ChatSession(snapshot: snapshot),
                       chatSession.user1Id == currentUserId || chatSession.user2Id == currentUserId {
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

        if let lastMessage = chatSession.chatMessages.last {
            cell.lastMessageLabel.text = lastMessage.content
            cell.timeLabel.text = formatTimestamp(lastMessage.timestamp)
        } else {
            cell.lastMessageLabel.text = "Start texting!"
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
