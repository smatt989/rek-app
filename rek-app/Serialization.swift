//
//  Serialization.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/12/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import Foundation
import CoreLocation

extension User {
    
    static func parseMany(data: Data) -> [User] {
        var newUsers = [User]()
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        
        if let array = json as? [[String: Any]] {
            newUsers = array.flatMap{ element in
                parseUserDict(dict: element)
            }
        }
        return newUsers
    }
    
    static func parseUser(data: Data) -> User?{
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [String: Any] {
            return parseUserDict(dict: json)
        }
        return nil
    }
    
    static func parseUserDict(dict: [String: Any]) -> User {
        let username = dict["username"] as! String
        let id = dict["id"] as! Int
        return User(username: username, id: id)
    }
}

extension UserCreate {
    
    func toJsonDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["username"] = username
        dict["email"] = email
        dict["password"] = password
        return dict
    }
}

extension UserConnectionAddRequest {
    
    func toJsonDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["addUserId"] = addUserId
        return dict
    }
}

extension Destination {
    
    func toJsonDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["name"] = name
        dict["address"] = address
        dict["latitude"] = latitude
        dict["longitude"] = longitude
        if id != nil {
            dict["id"] = id!
        }
        return dict
    }
    
    static func parseDestination(data: Data) -> Destination? {
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [String: Any] {
            return parseDestinationDict(dict: json)
        }
        return nil
    }
    
    static func parseDestinationDict(dict: [String: Any]) -> Destination {
        let name = dict["name"] as! String
        let address = dict["address"] as! String
        let latitude = dict["latitude"] as! Double
        let longitude = dict["longitude"] as! Double
        let id = dict["id"] as? Int
        return Destination(name: name, address: address, latitude: latitude, longitude: longitude, id: id)
    }
}

extension DestinationShareRequest {
    func toJsonDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["receiverUserId"] = self.shareWithUserId
        dict["destinationId"] = self.destinationId
        if let n = self.note {
            dict["note"] = n
        }
        return dict
    }
}

extension RichDestination {
    
    static func parseManyRichDestinations(data: Data) -> [RichDestination] {
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        
        if let array = json as? [[String: Any]] {
            return array.map{parseRichDestinationDict(dict: $0)}
        }
        return [RichDestination]()
    }
    
    static func parseRichDestination(data: Data) -> RichDestination? {
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [String: Any] {
            return parseRichDestinationDict(dict: json)
        }
        return nil
    }
    
    static func parseRichDestinationDict(dict: [String: Any]) -> RichDestination {
        let destination = Destination.parseDestinationDict(dict: dict["destination"] as! [String: Any])
        let inboundRecommendations = (dict["inboundRecommendations"] as! [[String: Any]]).map{Recommendation.parseRecommendationDict(dict: $0)}
        let reviews = (dict["reviews"] as! [[String: Any]]).map{Review.parseReviewDict(dict: $0)}
        let ownReview = (dict["ownReview"] as? [String: Any]).map{Review.parseReviewDict(dict: $0)}
        let thanksSent = (dict["thanksSent"] as! [[String: Any]]).map{Thank.parseThankDict(dict: $0)}
        let thanksReceived = (dict["thanksReceived"] as! [[String: Any]]).map{Thank.parseThankDict(dict: $0)}
        return RichDestination(destination: destination, inboundRecommendations: inboundRecommendations, reviews: reviews, ownReview: ownReview, thanksSent: thanksSent, thanksReceived: thanksReceived)
    }
}

extension Review {
    
    static func parseReview(data: Data) -> Review? {
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [String: Any] {
            return parseReviewDict(dict: json)
        }
        return nil
    }
    
    static func parseReviewDict(dict: [String: Any]) -> Review {
        let user = User.parseUserDict(dict: dict["user"] as! [String: Any])
        let destinationId = dict["destinationId"] as! Int
        let rating = dict["rating"] as? Double
        let note = dict["note"] as? String
        return Review(user: user, destinationId: destinationId, rating: rating, note: note)
    }
}

extension Recommendation {
    
    static func parseRecommendation(data: Data) -> Recommendation? {
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [String: Any] {
            return parseRecommendationDict(dict: json)
        }
        return nil
    }
    
    static func parseRecommendationDict(dict: [String: Any]) -> Recommendation {
        let sender = User.parseUserDict(dict: dict["sender"] as! [String: Any])
        let receiver = User.parseUserDict(dict: dict["receiver"] as! [String: Any])
        let destination = Destination.parseDestinationDict(dict: dict["destination"] as! [String: Any])
        let note = dict["note"] as? String
        return Recommendation(sender: sender, receiver: receiver, destination: destination, note: note)
    }
}

extension ReviewRequest {
    
    func toJsonDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["destinationId"] = destinationId
        dict["rating"] = rating
        if note != nil {
            dict["note"] = note
        }
        return dict
    }
    
}

extension Thank {
    
    static func parseManyThanks(data: Data) -> [Thank] {
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        
        if let array = json as? [[String: Any]] {
            return array.map{parseThankDict(dict: $0)}
        }
        return [Thank]()
    }
    
    static func parseThank(data: Data) -> Thank? {
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [String: Any] {
            return parseThankDict(dict: json)
        }
        return nil
    }
    
    static func parseThankDict(dict: [String: Any]) -> Thank {
        let senderUserId = dict["senderUserId"] as! Int
        let receiverUserId = dict["receiverUserId"] as! Int
        let destinationId = dict["destinationId"] as! Int
        return Thank(senderUserId: senderUserId, receiverUserId: receiverUserId, destinationId: destinationId)
    }
}

extension ThankRequest {
    func toJsonDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["receiverUserId"] = receiverUserId
        dict["destinationId"] = destinationId
        return dict
    }
}
