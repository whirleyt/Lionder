//
//  MapViewController.swift
//  messaging
//
//  Created by Runwei Wang on 11/16/23.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate{
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()

        let columbiaUniversityCoordinates = CLLocationCoordinate2D(latitude: 40.8075, longitude: -73.9626)
        let region = MKCoordinateRegion(center: columbiaUniversityCoordinates, latitudinalMeters: 500, longitudinalMeters: 500)
        
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
    }

    func showAlertWithSettings(_ message: String) {
        let alertController = UIAlertController(title: "Location Access Denied",
                                                message: message,
                                                preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        present(alertController, animated: true, completion: nil)
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
