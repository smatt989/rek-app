//
//  Destination.swift
//  rek-app
//
//  Created by Matthew Slotkin on 4/1/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class Destination: NSObject {
    var name: String
    var address: String
    var latitude: Double
    var longitude: Double
    var id: Int?
    
    init(name: String, address: String, latitude: Double, longitude: Double, id: Int?) {
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.id = id
        super.init()
    }
}

extension Destination: MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        set {
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
    }
    
    var title: String? {
        get {
            return name
        }
    }
}
