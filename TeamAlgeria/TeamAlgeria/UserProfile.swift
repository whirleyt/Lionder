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
    var password: String?
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

    init() {
        self.name = ""
        self.email = ""
        self.gender = ""
        self.pronouns = ""
        self.password = ""
        self.school = ""
        self.images = []  // Initialize images here
        self.bio = ""
        self.sexualPreferences = ""
        self.agePreferences = ""
        self.interests = ""
        self.clubs = ""
        self.extracurriculars = ""
        self.major = ""
        self.minor = ""
        self.classes = ""
    }

    init?(data: [String: Any]) {
        guard
            let name = data["name"] as? String,
            let email = data["email"] as? String,
            let gender = data["gender"] as? String,
            let pronouns = data["pronouns"] as? String,
            let password = data["password"] as? String,
            let school = data["school"] as? String,
            let bio = data["bio"] as? String,
            let sexualPreferences = data["sexualPreferences"] as? String,
            let agePreferences = data["agePreferences"] as? String,
            let interests = data["interests"] as? String,
            let clubs = data["clubs"] as? String,
            let extracurriculars = data["extracurriculars"] as? String,
            let major = data["major"] as? String,
            let minor = data["minor"] as? String,
            let classes = data["classes"] as? String
        else {
            return nil
        }

        // Initialize images property as an array of Data
        var images: [Data] = []
        if let imagesData = data["images"] as? [Data] {
            images = imagesData
        }

        self.name = name
        self.email = email
        self.gender = gender
        self.pronouns = pronouns
        self.password = password
        self.school = school
        self.images = images.compactMap { UIImage(data: $0) } // Convert Data to UIImage
        self.bio = bio
        self.sexualPreferences = sexualPreferences
        self.agePreferences = agePreferences
        self.interests = interests
        self.clubs = clubs
        self.extracurriculars = extracurriculars
        self.major = major
        self.minor = minor
        self.classes = classes
    }

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
