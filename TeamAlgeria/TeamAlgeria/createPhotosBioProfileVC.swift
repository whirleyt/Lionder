//
//  createPhotosBioProfileVC.swift
//  TeamAlgeria
//
//  Created by Tara Whirley on 11/29/23.
//

import UIKit

class createPhotosBioProfileVC: UIViewController, UITextFieldDelegate  {

    @IBOutlet weak var bio: UITextField!
    
    var userProfile: UserProfile?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bio?.delegate = self
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
         case "bio":
            userProfile?.bio = textField.text ?? ""
         default:
             print("Unhandled identifier: \(identifier)")
         }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? createDatingProfileVC {
            self.userProfile?.bio = bio.text ?? ""
            destination.userProfile = self.userProfile
        }
    }

}
