import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import SDWebImage

class UserProfileVC: UIViewController {

    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var image1: UIImageView!
    @IBOutlet var image2: UIImageView!
    @IBOutlet var image3: UIImageView!
    @IBOutlet var image4: UIImageView!

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var pronouns: UILabel!
    @IBOutlet weak var gender: UILabel!
    @IBOutlet weak var school: UILabel!
    @IBOutlet weak var bio: UILabel!

    @IBOutlet weak var logOutButton: UIButton!
    
    var databaseRef: DatabaseReference!
    var userProfile: UserProfile? = UserProfile()
    var storageRef: StorageReference!
    var db: Firestore!
    var emailForDB: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFirebase()
        
        databaseRef = Database.database().reference()

        if let currentUser = Auth.auth().currentUser {
            if let email = currentUser.email {
                let fixedEmail = email.replacingOccurrences(of: ".", with: "_dot_")
                emailForDB = email
                let userRef = databaseRef.child("user").child(fixedEmail)

                userRef.observeSingleEvent(of: .value, with: { snapshot in
                    guard let snapshotValue = snapshot.value as? [String: Any] else {
                        print("User data not found.")
                        return
                    }

                    if let userProfile = UserProfile(data: snapshotValue) {
                        self.updateUI(with: userProfile)
                    } else {
                        print("Failed to create UserProfile.")
                    }
                })
            } else {
                print("Email is nil.")
            }
        } else {
            print("No user is currently signed in.")
        }

        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        profileImage.clipsToBounds = true
    }

    func setupFirebase() {
        storageRef = Storage.storage().reference()
        db = Firestore.firestore()
    }

    func fetchFirstPhoto() {
        guard let email = userProfile?.email else {
            return
        }

        let userRef = db.collection("user").document(self.emailForDB).collection("images").document("image0")

        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let imageName = document.data()?["downloadURL"] as? String {
                    self.loadImageFromStorage(imageURL: imageName, imageView: self.profileImage)
                    self.loadImageFromStorage(imageURL: imageName, imageView: self.image1)
                } else {
                    print("No download URL found in Firestore.")
                }
            } else {
                print("Document does not exist in Firestore.")
            }
        }
    }

    func fetchSecondPhoto() {
        guard let email = userProfile?.email else {
            return
        }

        let userRef = db.collection("user").document(self.emailForDB).collection("images").document("image1")

        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let imageName = document.data()?["downloadURL"] as? String {
                    self.loadImageFromStorage(imageURL: imageName, imageView: self.image2)
                } else {
                    print("No download URL found in Firestore.")
                }
            } else {
                print("Document does not exist in Firestore.")
            }
        }
    }

    func fetchThirdPhoto() {
        guard let email = userProfile?.email else {
            return
        }

        let userRef = db.collection("user").document(self.emailForDB).collection("images").document("image2")

        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let imageName = document.data()?["downloadURL"] as? String {
                    self.loadImageFromStorage(imageURL: imageName, imageView: self.image3)
                } else {
                    print("No download URL found in Firestore.")
                }
            } else {
                print("Document does not exist in Firestore.")
            }
        }
    }

    func fetchFourthPhoto() {
        guard let email = userProfile?.email else {
            return
        }

        let userRef = db.collection("user").document(self.emailForDB).collection("images").document("image3")

        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let imageName = document.data()?["downloadURL"] as? String {
                    self.loadImageFromStorage(imageURL: imageName, imageView: self.image4)
                } else {
                    print("No download URL found in Firestore.")
                }
            } else {
                print("Document does not exist in Firestore.")
            }
        }
    }

    func loadImageFromStorage(imageURL: String, imageView: UIImageView) {
        if let url = URL(string: imageURL) {
            imageView.sd_setImage(with: url, completed: nil)
        }
    }

    func updateUI(with userProfile: UserProfile) {
        name.text = userProfile.name
        pronouns.text = userProfile.pronouns
        gender.text = userProfile.gender
        school.text = userProfile.school
        bio.text = userProfile.bio

        fetchFirstPhoto()
        fetchSecondPhoto()
        fetchThirdPhoto()
        fetchFourthPhoto()
    }
    
    func signOut() {
        AuthenticationManager.signOut { error in
            if let error = error {
                print("Sign-out error: \(error.localizedDescription)")
            } else {
                Coordinator.showLoginScreen()
            }
        }
    }

    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        signOut()
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? MatchProfileVC {
            destination.userProfile?.email = self.emailForDB
        }
    }

}
