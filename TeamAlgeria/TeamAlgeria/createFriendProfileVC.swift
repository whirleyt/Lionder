//
//  createFriendProfileVC.swift
//  TeamAlgeria
//
//  Created by Tara Whirley on 11/29/23.
//

import UIKit

class createFriendProfileVC: UIViewController, UITextFieldDelegate  {

    @IBOutlet weak var interests: UITextField!
    @IBOutlet weak var clubs: UITextField!
    @IBOutlet weak var extracurriculars: UITextField!
    
    var userProfile: UserProfile?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        interests?.delegate = self
        clubs?.delegate = self
        extracurriculars?.delegate = self
        
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
         case "interests":
            userProfile?.interests = textField.text ?? ""
         case "clubs":
            userProfile?.clubs = textField.text ?? ""
         case "extracurriculars":
            userProfile?.extracurriculars = textField.text ?? ""
         default:
             print("Unhandled identifier: \(identifier)")
         }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? createStudyProfileVC {
            self.userProfile?.extracurriculars = extracurriculars.text ?? ""
            destination.userProfile = self.userProfile
        }
    }

}
