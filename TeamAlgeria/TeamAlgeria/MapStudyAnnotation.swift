//
//  MapStudyAnnotation.swift
//  TeamAlgeria
//
//  Created by Tara Whirley on 12/4/23.
//

import UIKit
import MapKit

class MapStudyAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        super.init()
    }
}

class MapStudyAnnotationView: MKAnnotationView {
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        if annotation is MapStudyAnnotation {
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
