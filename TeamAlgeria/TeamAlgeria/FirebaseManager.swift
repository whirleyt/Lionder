//// FirebaseManager.swift
//
//import Foundation
//import Firebase
//
//class FirebaseManager {
//    static let shared = FirebaseManager()
//
//    var ref: DatabaseReference!
//    let currentUserEmail: String
//
//    private init() {
//        ref = Database.database().reference()
//
//        guard let email = Auth.auth().currentUser?.email else {
//            fatalError("User not logged in")
//        }
//
//        currentUserEmail = email
//        print("**FIREBASE MANAGER DEBUG*******************")
//        print("**Current User Email: \(currentUserEmail)**")
//        print("*******************************************")
//    }
//
//    func loadUserData(completion: @escaping (String) -> Void) {
//            createMatchNodeIfNeeded()
//            createUserFoldersIfNeeded()
//            createMatchNodeIfNeeded()
//            completion("User data loaded.")
//        }
//    
//    func createUserMatchInfoIfNeeded() {
//            // userMatchInfo 노드가 없으면 생성
//            ref.child("userMatchInfo").observeSingleEvent(of: .value) { snapshot in
//                if !snapshot.exists() {
//                    // userMatchInfo 노드가 없으면 생성
//                    self.ref.child("userMatchInfo").setValue([])
//                }
//            }
//        }
//
//    func createUserFoldersIfNeeded() {
//        // 현재 로그인한 사용자의 이메일을 기반으로 노드 경로 생성
//        let userNodePath = "userMatchInfo/\(currentUserEmail.replacingOccurrences(of: ".", with: "_dot_"))"
//
//        // 해당 경로에 노드가 없으면 생성
//        ref.child(userNodePath).observeSingleEvent(of: .value) { snapshot in
//            if !snapshot.exists() {
//                // 유저 노드가 없으면 생성
//                self.ref.child(userNodePath).setValue(["neverMatchedWith": [], "waitForMatch": [], "liked": [], "matched": []])
//            }
//        }
//    }
//
//    func createMatchNodeIfNeeded() {
//        // match 노드가 없으면 생성
//        ref.child("userMatchInfo/match").observeSingleEvent(of: .value) { snapshot in
//            if !snapshot.exists() {
//                // match 노드가 없으면 생성
//                self.ref.child("userMatchInfo/match").setValue([])
//            }
//        }
//    }
//
//    func loadOtherUsersData(completion: @escaping ([String]) -> Void) {
//        // Fetching user email addresses from the "user" folder
//        ref.child("user").observeSingleEvent(of: .value) { snapshot in
//            guard snapshot.exists() else {
//                print("No data available for users")
//                completion([])
//                return
//            }
//
//            // Extracting user email addresses from the snapshot
//            let userSnapshot = snapshot.children.allObjects as! [DataSnapshot]
//            let allUsersEmails = userSnapshot.map { $0.key.replacingOccurrences(of: "_dot_", with: ".") }
//
//            // Fetching neverMatchedWith, liked, matched information for the current user
//            let currentUserEmail = self.currentUserEmail.replacingOccurrences(of: ".", with: "_dot_")
//            self.ref.child("userMatchInfo/\(currentUserEmail)").observeSingleEvent(of: .value) { userMatchInfoSnapshot in
//                guard userMatchInfoSnapshot.exists(), let userData = userMatchInfoSnapshot.value as? [String: Any] else {
//                    print("No data available for current user")
//                    completion([])
//                    return
//                }
//
//                let neverMatchedWith = Set(userData["neverMatchedWith"] as? [String] ?? [])
//                let liked = Set(userData["liked"] as? [String] ?? [])
//                let matched = Set(userData["matched"] as? [String] ?? [])
//
//                // Filtering out email addresses of the current user and those in neverMatchedWith, liked, matched
//                let otherUsersEmails = allUsersEmails.filter { email in
//                    let otherUserEmail = email.replacingOccurrences(of: "_dot_", with: ".")
//                    return otherUserEmail != currentUserEmail && !neverMatchedWith.contains(otherUserEmail) && !liked.contains(otherUserEmail) && !matched.contains(otherUserEmail)
//                }
//
//                completion(otherUsersEmails)
//            }
//        }
//    }
//
//    func updateNeverMatchedWith(targetUserEmail: String) {
//        let targetUserNodePath = "userMatchInfo/\(targetUserEmail.replacingOccurrences(of: ".", with: "_dot_"))"
//        let neverMatchedWithTargetUserPath = "\(targetUserNodePath)/neverMatchedWith"
//
//        // Using a transaction to ensure data consistency when updating the list for the target user
//        ref.child(neverMatchedWithTargetUserPath).runTransactionBlock { currentData -> TransactionResult in
//            if var neverMatchedWithTargetUser = currentData.value as? [String] {
//                // Add the current user's email to the target user's neverMatchedWith list
//                neverMatchedWithTargetUser.append(self.currentUserEmail.replacingOccurrences(of: ".", with: "_dot_"))
//                currentData.value = neverMatchedWithTargetUser
//            } else {
//                // If the list doesn't exist, create a new one with the current user's email
//                currentData.value = [self.currentUserEmail.replacingOccurrences(of: ".", with: "_dot_")]
//            }
//            return TransactionResult.success(withValue: currentData)
//        } andCompletionBlock: { error, committed, snapshot in
//            if let error = error {
//                print("Failed to update neverMatchedWith for target user: \(error.localizedDescription)")
//            } else {
//                print("neverMatchedWith for target user updated successfully")
//            }
//        }
//    }
//
//    func updateWaitForMatch(targetUserEmail: String) {
//        let currentUserNodePath = "userMatchInfo/\(currentUserEmail.replacingOccurrences(of: ".", with: "_dot_"))"
//        let targetUserNodePath = "userMatchInfo/\(targetUserEmail.replacingOccurrences(of: ".", with: "_dot_"))"
//
//        // Add the target user to the current user's matched list
//        updateMatched(targetUserEmail: targetUserEmail)
//
//        // Remove the target user from the current user's waitForMatch list
//        ref.child(currentUserNodePath).child("waitForMatch").observeSingleEvent(of: .value) { [weak self] snapshot in
//            guard let self = self else { return }
//
//            if var waitForMatch = snapshot.value as? [String], let index = waitForMatch.firstIndex(of: targetUserEmail.replacingOccurrences(of: ".", with: "_dot_")) {
//                waitForMatch.remove(at: index)
//                self.ref.child(currentUserNodePath).child("waitForMatch").setValue(waitForMatch)
//            }
//        }
//
//        // Remove the current user from the target user's liked list
//        ref.child(targetUserNodePath).child("liked").observeSingleEvent(of: .value) { snapshot in
//            if var liked = snapshot.value as? [String], let index = liked.firstIndex(of: self.currentUserEmail.replacingOccurrences(of: ".", with: "_dot_")) {
//                liked.remove(at: index)
//                self.ref.child(targetUserNodePath).child("liked").setValue(liked)
//            }
//        }
//
//        // Add the current user to the target user's matched list
//        ref.child(targetUserNodePath).child("matched").observeSingleEvent(of: .value) { snapshot in
//            var matched = snapshot.value as? [String] ?? []
//            matched.append(self.currentUserEmail.replacingOccurrences(of: ".", with: "_dot_"))
//            self.ref.child(targetUserNodePath).child("matched").setValue(matched)
//        }
//
//        // Update the match information
//        updateMatch(user1: currentUserEmail, user2: targetUserEmail)
//    }
//
//    func updateLiked(targetUserEmail: String) {
//        let userNodePath = "userMatchInfo/\(currentUserEmail.replacingOccurrences(of: ".", with: "_dot_"))"
//
//        // 현재 유저의 liked에 targetUserEmail을 추가
//        ref.child(userNodePath).child("liked").observeSingleEvent(of: .value) { [weak self] snapshot in
//            guard let self = self else { return }
//
//            var liked = snapshot.value as? [String] ?? []
//            liked.append(targetUserEmail.replacingOccurrences(of: ".", with: "_dot_"))
//
//            // 상대방의 waitForMatch에 현재 유저를 추가
//            self.updateWaitForMatchInOpponent(targetUserEmail: targetUserEmail)
//
//            self.ref.child(userNodePath).child("liked").setValue(liked)
//        }
//    }
//
//    func updateWaitForMatchInOpponent(targetUserEmail: String) {
//        let opponentNodePath = "userMatchInfo/\(targetUserEmail.replacingOccurrences(of: ".", with: "_dot_"))"
//
//        // 상대방의 waitForMatch에 현재 유저를 추가
//        ref.child(opponentNodePath).child("waitForMatch").observeSingleEvent(of: .value) { snapshot in
//            var waitForMatch = snapshot.value as? [String] ?? []
//            waitForMatch.append(self.currentUserEmail.replacingOccurrences(of: ".", with: "_dot_"))
//            self.ref.child(opponentNodePath).child("waitForMatch").setValue(waitForMatch)
//        }
//    }
//
//
//    func updateMatched(targetUserEmail: String) {
//        let userNodePath = "userMatchInfo/\(currentUserEmail.replacingOccurrences(of: ".", with: "_dot_"))"
//
//        // 현재 유저의 matched에 targetUserEmail을 추가
//        ref.child(userNodePath).child("matched").observeSingleEvent(of: .value) { snapshot in
//            var matched = snapshot.value as? [String] ?? []
//            matched.append(targetUserEmail.replacingOccurrences(of: ".", with: "_dot_"))
//            self.ref.child(userNodePath).child("matched").setValue(matched)
//        }
//    }
//    
//    func updateMatch(user1: String, user2: String) {
//        // match 노드에 유저 간의 매칭 정보를 추가
//        ref.child("match").observeSingleEvent(of: .value) { snapshot in
//            var matches = snapshot.value as? [[String]] ?? []
//            matches.append([user1.replacingOccurrences(of: ".", with: "_dot_"), user2.replacingOccurrences(of: ".", with: "_dot_")])
//            self.ref.child("match").setValue(matches)
//        }
//    }
//    
//}
