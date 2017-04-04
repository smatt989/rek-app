//
//  DestinationUtilities.swift
//  rek-app
//
//  Created by Matthew Slotkin on 4/3/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import Foundation
import CoreLocation

class DestinationUtilities {
    static func distanceToString(distance: CLLocationDistance) -> String {
        if distance < 1000 {
            return String(Int(round(distance / 10) * 10)) + "m"
        } else {
            return String(Int(round(distance / 1000))) + "km"
        }
    }
}
