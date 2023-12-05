//
//  MapViewController.swift
//  messaging
//
//  Created by Runwei Wang on 11/16/23.
//  Edited by Tara Whirley 12/4/23
//
import UIKit
import MapKit
import CoreLocation
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase

class MapViewController: UIViewController, CLLocationManagerDelegate {

    var databaseRef: DatabaseReference!

    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var emailForDB: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        let dbURL: String = "https://algeria-fb873-default-rtdb.firebaseio.com/"
        databaseRef = Database.database().reference(fromURL: dbURL)

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()

        let columbiaUniversityCoordinates = CLLocationCoordinate2D(latitude: 40.8075, longitude: -73.9626)
        let region = MKCoordinateRegion(center: columbiaUniversityCoordinates, latitudinalMeters: 500, longitudinalMeters: 500)

        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true

        if let currentUser = Auth.auth().currentUser {
            if let email = currentUser.email {
                emailForDB = email
                let fixedEmail = email.replacingOccurrences(of: ".", with: "_dot_")
                let userRef = databaseRef.child("user").child(fixedEmail)
                userRef.observeSingleEvent(of: .value, with: { snapshot in
                    guard snapshot.value is [String: Any] else {
                        print("User data not found.")
                        return
                    }
                })
            } else {
                print("Email is nil.")
            }
        } else {
            print("No user is currently signed in.")
        }

        let annotation1 = MapStudyAnnotation(
            coordinate: CLLocationCoordinate2D(latitude: 40.806378746859316, longitude: -73.96316316745433),
            title: "Butler Library",
            subtitle: "Friends studying at location: 0"
        )
        
        let annotation2 = MapStudyAnnotation(
            coordinate: CLLocationCoordinate2D(latitude: 40.80827726804546, longitude: -73.9608594295085),
            title: "Avery Library",
            subtitle: "Friends studying at location: 0"
        )
        
        let annotation3 = MapStudyAnnotation(
            coordinate: CLLocationCoordinate2D(latitude: 40.81017691619897, longitude: -73.96192394285819),
            title: "Northwest Corner Building",
            subtitle: "Friends studying at location: 0"
        )
        
        let annotation4 = MapStudyAnnotation(
            coordinate: CLLocationCoordinate2D(latitude: 40.80939165019247, longitude: -73.95988723566259),
            title: "Mudd Building",
            subtitle: "Friends studying at location: 0"
        )
        mapView.addAnnotation(annotation1)
        updateAnnotationSubtitle(annotation: annotation1)
        updateAnnotationSubtitle(annotation: annotation2)
        updateAnnotationSubtitle(annotation: annotation3)
        updateAnnotationSubtitle(annotation: annotation4)
    }

   
    @IBAction func joinButton(_ sender: Any) {
        if let selectedAnnotation = mapView.selectedAnnotations.first as? MapStudyAnnotation {
            print("Join button tapped for \(selectedAnnotation.title ?? "No Title")!")

            let studyMapRef = databaseRef.child("studyMap").child(selectedAnnotation.title!).child("emails").child(emailForDB.replacingOccurrences(of: ".", with: "_dot_"))
            studyMapRef.setValue(true)
            
            updateAnnotationSubtitle(annotation: selectedAnnotation)
        }
    }

    @IBAction func leaveButton(_ sender: Any) {
        if let selectedAnnotation = mapView.selectedAnnotations.first as? MapStudyAnnotation {
            print("Leave button tapped for \(selectedAnnotation.title ?? "No Title")!")

            let studyMapRef = databaseRef.child("studyMap").child(selectedAnnotation.title!).child("emails").child(emailForDB.replacingOccurrences(of: ".", with: "_dot_"))
            studyMapRef.removeValue()
            
            updateAnnotationSubtitle(annotation: selectedAnnotation)
        }
    }

    func updateAnnotationSubtitle(annotation: MapStudyAnnotation) {
        let studyMapRef = databaseRef.child("studyMap").child(annotation.title!).child("emails")
        studyMapRef.observeSingleEvent(of: .value, with: { snapshot in
            let emailCount = Int(snapshot.childrenCount)
            annotation.subtitle = "Friends studying at location: \(emailCount)"

            // Trigger a refresh
            self.mapView.removeAnnotation(annotation)
            self.mapView.addAnnotation(annotation)
        })
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

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MapStudyAnnotation {
            let identifier = "MapStudyAnnotationView"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MapStudyAnnotationView

            if annotationView == nil {
                annotationView = MapStudyAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            } else {
                annotationView?.annotation = annotation
            }

            return annotationView
        }

        return nil
    }
}
