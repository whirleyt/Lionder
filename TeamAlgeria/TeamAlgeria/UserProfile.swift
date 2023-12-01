//
//  UserProfile.swift
//  TeamAlgeria
//
//  Created by Tara Whirley on 11/29/23.
//

import UIKit

struct UserProfile {
      var name: String
      var email: String
      var gender: String
      var pronouns: String
      var password: String
      var school: String
      var images: [UIImage]
      var bio: String
      var sexualPreferences: String
      var agePreferences: String
      var interests: String
      var clubs: String
      var extracurriculars: String
      var major: String
      var minor: String
      var classes: String
      func asDictionary() -> [String: Any] {
        return [
            "name": name,
            "email": email,
            "gender": gender,
            "pronouns": pronouns,
            "password": password,
            "school": school,
            "bio": bio,
            "sexualPreferences": sexualPreferences,
            "agePreferences": agePreferences,
            "interests": interests,
            "clubs": clubs,
            "extracurriculars": extracurriculars,
            "major": major,
            "minor": minor,
            "classes": classes
        ]
    }
}
