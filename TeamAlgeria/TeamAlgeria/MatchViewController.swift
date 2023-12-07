//
//  MatchViewController.swift
//
//  Edited by Tara Whirley 12/5/23
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import SDWebImage

class MatchViewController: UIViewController, UIViewControllerTransitioningDelegate {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dislikeButton: UIButton!

    var currentIndex = 0
    var ref: DatabaseReference!
    var loadedUsers: [UserProfile] = []
    var db: Firestore!
    
    var likedUsersEmpty: Bool = false
    var dislikedUsersEmpty: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        db = Firestore.firestore()

        let dbURL: String = "https://algeria-fb873-default-rtdb.firebaseio.com/"
        ref = Database.database().reference(fromURL: dbURL)
        
        name.text = ""

       fetchAllUsers()
    }

    func fetchAllUsers() {
        guard let currentUserEmail = Auth.auth().currentUser?.email else {
            print("Current user email not available.")
            return
        }

        let sanitizedEmail = sanitizeFirebaseKey(currentUserEmail)
        let dislikedUsersRef = ref.child("dislikedLists/\(sanitizedEmail)/users")
        let likedUsersRef = ref.child("likedLists/\(sanitizedEmail)/users")

        dislikedUsersRef.observeSingleEvent(of: .value, with: { dislikedSnapshot in
            let dislikedValue = dislikedSnapshot.value as? [String: Bool]
            likedUsersRef.observeSingleEvent(of: .value, with: { likedSnapshot in
                guard let likedValue = likedSnapshot.value as? [String: Bool] else {
                    print("Error fetching liked users.")
                    return self.fetchWhenLikedUsersIsEmpty(currentUserEmail: currentUserEmail, dislikedSnapshot: dislikedSnapshot)
                }
                if dislikedSnapshot.childrenCount == 0 {
                    return self.fetchWhenDislikedUsersIsEmpty(currentUserEmail: currentUserEmail, likedSnapshot: likedSnapshot)
                }

                let dislikedUsersDict = dislikedSnapshot.value as? [String: Bool] ?? [:]
                let likedUsersDict = likedSnapshot.value as? [String: Bool] ?? [:]

                self.ref.child("user").observeSingleEvent(of: .value, with: { userSnapshot in
                    guard let value = userSnapshot.value as? [String: Any] else {
                        print("No user data found.")
                        return
                    }

                    for (email, userData) in value {
                        let normalizedEmail = email.replacingOccurrences(of: ".", with: "_dot_").trimmingCharacters(in: .whitespaces)

                        if normalizedEmail != sanitizedEmail,
                            let userDict = userData as? [String: Any],
                            let userProfile = UserProfile(data: userDict),
                            let currentUserData = userSnapshot.childSnapshot(forPath: currentUserEmail.replacingOccurrences(of: ".", with: "_dot_")).value as? [String: Any],
                            let currentUserGenderPreference = currentUserData["sexualPreferences"] as? String,
                            let currentUserGender = currentUserData["gender"] as? String,
                           (userProfile.gender == currentUserGenderPreference || currentUserGenderPreference == "Both" || userProfile.gender == "Both"),
                              (currentUserGender == userProfile.sexualPreferences || userProfile.sexualPreferences == "Both" || currentUserGender == "Both"),
                            !dislikedUsersDict[normalizedEmail, default: false],
                            !likedUsersDict[normalizedEmail, default: false],
                            !value.keys.contains(normalizedEmail) {
                            self.loadedUsers.append(userProfile)
                        }
                    }
                    self.updateUI()
                })
            })
        })
    }
    
    func fetchWhenLikedUsersIsEmpty(currentUserEmail: String, dislikedSnapshot: DataSnapshot) {
        let sanitizedEmail = sanitizeFirebaseKey(currentUserEmail)
        self.ref.child("user").observeSingleEvent(of: .value, with: { userSnapshot in
            guard let value = userSnapshot.value as? [String: Any] else {
                print("No user data found.")
                return
            }
            
            guard dislikedSnapshot.value is [String: Bool] else {
                print("Error fetching disliked users.")
                return self.fetchWhenLikedAndDislikedUsersIsEmpty(currentUserEmail: currentUserEmail)
            }

            let dislikedUsersDict = dislikedSnapshot.value as? [String: Bool] ?? [:]

            for (email, userData) in value {
                let normalizedEmail = email.replacingOccurrences(of: ".", with: "_dot_").trimmingCharacters(in: .whitespaces)

                if normalizedEmail != sanitizedEmail,
                   let userDict = userData as? [String: Any],
                   let userProfile = UserProfile(data: userDict),
                   let currentUserData = userSnapshot.childSnapshot(forPath: currentUserEmail.replacingOccurrences(of: ".", with: "_dot_")).value as? [String: Any],
                   let currentUserGenderPreference = currentUserData["sexualPreferences"] as? String,
                   let currentUserGender = currentUserData["gender"] as? String,
                   (userProfile.gender == currentUserGenderPreference || currentUserGenderPreference == "Both"),
                   (currentUserGender == userProfile.sexualPreferences || userProfile.sexualPreferences == "Both"),
                   !dislikedUsersDict[normalizedEmail, default: false],
                   !value.keys.contains(normalizedEmail) {
                    self.loadedUsers.append(userProfile)
                }
            }

            self.updateUI()
        })
    }

    func fetchWhenDislikedUsersIsEmpty(currentUserEmail: String, likedSnapshot: DataSnapshot) {
        let sanitizedEmail = sanitizeFirebaseKey(currentUserEmail)
        self.ref.child("user").observeSingleEvent(of: .value, with: { userSnapshot in
            guard let value = userSnapshot.value as? [String: Any] else {
                print("No user data found.")
                return
            }
            
            let likedUsersDict = likedSnapshot.value as? [String: Bool] ?? [:]

                for (email, userData) in value {
                    let normalizedEmail = email.replacingOccurrences(of: ".", with: "_dot_").trimmingCharacters(in: .whitespaces)

                    if normalizedEmail != sanitizedEmail,
                       let userDict = userData as? [String: Any],
                       let userProfile = UserProfile(data: userDict),
                       let currentUserData = userSnapshot.childSnapshot(forPath: sanitizedEmail).value as? [String: Any],
                       let currentUserGenderPreference = currentUserData["sexualPreferences"] as? String,
                       let currentUserGender = currentUserData["gender"] as? String,
                       (userProfile.gender == currentUserGenderPreference || currentUserGenderPreference == "Both"),
                       (currentUserGender == userProfile.sexualPreferences || userProfile.sexualPreferences == "Both"),
                       !likedUsersDict[normalizedEmail, default: false],
                       !value.keys.contains(normalizedEmail) {
                        self.loadedUsers.append(userProfile)
                    }
                }

                self.updateUI()
            })
    }
    
    func fetchWhenLikedAndDislikedUsersIsEmpty(currentUserEmail: String) {
        let sanitizedEmail = sanitizeFirebaseKey(currentUserEmail)
        self.ref.child("user").observeSingleEvent(of: .value, with: { userSnapshot in
            guard let value = userSnapshot.value as? [String: Any] else {
                print("No user data found.")
                return
            }
        for (email, userData) in value {
            let normalizedEmail = email.replacingOccurrences(of: ".", with: "_dot_").trimmingCharacters(in: .whitespaces)

            if normalizedEmail != sanitizedEmail,
               let userDict = userData as? [String: Any],
               let userProfile = UserProfile(data: userDict),
               let currentUserData = userSnapshot.childSnapshot(forPath: currentUserEmail.replacingOccurrences(of: ".", with: "_dot_")).value as? [String: Any],
               let currentUserGenderPreference = currentUserData["sexualPreferences"] as? String,
               let currentUserGender = currentUserData["gender"] as? String,
               (userProfile.gender == currentUserGenderPreference ||
                currentUserGenderPreference == "Both"),
               (currentUserGender == userProfile.sexualPreferences ||
                userProfile.sexualPreferences == "Both") {
                self.loadedUsers.append(userProfile)
            }
        }
        self.updateUI()
    })
}
    

    
       func updateUI() {
           if let firstUser = loadedUsers.first {
               loadImageForUser(user: firstUser)
               name.text = firstUser.name
           }

           guard !loadedUsers.isEmpty else {
               print("No more images to load.")

               let messageLabel = UILabel(frame: CGRect(x: 20, y: 100, width: view.frame.width - 40, height: 100))
               messageLabel.text = "No more users found!\nSorry, Try again later!"
               messageLabel.numberOfLines = 0
               messageLabel.textAlignment = .center
               messageLabel.center = view.center
               view.addSubview(messageLabel)
               imageView?.isHidden = true
               name?.isHidden = true
               likeButton.isHidden = true
               dislikeButton.isHidden = true
               return
           }
       }

    func loadImageForUser(user: UserProfile) {
        let userRef = db.collection("user").document(user.email).collection("images").document("image0")
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let imageName = document.data()?["downloadURL"] as? String {
                    self.loadImageFromStorage(imageURL: imageName) {
                    }
                } else {
                    print("No download URL found in Firestore.")
                }
            } else {
                print("Error fetching document: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    @IBAction func likeButtonTapped(_ sender: UIButton) {
        let likedUser = loadedUsers[currentIndex]

        guard let currentUserEmail = Auth.auth().currentUser?.email else {
            print("Current user email not available.")
            return
        }

        let sanitizedEmail = sanitizeFirebaseKey(currentUserEmail)
        let likedUsersRef = ref.child("likedLists/\(sanitizedEmail)/users")

        likedUsersRef.observeSingleEvent(of: .value, with: { snapshot in
            var likedUsersDict = [String: Bool]()

            if let existingLikedUsers = snapshot.value as? [String: Bool] {
                likedUsersDict = existingLikedUsers
            }

            let likedUserEmail = self.sanitizeFirebaseKey(likedUser.email)
            likedUsersDict[likedUserEmail] = true

            likedUsersRef.setValue(likedUsersDict)
        })
        createNewSessionIfMatched(likedUser: likedUser)
        self.currentIndex += 1
        loadNextImage {}
    }

    @IBAction func dislikeButtonTapped(_ sender: UIButton) {
        let dislikedUser = loadedUsers[currentIndex]

        guard let currentUserEmail = Auth.auth().currentUser?.email else {
            print("Current user email not available.")
            return
        }

        let sanitizedEmail = sanitizeFirebaseKey(currentUserEmail)
        let dislikedUsersRef = ref.child("dislikedLists/\(sanitizedEmail)/users")
        
        
        
        dislikedUsersRef.observeSingleEvent(of: .value, with: { snapshot in
            var dislikedUsersDict = [String: Bool]()

            if let existingDislikedUsers = snapshot.value as? [String: Bool] {
                dislikedUsersDict = existingDislikedUsers
            }

            let dislikedUserEmail = self.sanitizeFirebaseKey(dislikedUser.email)
            dislikedUsersDict[dislikedUserEmail] = true

            dislikedUsersRef.setValue(dislikedUsersDict)
        })
        self.currentIndex += 1
        loadNextImage {}
    }
    
    func createNewSessionIfMatched(likedUser: UserProfile) {
        guard let currentUserEmail = Auth.auth().currentUser?.email,
              !currentUserEmail.isEmpty,
              !likedUser.email.isEmpty else {
            return
        }

        let sanitizedCurrentUserEmail = sanitizeFirebaseKey(currentUserEmail)
        let sanitizedLikedUserEmail = sanitizeFirebaseKey(likedUser.email)

        let likedUsersRef = ref.child("likedLists/\(sanitizedLikedUserEmail)/users")

        likedUsersRef.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let self = self else { return }

            if snapshot.hasChild(sanitizedCurrentUserEmail) {
                self.createSession(currentUserEmail: currentUserEmail, likedUser: likedUser)
            }
        })
    }

    func createSession(currentUserEmail: String, likedUser: UserProfile) {
        let sanitizedEmail = sanitizeFirebaseKey(currentUserEmail)
        let sortedUserIds = [currentUserEmail, likedUser.email].sorted().joined(separator: "_")
        let timestamp = Date().timeIntervalSince1970 // Use timestamp as part of the session ID
        let sessionID = "\(sortedUserIds)_\(timestamp)"
        
        let sanitizedLikedUserEmail = sanitizeFirebaseKey(likedUser.email)

        let sanitizedSessionID = self.sanitizeFirebaseKey(sessionID)

        let newSession: [String: Any] = [
            "sessionId": sanitizedSessionID,
            "user1Id": sanitizedEmail,
            "user2Id": sanitizedLikedUserEmail,
            "chatMessages": []
        ]

        let sessionRef = self.ref.child("chatSessions").child(sanitizedSessionID)
        sessionRef.setValue(newSession)
    }

    func sanitizeFirebaseKey(_ key: String) -> String {
        let invalidCharacters = CharacterSet(charactersIn: ".")
        var sanitizedKey = key

        for char in key.unicodeScalars {
            if invalidCharacters.contains(char) {
                sanitizedKey = sanitizedKey.replacingOccurrences(of: String(char), with: "_dot_")
            }
        }

        return sanitizedKey
    }

    func loadNextImage(completion: @escaping () -> Void) {
        guard currentIndex < loadedUsers.count else {
            print("No more images to load.")
            name.text = ""

            let messageLabel = UILabel(frame: CGRect(x: 20, y: 100, width: view.frame.width - 40, height: 100))
            messageLabel.text = "No more users found!\nSorry, Try again later!"
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            messageLabel.center = view.center
            view.addSubview(messageLabel)
            imageView?.isHidden = true
            likeButton.isHidden = true
            dislikeButton.isHidden = true
            return
        }
        let user = loadedUsers[currentIndex]
        name.text = user.name

        let userRef = db.collection("user").document(user.email).collection("images").document("image0")
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let imageName = document.data()?["downloadURL"] as? String {
                    self.loadImageFromStorage(imageURL: imageName) {
                        print("Loaded user: \(user.name), \(user.email)")
                        completion() // Call the completion block here
                    }
                } else {
                    print("No download URL found in Firestore.")
                }
            } else {
                print("Error fetching document: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    func loadImageFromStorage(imageURL: String, completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            if let url = URL(string: imageURL) {
                self.imageView.sd_setImage(with: url) { _, _, _, _ in
                    completion()
                }
            } else {
                self.imageView.isHidden = true
            }
        }
    }
}
