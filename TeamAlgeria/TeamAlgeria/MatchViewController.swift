import UIKit
import Firebase
import FirebaseStorage
import SDWebImage

struct User {
    let userID: String
    let userData: [String: Any]
}

class MatchViewController: UIViewController {

    var ref: DatabaseReference!
    var storageRef: StorageReference!

    var loadedUsers: [User] = []
    var currentIndex = 0
    var imageView: UIImageView?
    
    var likedList: [User] = []
    var dislikedList: [User] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        storageRef = Storage.storage().reference()

        setupLayout()
        loadUserData()
    }

    
    func setupLayout() {
        view.backgroundColor = .white

        imageView = UIImageView(frame: CGRect(x: 20, y: 100, width: view.frame.width - 40, height: view.frame.height - 200))
        imageView?.contentMode = .scaleAspectFill
        imageView?.layer.cornerRadius = 20
        imageView?.clipsToBounds = true
        imageView?.layer.borderWidth = 2
        imageView?.layer.borderColor = UIColor.lightGray.cgColor
        imageView?.isUserInteractionEnabled = true
        view.addSubview(imageView!)

        imageView?.layer.shadowColor = UIColor.black.cgColor
        imageView?.layer.shadowOpacity = 0.5
        imageView?.layer.shadowOffset = CGSize(width: 0, height: 2)
        imageView?.layer.shadowRadius = 4

        let swipeGesture = UIPanGestureRecognizer(target: self, action: #selector(didSwipe))
        imageView?.addGestureRecognizer(swipeGesture)
    }

    func loadUserData() {
        guard let currentUserEmail = Auth.auth().currentUser?.email else {
            print("User not logged in")
            return
        }

        ref.child("user").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }

            if let currentUserData = snapshot.childSnapshot(forPath: currentUserEmail.replacingOccurrences(of: ".", with: "_dot_")).value as? [String: Any],
               let currentUserGender = currentUserData["gender"] as? String {

                self.loadAllUsers(currentUserGender: currentUserGender)
            } else {
                print("No data available for current user")
            }
        }
    }

    func loadAllUsers(currentUserGender: String) {
        ref.child("user").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }

            guard let allUsersData = snapshot.value as? [String: Any] else {
                print("No data available for users")
                return
            }

            self.filterUsers(currentUserGender: currentUserGender, allUsersData: allUsersData)
        }
    }

    func filterUsers(currentUserGender: String, allUsersData: [String: Any]) {
        for (userID, userData) in allUsersData {
            if let userDataDict = userData as? [String: Any], let userGender = userDataDict["gender"] as? String {
                if userGender != currentUserGender {
                    let cleanedUserID = cleanUserID(userID: userID)
                    let user = User(userID: cleanedUserID, userData: userDataDict)
                    loadedUsers.append(user)
                }
            }
        }

        loadNextImage()
    }

    @objc func didSwipe(_ gesture: UIPanGestureRecognizer) {
        guard let imageView = imageView else { return }

        let translation = gesture.translation(in: view)

        imageView.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)

        let rotationStrength = min(translation.x / view.frame.width, 1)
        let rotationAngle = .pi/8 * rotationStrength
        let scaleFactor = max(1 - abs(rotationStrength) / 4, 0.7)

        var transform = CGAffineTransform(rotationAngle: rotationAngle)
        transform = transform.scaledBy(x: scaleFactor, y: scaleFactor)
        imageView.transform = transform

        let alpha = 1 - abs(translation.x / (view.frame.width / 2))
        imageView.alpha = alpha

        if gesture.state == .ended {
            if translation.x < -125 {
                animateImageOffScreen(direction: .left)
                addToDislikedList()
            } else if translation.x > 125 {
                animateImageOffScreen(direction: .right)
                addToLikedList()
            } else {
                resetImageView()
            }
        }
    }

    func addToLikedList() {
        guard currentIndex < loadedUsers.count else { return }
        let likedUser = loadedUsers[currentIndex]
        likedList.append(likedUser)
    }

    func addToDislikedList() {
        guard currentIndex < loadedUsers.count else { return }
        let dislikedUser = loadedUsers[currentIndex]
        dislikedList.append(dislikedUser)
    }

    func animateImageOffScreen(direction: AnimationDirection) {
        guard let imageView = imageView, currentIndex > 0 else { return }

        let screenWidth = view.frame.width
        let offScreenX = direction == .left ? -screenWidth : screenWidth * 2

        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
            imageView.transform = CGAffineTransform(rotationAngle: direction == .left ? -0.2 : 0.2)
            imageView.center = CGPoint(x: offScreenX, y: imageView.center.y + 200)
            imageView.alpha = 0.0
        }) { (_) in
            self.loadNextImage()
            self.printLikedList()
            self.printDislikedList()
            self.resetImageView()
        }
    }

    func resetImageView() {
        guard let imageView = imageView else { return }

        UIView.animate(withDuration: 0.3) {
            imageView.center = self.view.center
            imageView.transform = .identity
            imageView.alpha = 1.0
        }
    }

    func loadNextImage() {
        guard currentIndex < loadedUsers.count else {
            print("No more images to load.")

            let messageLabel = UILabel(frame: CGRect(x: 20, y: 100, width: view.frame.width - 40, height: 100))
            messageLabel.text = "No more user found!\nSorry, Try later!"
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            messageLabel.center = view.center
            view.addSubview(messageLabel)

            imageView?.isHidden = true
            return
        }

        let user = loadedUsers[currentIndex]
        let userID = user.userID

        let userEmail = cleanUserID(userID: userID)

        downloadImageForUser(userID: userID)
        currentIndex += 1

        print("Current user's email: \(userEmail)")
    }

    func cleanUserID(userID: String) -> String {
        return userID.replacingOccurrences(of: "_dot_", with: ".")
    }

    func downloadImageForUser(userID: String) {
        let userImagesRef = storageRef.child("user/\(userID)/images")

        userImagesRef.listAll { [weak self] (result, error) in
            guard let self = self else { return }

            if let error = error {
                print("Error listing user images: \(error)")
            } else {
                if let firstImage = result?.items.first {
                    self.downloadImage(from: firstImage)
                } else {
                    print("No images found for the user.")
                }
            }
        }
    }

    func downloadImage(from storageReference: StorageReference) {
        storageReference.downloadURL { [weak self] (url, error) in
            guard let self = self, let url = url else {
                return
            }

            SDWebImageManager.shared.loadImage(with: url, options: .highPriority, progress: nil) { (image, _, _, _, _, _) in
                if let image = image {
                    self.imageView?.image = image
                }
            }
        }
    }

    func printLikedList() {
        print("Liked Users:")
        for user in likedList {
            print("UserID: \(user.userID), UserData: \(user.userData)")
        }
    }

    func printDislikedList() {
        print("Disliked Users:")
        for user in dislikedList {
            print("UserID: \(user.userID), UserData: \(user.userData)")
        }
    }

    enum AnimationDirection {
        case left
        case right
    }
}
