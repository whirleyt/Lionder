//
//  createMainProfileVC.swift
//  TeamAlgeria
//
//  Created by Tara Whirley on 11/29/23.
//
//
//  createMainProfileVC.swift
//  TeamAlgeria
//
//  Created by Tara Whirley on 11/29/23.
//


import UIKit
import Firebase

class createMainProfileVC: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var school: UITextField!
    @IBOutlet weak var gender: UITextField!
    @IBOutlet weak var pronouns: UITextField!

    let schoolDropdownValues = ["Columbia College",
                                "SEAS",
                                "Columbia Business School",
                                "Graduate School of Arts and Sciences",
                                "School of General Studies",
                                "Columbia Law School",
                                "Mailman School of Public Health",
                                "Columbia University College of Physicians and Surgeons",
                                "SIPA",
                                "Graduate School of Journalism",
                                "School of the Arts",
                                "GSAPP"]

    let genderDropdownValues = ["Male","Female","Non-binary", "Perfer not to say"]

    let pronounsDropdownValues = ["He/Him","She/Her","They/Them", "Other"]

    lazy var schoolPickerView: UIPickerView = UIPickerView()
    lazy var genderPickerView: UIPickerView = UIPickerView()
    lazy var pronounsPickerView: UIPickerView = UIPickerView()

    var activePickerView: UIPickerView?

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case schoolPickerView:
            return schoolDropdownValues.count
        case genderPickerView:
            return genderDropdownValues.count
        case pronounsPickerView:
            return pronounsDropdownValues.count
        default:
            return 0
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case schoolPickerView:
            return schoolDropdownValues[row]
        case genderPickerView:
            return genderDropdownValues[row]
        case pronounsPickerView:
            return pronounsDropdownValues[row]
        default:
            return nil
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case schoolPickerView:
            school.text = schoolDropdownValues[row]
        case genderPickerView:
            gender.text = genderDropdownValues[row]
        case pronounsPickerView:
            pronouns.text = pronounsDropdownValues[row]
        default:
            break
        }
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case school:
            activePickerView = schoolPickerView
        case gender:
            activePickerView = genderPickerView
        case pronouns:
            activePickerView = pronounsPickerView
        default:
            break
        }
        activePickerView?.dataSource = self
        activePickerView?.delegate = self
        textField.inputView = activePickerView
        addDoneButton(to: textField)
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

    var userProfile: UserProfile? = UserProfile(
        name: "",
        email: "",
        gender: "",
        pronouns: "",
        password: "",
        school: "",
        images: [],
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
        activePickerView?.resignFirstResponder()
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
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let email = userProfile?.email, !email.isEmpty,
           let password = userProfile?.password, password.count >= 6 {
           Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
               if let error = error {
                   print("Error creating user: \(error.localizedDescription)")
               } else {
                   print("User created successfully")
               }
           }
        } else {
           let alert = UIAlertController(title: "Error", message: "Email and password are required. Password must be at least 6 characters long.", preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
           present(alert, animated: true, completion: nil)
        }
        if let destination = segue.destination as? createPhotosBioProfileVC {
            self.userProfile?.pronouns = pronouns.text ?? ""
            destination.userProfile = self.userProfile
        }
    }
}
