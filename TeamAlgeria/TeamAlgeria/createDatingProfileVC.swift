//
//  createDatingProfileVC.swift
//  TeamAlgeria
//
//  Created by Tara Whirley on 11/29/23.
//

import UIKit

class createDatingProfileVC: UIViewController, UITextFieldDelegate  {
    
    
    @IBOutlet weak var sexualPreferences: UITextField!
    @IBOutlet weak var agePreferences: UITextField!
    
    var userProfile: UserProfile?

    override func viewDidLoad() {
        super.viewDidLoad()
        sexualPreferences?.delegate = self
        agePreferences?.delegate = self
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
         case "sexualPreferences":
            userProfile?.sexualPreferences = textField.text ?? ""
         case "agePreferences":
            userProfile?.agePreferences = textField.text ?? ""
         default:
             print("Unhandled identifier: \(identifier)")
         }
        print(userProfile as Any)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? createFriendProfileVC {
            self.userProfile?.agePreferences = agePreferences.text ?? ""
            destination.userProfile = self.userProfile
        }
    }

}
