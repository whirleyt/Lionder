//
//  createStudyProfileVC.swift
//  TeamAlgeria
//
//  Created by Tara Whirley on 11/29/23.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import FirebaseFirestore
import FirebaseStorage

class createStudyProfileVC: UIViewController, UITextFieldDelegate  {
    
    var ref: DatabaseReference!

    @IBOutlet weak var major: UITextField!
    @IBOutlet weak var minor: UITextField!
    @IBOutlet weak var classes: UITextField!
    
    var userProfile: UserProfile?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        major?.delegate = self
        minor?.delegate = self
        classes?.delegate = self
        
        let dbURL:String = "https://algeria-fb873-default-rtdb.firebaseio.com/"
        ref = Database.database().reference(fromURL: dbURL)
    }
    
    @IBAction func signUpButton(_ sender: Any) {
        self.userProfile?.classes = classes.text ?? ""

        guard let userProfileDict = try? userProfile?.asDictionary(),
              let email = userProfile?.email else {
            return
        }
        
        guard let sanitizedEmail = userProfile?.email.replacingOccurrences(of: ".", with: "_dot_") else { return
        }
        self.ref.child("user").child(sanitizedEmail).setValue(userProfileDict)
        
        if let tabBarController = self.storyboard?.instantiateViewController(withIdentifier: "tabBarController") as? UITabBarController {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = tabBarController
                window.makeKeyAndVisible()
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        processTextFieldInput(textField)
      }
    
    func processTextFieldInput(_ textField: UITextField) {
        guard let identifier = textField.accessibilityIdentifier else {
            print("Error: Text field has no accessibility identifier")
            return
        }

        switch identifier {
         case "major":
            userProfile?.major = textField.text ?? ""
         case "minor":
            userProfile?.minor = textField.text ?? ""
         case "classes":
            userProfile?.classes = textField.text ?? ""
         default:
             print("Unhandled identifier: \(identifier)")
         }
    }

}
