//
//  MapViewController.swift
//  rek-app
//
//  Created by Matthew Slotkin on 4/3/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    var annotations = [Destination]()
    
    @IBOutlet weak var mapview: MKMapView!
    
    var selectedDestination: Destination?
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
   
        }
        pinView!.canShowCallout = true
        let button = UIButton(type: .detailDisclosure)
        pinView!.rightCalloutAccessoryView = button
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        selectedDestination = view.annotation as? Destination
        performSegue(withIdentifier: Identifiers.Segues.mapToDetail, sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapview.delegate = self
        mapview.addAnnotations(annotations)
        mapview.showAnnotations(Array(annotations.prefix(10)), animated: true)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Identifiers.Segues.mapToDetail {
            print("trying here")
            if let viewController = segue.destination as? DestinationDetailViewController {
                print("assigning here")
                print("is defined?: \(selectedDestination != nil)")
                viewController.destination = selectedDestination
            }
        }
    }

}
