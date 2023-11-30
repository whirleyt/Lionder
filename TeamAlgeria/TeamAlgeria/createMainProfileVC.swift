//
//  createMainProfileVC.swift
//  TeamAlgeria
//
//  Created by Tara Whirley on 11/29/23.
//

import UIKit
import Firebase

class createMainProfileVC: UIViewController, UITextFieldDelegate  {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var school: UITextField!
    @IBOutlet weak var gender: UITextField!
    @IBOutlet weak var pronouns: UITextField!
    
    var userProfile: UserProfile? = UserProfile(
           name: "",
           email: "",
           gender: "",
           pronouns: "",
           password: "",
           school: "",
           bio: "",
           sexualPreferences: "",
           agePreferences: "",
           interests: "",
           clubs: "",
           extracurriculars: "",
           major: "",
           minor: "",
           classes: ""
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        password.isSecureTextEntry = true
        name?.delegate = self
        email?.delegate = self
        password?.delegate = self
        school?.delegate = self
        gender?.delegate = self
        pronouns?.delegate = self

    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("Editing ended for \(textField.accessibilityIdentifier ?? "unknown field")")
        processTextFieldInput(textField)
      }
    
    func processTextFieldInput(_ textField: UITextField) {
        guard let identifier = textField.accessibilityIdentifier else {
            print("Error: Text field has no accessibility identifier")
            return
        }

        switch identifier {
         case "name":
            userProfile?.name = textField.text ?? ""
         case "email":
            userProfile?.email = textField.text ?? ""
         case "gender":
            userProfile?.gender = textField.text ?? ""
         case "pronouns":
            userProfile?.pronouns = textField.text ?? ""
         case "password":
            userProfile?.password = textField.text ?? ""
         case "school":
            userProfile?.school = textField.text ?? ""
         default:
             print("Unhandled identifier: \(identifier)")
         }
        print(userProfile as Any)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let email = userProfile?.email, !email.isEmpty,
              let password = userProfile?.password, !password.isEmpty else {
            let alert = UIAlertController(title: "Error", message: "Email and password are required.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Error creating user: \(error.localizedDescription)")
            } else {
                print("User created successfully")
            }
        }
        if let destination = segue.destination as? createPhotosBioProfileVC {
            self.userProfile?.pronouns = pronouns.text ?? ""
            destination.userProfile = self.userProfile
        }
    }
}
