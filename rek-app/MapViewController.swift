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

    var annotations = [RichDestination]()
    
    @IBOutlet weak var mapview: MKMapView!
    
    var selectedDestination: RichDestination?
    
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
    
//    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//        
//        let calloutView = MapCalloutView()
//        calloutView.richDestination = view.annotation as! RichDestination
//        calloutView.setup(view: view)
//        view.insertSubview(calloutView, at: 10)
//    }
//    
//    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
//        for v in view.subviews {
//            v.removeFromSuperview()
//        }
//    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        selectedDestination = view.annotation as? RichDestination
        performSegue(withIdentifier: Identifiers.Segues.mapToDetail, sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapview.delegate = self
        mapview.addAnnotations(annotations)
        mapview.showAnnotations(Array(annotations.prefix(10)), animated: true)
        if selectedDestination != nil {
            mapview.selectAnnotation(selectedDestination!, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Identifiers.Segues.mapToDetail {
            if let viewController = segue.destination as? DestinationDetailViewController {
                viewController.richDestination = selectedDestination
                viewController.destination = selectedDestination?.destination
            }
        }
    }

}
