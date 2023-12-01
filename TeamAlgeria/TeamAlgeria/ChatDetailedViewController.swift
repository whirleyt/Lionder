//
//  ChatDetailedViewController.swift
//  TeamAlgeria
//
//  Created by Runwei Wang on 12/1/23.
//

import UIKit

class ChatDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageInputField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!

    var chatSession: ChatSession?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        setupProfileImageView()
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
        guard let message = chatSession?.chatMessages[indexPath.row] else {
            return UITableViewCell()
        }

        if message.isOutgoing {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OutMessageCell", for: indexPath) as! OutMessageCell
            cell.configure(with: message)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "InMessageCell", for: indexPath) as! InMessageCell
            cell.configure(with: message)
            return cell
        }
        
        
    }

    @IBAction func sendButtonTapped(_ sender: UIButton) {
        // Implement the logic to send a message
        // Don't forget to append the new message to chatSession.chatMessages
        // and reload the tableView
    }
}


