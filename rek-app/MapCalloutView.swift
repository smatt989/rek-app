//
//  MapCalloutView.swift
//  rek-app
//
//  Created by Matthew Slotkin on 4/12/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit
import MapKit

class MapCalloutView: UIView {
    
    var richDestination: RichDestination?
    
    let width = CGFloat(150)
    let height = CGFloat(80)
    
    func setup(view: MKAnnotationView) {
        let annotationFrame = CGRect(x: (view.frame.width / 2 - view.centerOffset.x) - width / 2, y: view.frame.height / 2 - height - 25.0, width: width, height: height)
        frame = annotationFrame
        let label = UILabel()
        label.text = richDestination?.title
        label.frame = CGRect(x: 10, y: 10, width: 130, height: 20)
        insertSubview(label, at: 3)
        
        
        if let rating = richDestination?.reviewRating {
            let ratingLabel = UILabel()
            ratingLabel.text = "\(Int(rating * 100))%"
            ratingLabel.frame = CGRect(x: 10, y: 10 + label.frame.height + 5, width: 60, height: 15)
            insertSubview(ratingLabel, at: 3)
        }
        
        
        backgroundColor = UIColor.red
    }

}
