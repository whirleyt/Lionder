//
//  AuthenticationManager.swift
//  TeamAlgeria
//
//  Created by Vincent Han on 12/6/23.
//

import UIKit
import Firebase
import FirebaseAuth

class AuthenticationManager {
    static func signOut(completion: @escaping (Error?) -> Void) {
        do {
            try Auth.auth().signOut()
            print("Logged Out Successfully!")
            completion(nil)
        } catch let signOutError as NSError {
            print("Failed to log out: \(signOutError.localizedDescription)")
            completion(signOutError)
        }
    }
}


class Coordinator {
    static func showLoginScreen() {
        if let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "logInPage") as? firebaseViewController {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let delegate = windowScene.delegate as? SceneDelegate {
                delegate.window?.rootViewController = loginVC
                delegate.window?.makeKeyAndVisible()
            }
        }
    }
}

