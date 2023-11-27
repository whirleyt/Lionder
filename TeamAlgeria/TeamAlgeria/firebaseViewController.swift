//
//  firebaseViewController.swift
//  TeamAlgeria
//
//  Created by Tara Whirley on 11/19/23.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import FirebaseFirestore
import FirebaseStorage


class firebaseViewController: UIViewController, UITextFieldDelegate {
    
    var ref: DatabaseReference!
    
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var school: UITextField!
    @IBOutlet weak var gender: UITextField!
    @IBOutlet weak var pronouns: UITextField!
    @IBOutlet weak var bio: UITextField!
    
    @IBOutlet weak var sexualPreferences: UITextField!
    @IBOutlet weak var agePreferences: UITextField!
    
    @IBOutlet weak var interests: UITextField!
    @IBOutlet weak var clubs: UITextField!
    @IBOutlet weak var extracurriculars: UITextField!
    
    @IBOutlet weak var major: UITextField!
    @IBOutlet weak var minor: UITextField!
    @IBOutlet weak var classes: UITextField!
    
    var textValues: [String: String] = [:]
    
    
    @IBAction func loginButton(_ sender: Any)
    {
        
        let email = emailText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil {
            let alert = UIAlertController(title: "Error", message: "\(error!.localizedDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                self.present(alert, animated: true)
            } else {
//                self.performSegue(withIdentifier: "homePageSegue", sender: nil)
                print("Login Successful")
                }
            }
    }
    
    @IBAction func signUpButton(_ sender: Any)
    {
        print("Text Values: \(textValues)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
       
        let dbURL:String = "https://algeria-fb873-default-rtdb.firebaseio.com/"
        ref = Database.database().reference(fromURL: dbURL)
        self.ref.child("user").setValue(1234)
        self.ref.child("user").child("1234").setValue(["email": "tjw2154@columbia.edu"])
        name?.delegate = self
        email?.delegate = self
        password?.delegate = self
        school?.delegate = self
        gender?.delegate = self
        pronouns?.delegate = self
        bio?.delegate = self
        sexualPreferences?.delegate = self
        agePreferences?.delegate = self
        interests?.delegate = self
        clubs?.delegate = self
        extracurriculars?.delegate = self
        major?.delegate = self
        minor?.delegate = self
        classes?.delegate = self
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("Editing ended for \(textField.accessibilityIdentifier ?? "unknown field")")
        if let identifier = textField.accessibilityIdentifier {
            textValues[identifier] = textField.text
            print("Text value for \(identifier): \(textField.text ?? "nil")")
            print("Current Text Values: \(textValues)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? firebaseViewController {
            destination.textValues = self.textValues
        }
    }

}
