//
//  RichDestination.swift
//  rek-app
//
//  Created by Matthew Slotkin on 4/3/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class RichDestination: NSObject {
    var destination: Destination
    var inboundRecommendations: [Recommendation]
    var reviews: [Review]
    var ownReview: Review?
    var thanksSent: [Thank]
    var thanksReceived: [Thank]
    
    var reviewRating: Double? {
        get {
            if reviewCount > 0 {
                return Double(reviews.flatMap{$0.rating}.reduce(0, +)) / Double(reviewCount)
            }
            return nil
        }
    }
    
    func ratingFor(_ userId: Int) -> Double? {
        return reviews.first{$0.user.id == userId}.flatMap{$0.rating}
    }
    
    var reviewCount: Int {
        get {
            return reviews.filter{$0.rating != nil}.count
        }
    }
    
    init(destination: Destination, inboundRecommendations: [Recommendation], reviews: [Review], ownReview: Review?, thanksSent: [Thank], thanksReceived: [Thank]) {
        self.destination = destination
        self.inboundRecommendations = inboundRecommendations
        self.reviews = reviews
        self.ownReview = ownReview
        self.thanksSent = thanksSent
        self.thanksReceived = thanksReceived
        super.init()
    }
    
    func distanceAway(currentLocation: CLLocationCoordinate2D) -> CLLocationDistance {
        return CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
            .distance(from: CLLocation(latitude: destination.latitude, longitude: destination.longitude))
    }
}

extension RichDestination: MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        get {
            return destination.coordinate
        }
        set {
            destination.coordinate = coordinate
        }
    }
    
    var title: String? {
        get {
            return destination.name
        }
    }
}
