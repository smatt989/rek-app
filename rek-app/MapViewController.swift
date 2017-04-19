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
    
    var specificUserReviews: User?
    
    @IBOutlet weak var mapview: MKMapView!
    
    var selectedDestination: RichDestination?
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        
        var view: MKAnnotationView! = mapView.dequeueReusableAnnotationView(withIdentifier: "marker")
        if view == nil {
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: "marker")
        } else {
            view.annotation = annotation
        }
        
        let destination = annotation as! RichDestination
        
        var rating: Double?
        if specificUserReviews != nil {
            rating = destination.ratingFor(specificUserReviews!.id)
        } else {
            rating = destination.reviewRating
        }
        
        
        view.image = pinImageGivenRating(rating ?? -1).imageResize(sizeChange: CGSize(width: 37.0, height: 38.0))
        view.centerOffset = CGPoint(x: 0, y: view.image!.size.height / -2.0)
        
        view.canShowCallout = true
        let button = UIButton(type: .detailDisclosure)
        view.rightCalloutAccessoryView = button

        
        return view
    }
    
    private func pinImageGivenRating(_ rating: Double) -> UIImage{
        switch rating {
        case _ where rating > 4.5:
            return #imageLiteral(resourceName: "marker-rating-5")
        case _ where rating > 3.5:
            return #imageLiteral(resourceName: "marker-rating-4")
        case _ where rating > 2.5:
            return #imageLiteral(resourceName: "marker-rating-3")
        case _ where rating > 1.5:
            return #imageLiteral(resourceName: "marker-rating-2")
        case _ where rating > 0.0:
            return #imageLiteral(resourceName: "marker-rating-1")
        default:
            return #imageLiteral(resourceName: "marker-rating-5")
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        selectedDestination = view.annotation as? RichDestination
        performSegue(withIdentifier: Identifiers.Segues.mapToDetail, sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapview.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mapview.addAnnotations(annotations)
        mapview.showAnnotations(Array(annotations.prefix(7)), animated: true)
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

extension UIImage {
    
    func imageResize (sizeChange:CGSize)-> UIImage{
        
        let hasAlpha = true
        let scale: CGFloat = 0.0 // Use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        self.draw(in: CGRect(origin: CGPoint.zero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage!
    }
    
}
