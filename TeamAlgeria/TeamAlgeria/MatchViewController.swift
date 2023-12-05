

import UIKit
import Firebase
import FirebaseStorage
import SDWebImage

class MatchViewController: UIViewController {

    var ref: DatabaseReference!
    var storageRef: StorageReference!
    
    var loadedUsers: [String] = []
    var currentIndex = 0
    var imageView: UIImageView?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Firebase Realtime Database 및 Storage에 대한 참조 생성
        ref = Database.database().reference()
        storageRef = Storage.storage().reference()

        // 현재 로그인한 사용자의 이메일 주소 가져오기
        if let currentUserEmail = Auth.auth().currentUser?.email {
            print("Current User Email: \(currentUserEmail)")

            // 예제로 'user' 경로에 있는 현재 사용자의 데이터 가져오기
            ref.child("user").observeSingleEvent(of: .value, with: { (snapshot) in
                // 성공적으로 데이터를 가져왔을 때의 처리
                if let currentUserData = snapshot.childSnapshot(forPath: currentUserEmail.replacingOccurrences(of: ".", with: "_dot_")).value as? [String: Any],
                   let currentUserGender = currentUserData["gender"] as? String {

                    print("Current User Gender: \(currentUserGender)")

                    // 'user' 경로에 있는 모든 사용자 데이터 가져오기
                    self.ref.child("user").observeSingleEvent(of: .value, with: { (snapshot) in
                        // 성공적으로 데이터를 가져왔을 때의 처리
                        if let allUsersData = snapshot.value as? [String: Any] {
                            // 모든 사용자 데이터를 순회하며 자기 자신과 성별이 다른 경우에만 출력
                            for (userID, userData) in allUsersData {
                                if let userDataDict = userData as? [String: Any], let userGender = userDataDict["gender"] as? String {
                                    if userGender != currentUserGender {
                                        print("User ID: \(userID), User Data: \(userDataDict)")
                                        
                                        let cleanedUserID = self.cleanUserID(userID: userID) // email address formatting
                                        self.loadedUsers.append(cleanedUserID)
                                    }
                                }
                            }
                            
                            // Setup initial image view
                            self.imageView = UIImageView(frame: CGRect(x: 20, y: 100, width: self.view.frame.width - 40, height: self.view.frame.height - 200))
                            self.view.addSubview(self.imageView!)

                            // Add swipe gesture recognizer
                            let swipeGesture = UIPanGestureRecognizer(target: self, action: #selector(self.didSwipe))
                            self.imageView?.addGestureRecognizer(swipeGesture)
                            self.imageView?.isUserInteractionEnabled = true

                            // Load initial image
                            self.loadNextImage()
                            
                        } else {
                            print("No data available for users")
                        }
                    }) { (error) in
                        // 데이터를 가져오는 도중 에러가 발생했을 때의 처리
                        print("Error fetching data: \(error.localizedDescription)")
                    }

                } else {
                    print("No data available for current user")
                }
            }) { (error) in
                // 데이터를 가져오는 도중 에러가 발생했을 때의 처리
                print("Error fetching current user data: \(error.localizedDescription)")
            }
        } else {
            print("User not logged in")
        }
    }

    @objc func didSwipe(_ gesture: UIPanGestureRecognizer) {
            guard let imageView = imageView else { return }

            let translation = gesture.translation(in: view)

            // Move the image view according to the user's swipe gesture
            imageView.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)

            let rotationStrength = min(translation.x / view.frame.width, 1)
            let rotationAngle = .pi/8 * rotationStrength
            let scaleFactor = max(1 - abs(rotationStrength) / 4, 0.7)

            // Apply rotation and scaling to the image view
            var transform = CGAffineTransform(rotationAngle: rotationAngle)
            transform = transform.scaledBy(x: scaleFactor, y: scaleFactor)
            imageView.transform = transform

            // Adjust alpha based on swipe distance
            let alpha = 1 - abs(translation.x / (view.frame.width / 2))
            imageView.alpha = alpha

            if gesture.state == .ended {
                if translation.x < -125 {
                    // User swiped left, animate the image to disappear to the left
                    animateImageOffScreen(direction: .left)
                } else if translation.x > 125 {
                    // User swiped right, animate the image to disappear to the right
                    animateImageOffScreen(direction: .right)
                } else {
                    // Return the image view to its original position if the swipe is not significant
                    resetImageView()
                }
            }
        }

    func animateImageOffScreen(direction: AnimationDirection) {
        guard let imageView = imageView else { return }

        let screenWidth = view.frame.width
        let offScreenX = direction == .left ? -screenWidth : screenWidth * 2

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            // Apply a curve to the image animation
            imageView.alpha = 0.0
            imageView.center = CGPoint(x: offScreenX, y: imageView.center.y + 100) // Adjust the curve
            imageView.transform = CGAffineTransform(rotationAngle: direction == .left ? -0.2 : 0.2) // Apply a rotation for a curve
        }) { (_) in
            // Animation completion block, load the next image
            self.loadNextImage()

            // Reset the image view to its original position and reset alpha
            self.resetImageView()
        }
    }
    
    func resetImageView() {
        guard let imageView = imageView else { return }

        UIView.animate(withDuration: 0.3) {
            // Reset the image view to its original position and reset alpha
            imageView.center = self.view.center
            imageView.transform = .identity
            imageView.alpha = 1.0
        }
    }

    func loadNextImage() {
            guard currentIndex < loadedUsers.count else {
                // No more images to load
                print("No more images to load.")

                // Display a message when there are no more images
                let messageLabel = UILabel(frame: CGRect(x: 20, y: 100, width: self.view.frame.width - 40, height: 100))
                messageLabel.text = "No more user found!\nSorry, Try later!"
                messageLabel.numberOfLines = 0
                messageLabel.textAlignment = .center
                messageLabel.center = self.view.center
                self.view.addSubview(messageLabel)

                // Hide the image view when there are no more images
                imageView?.isHidden = true

                return
            }

            let userID = loadedUsers[currentIndex]
            downloadImageForUser(userID: userID)
            currentIndex += 1
        }

        
    func cleanUserID(userID: String) -> String {
        // Replace "_dot_" with "."
        return userID.replacingOccurrences(of: "_dot_", with: ".")
    }
    

    func downloadImageForUser(userID: String) {
        let userImagesRef = storageRef.child("user/\(userID)/images")

        // Get the list of items (images) in the user's images folder
        userImagesRef.listAll { (result, error) in
            if let error = error {
                print("Error listing user images: \(error)")
            } else {
                // Safely unwrap the result and check if it has any items
                if let firstImage = result?.items.first {
                    self.downloadImage(from: firstImage)
                } else {
                    print("No images found for the user.")
                }
            }
        }
    }

    func downloadImage(from storageReference: StorageReference) {
        // Download and display the image using SDWebImage
        storageReference.downloadURL { (url, error) in
            if let url = url {
                SDWebImageManager.shared.loadImage(with: url, options: .highPriority, progress: nil) { (image, _, _, _, _, _) in
                    if let image = image {
                        // Now you have the image, you can use it as needed (e.g., display in UIImageView)
                        // For example, you might want to create a UIImageView and set its image property:
                        self.imageView?.image = image
                    }
                }
            }
        }
    }
    
    enum AnimationDirection {
        case left
        case right
    }
}


