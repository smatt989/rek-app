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

extension ReviewRequest {
    
    func toJsonDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["destinationId"] = destinationId
        dict["positiveRating"] = positiveRating
        if note != nil {
            dict["note"] = note
        }
        return dict
    }
    
}
