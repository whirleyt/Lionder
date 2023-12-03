//
//  MatchViewController.swift
//  messaging
//
//  Created by Runwei Wang on 11/16/23.
//

import UIKit

class MatchViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func calendarButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showCalendar", sender: self)
    }
    @IBAction func profileButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showProfile", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCalendar" {
            // Pass data to the Calendar view controller if needed
        } else if segue.identifier == "showProfile" {
            // Pass data to the Profile view controller if needed
        }
    }
    
}
