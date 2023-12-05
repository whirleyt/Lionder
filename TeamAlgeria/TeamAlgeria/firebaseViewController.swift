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
    
    @IBAction func loginButton(_ sender: Any)
    {
        
//        let email = emailText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
//        let password = passwordText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let email = "hh2989@columbia.edu"
        let password = "aaaaaa"
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil {
            let alert = UIAlertController(title: "Error", message: "\(error!.localizedDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                self.present(alert, animated: true)
            } else {
                print("Login Successful")
                
                if let tabBarController = self.storyboard?.instantiateViewController(withIdentifier: "tabBarController") as? UITabBarController {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first {
                        window.rootViewController = tabBarController
                        window.makeKeyAndVisible()
                        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
                    }
                }

            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        passwordText.isSecureTextEntry = true
        emailText.autocorrectionType = .no
    }
}
