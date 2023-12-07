//  createDatingProfileVC.swift
//  TeamAlgeria
//
//  Created by Tara Whirley on 11/29/23.
//

import UIKit

class createDatingProfileVC: UIViewController, UITextFieldDelegate, UIPickerViewDataSource,
                             UIPickerViewDelegate {

    @IBOutlet weak var sexualPreferences: UITextField!
    @IBOutlet weak var agePreferences: UITextField!

    var userProfile: UserProfile?
    
    let sexualPreferenceValues = ["Male","Female","Both"]
    
    lazy var sexualPreferencesPickerView: UIPickerView = UIPickerView()

    var activePickerView: UIPickerView?

    override func viewDidLoad() {
        super.viewDidLoad()

        sexualPreferences?.delegate = self
        agePreferences?.delegate = self
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case sexualPreferencesPickerView:
            return sexualPreferenceValues.count
        default:
            return 0
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case sexualPreferencesPickerView:
            return sexualPreferenceValues[row]
        default:
            return nil
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case sexualPreferencesPickerView:
            sexualPreferences.text = sexualPreferenceValues[row]
        default:
            break
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case sexualPreferences:
            activePickerView = sexualPreferencesPickerView
        default:
            activePickerView = nil
        }
        
        if let pickerView = activePickerView {
            pickerView.dataSource = self
            pickerView.delegate = self
            textField.inputView = pickerView
            addDoneButton(to: textField)
        } else {
            textField.inputView = nil
        }
    }

    func addDoneButton(to textField: UITextField) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))

        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        textField.inputAccessoryView = toolbar
    }

    @objc func doneButtonTapped() {
        view.endEditing(true)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        activePickerView?.resignFirstResponder()
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
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? createFriendProfileVC {
            self.userProfile?.agePreferences = agePreferences.text ?? ""
            destination.userProfile = self.userProfile
        }
    }
}
