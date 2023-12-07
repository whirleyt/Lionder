//
//  ChatDetailedViewController.swift
//  TeamAlgeria
//
//  Created by Runwei Wang on 12/1/23.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseFirestore
import FirebaseStorage

class ChatDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageInputField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
  
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sendButtonBottom: NSLayoutConstraint!
    let currentUserId = Auth.auth().currentUser?.uid
    var chatSession: ChatSession?
    var emailForDB: String?
    var storageRef: StorageReference!
    var db: Firestore!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
        fetchMessages()
        sendButtonBottom.constant = 0
        storageRef = Storage.storage().reference()
        db = Firestore.firestore()
        
        if let currentUserEmail = Auth.auth().currentUser?.email {
            // Replace characters as needed to comply with Firebase key constraints
            // For example, replacing '.' with '_'
            emailForDB = currentUserEmail.replacingOccurrences(of: ".", with: "_dot_")

            print("Current User Email: \(emailForDB ?? "NA")")
        } else {
            print("No user email found")
        }
        
        guard let emailForDB = emailForDB else {
            print("User email is not available.")
            return
        }
        
        let otherUserEmail = (chatSession?.user1Id == emailForDB ? chatSession?.user2Id : chatSession?.user1Id)!

        fetchUserName(email: otherUserEmail) { userName in
            DispatchQueue.main.async { [self] in
                if let name = userName {
                    self.nameLabel.text = name
                    self.nameLabel.textColor = .label
                } else {
                    nameLabel.text = "Unknown User"
                }
            }
        }
        
        let otherUserEmailStore = otherUserEmail.replacingOccurrences(of: "_dot_", with: ".")
        fetchProfilePictureURL(forEmail: otherUserEmailStore) { imageURL in
            DispatchQueue.main.async {
                if let imageURL = imageURL {
                    self.loadImageFromStorage(imageURL: imageURL, imageView: self.profileImageView)
                } else {
                    self.profileImageView.image = UIImage(named: "defaultProfilePic")
                    self.profileImageView.contentMode = .scaleAspectFill
                    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2
                    self.profileImageView.clipsToBounds = true
                }
            }
        }
    
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            UIView.animate(withDuration: 0.3) {
                self.sendButtonBottom.constant = keyboardHeight - self.view.safeAreaInsets.bottom + 6
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.sendButtonBottom.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func scrollToLastMessage(animated: Bool) {
        guard let chatMessages = chatSession?.chatMessages, !chatMessages.isEmpty else {
            return
        }
        
        let lastRow = chatMessages.count - 1
        let indexPath = IndexPath(row: lastRow, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
    }
    
    func fetchProfilePictureURL(forEmail email: String, completion: @escaping (String?) -> Void) {
        let userRef = db.collection("user").document(email).collection("images").document("image0")

        userRef.getDocument { (document, error) in
            if let document = document, document.exists,
               let imageName = document.data()?["downloadURL"] as? String {
                completion(imageName)
            } else {
                print("No profile picture URL found in Firestore for user: \(email). Using default profile pic.")
                completion(nil)
            }
        }
    }
    
    
    func loadImageFromStorage(imageURL: String, imageView: UIImageView) {
        if let url = URL(string: imageURL) {
            imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "defaultProfilePic"), options: [], completed: { (image, error, cacheType, url) in
                // After the image has been loaded, apply the circular mask
                DispatchQueue.main.async {
                    imageView.contentMode = .scaleAspectFill
                    imageView.layer.cornerRadius = imageView.frame.size.width / 2
                    imageView.clipsToBounds = true
                }
            })
        } else {
            // If imageURL is not valid, set the default profile picture
            imageView.image = UIImage(named: "defaultProfilePic")
            imageView.contentMode = .scaleAspectFill
            imageView.layer.cornerRadius = imageView.frame.size.width / 2
            imageView.clipsToBounds = true
        }
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


