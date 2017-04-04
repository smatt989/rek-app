//
//  HttpRequests.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/12/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

extension User {
    
    struct Urls {
        static let createUser = domain+"/users/create"
        static let login = domain+"/sessions/new"
        static let logout = domain+"/sessions/logout"
        static let deviceToken = domain+"/users/tokens"
        static let usersSearch = domain+"/users/search"
        static let addedUsers = domain+"/users/connections/added"
        static let addUserConnection = domain+"/users/connections/create"
    }
    
    struct Headers {
        static let sessionHeader = "Rekki-Session-Key"
        static let usernameHeader = "username"
        static let passwordHeader = "password"
    }
    
    static func search(query: String, success: @escaping ([User]) -> Void, failure: @escaping (Error) -> Void) {
        let cleanQuery = query.replacingOccurrences(of: " ", with: "_")
        var request = URLRequest(url: URL(string: Urls.usersSearch+"?query="+cleanQuery)!)
        request.httpMethod = "POST"
        let session = URLSession.shared
        session.dataTask(with: request) {data, response, err in
            if let d = data {
                let users = User.parseMany(data: d)
                success(users)
            } else if err != nil {
                failure(err!)
            } else {
                print("WHOOPS")
            }
            }.resume()
    }
    
    static func signUp(newUser: UserCreate, success: @escaping (User) -> Void, failure: @escaping (Error) -> Void) {
        var request = URLRequest(url: URL(string: Urls.createUser)!)
        request.httpMethod = "POST"
        request.addValue("application/json",forHTTPHeaderField: "Content-Type")
        request.addValue("application/json",forHTTPHeaderField: "Accept")
        request.httpBody = try! JSONSerialization.data(withJSONObject: newUser.toJsonDictionary(), options: [])
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, err in
            if let d = data, let user = self.parseUser(data: d) {
                //need to get header and save session key (or maybe not here)
                DispatchQueue.main.async {
                    success(user)
                }
            } else if err != nil {
                DispatchQueue.main.async {
                    failure(err!)
                }
            }
        }.resume()
    }
    
    static func saveDeviceToken(_ token: String, success: @escaping (Void) -> Void, failure: @escaping (Error) -> Void){
        var request = URLRequest(url: URL(string: Urls.deviceToken+"?device_token="+token)!)
        request.httpMethod = "POST"
        request.authenticate()
        request.addValue("application/json",forHTTPHeaderField: "Content-Type")
        request.addValue("application/json",forHTTPHeaderField: "Accept")
        let session = URLSession.shared
        session.dataTask(with: request) {data, response, err in
            if data != nil {
                DispatchQueue.main.async {
                    success()
                }
            } else if err != nil {
                DispatchQueue.main.async {
                    failure(err!)
                }
            }
        }.resume()
    }
    
    static func checkSession(managedObjectContext: NSManagedObjectContext, success: @escaping (User) -> Void, failure: @escaping (Error) -> Void) {
        var request = URLRequest(url: URL(string: Urls.login)!)
        request.httpMethod = "GET"
        request.authenticate()
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, err in
            if let key = (response as? HTTPURLResponse)?.allHeaderFields[Headers.sessionHeader] as? String, let userData = data {
                _ = Session.setSessionKey(key: key, managedObjectContext: managedObjectContext)
                DispatchQueue.main.async {
                    success(User.parseUser(data: userData)!)
                }
            } else if err != nil{
                Session.removeSessionKey(managedObjectContext: managedObjectContext)
                DispatchQueue.main.async {
                    failure(err!)
                }
            } else {
                print("SOMETHING STRANGE")
                let error = NSError()
                DispatchQueue.main.async {
                    failure(error)
                }
            }
        }.resume()
    }
    
    static func login(username: String, password: String, managedObjectContext: NSManagedObjectContext, success: @escaping (User) -> Void, failure: @escaping (Error) -> Void){
        var request = URLRequest(url: URL(string: Urls.login)!)
        request.httpMethod = "GET"
        request.addValue(username, forHTTPHeaderField: Headers.usernameHeader)
        request.addValue(password, forHTTPHeaderField: Headers.passwordHeader)
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, err in
            if let key = (response as? HTTPURLResponse)?.allHeaderFields[Headers.sessionHeader] as? String
, let userData = data {
                _ = Session.setSessionKey(key: key, managedObjectContext: managedObjectContext)
                DispatchQueue.main.async {
                    success(User.parseUser(data: userData)!)
                }
            } else if err != nil{
                print("UNO PROBLEMO")
                DispatchQueue.main.async {
                    failure(err!)
                }
            } else {
                print("SOMETHING ELSE...")
            }
        }.resume()
    }
    
    static func logout(callback: @escaping () -> Void){
        var request = URLRequest(url: URL(string: Urls.logout)!)
        request.httpMethod = "POST"
        request.authenticate()
        let session = URLSession.shared
        session.dataTask(with: request) {data, response, err in
            DispatchQueue.main.async{
                callback()
            }
        }.resume()
    }
    
    static func addedUsers(success: @escaping ([User]) -> Void, failure: @escaping (Error) -> Void) {
        var request = URLRequest(url: URL(string: Urls.addedUsers)!)
        request.httpMethod = "GET"
        request.authenticate()
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, err in
            if let d = data {
                let users = User.parseMany(data: d)
                success(users)
            } else if err != nil {
                failure(err!)
            } else {
                print("BRARRR")
            }
            }.resume()
    }
    
    static func addUser(addUserRequest: UserConnectionAddRequest, success: @escaping () -> Void, failure: @escaping (Error) -> Void) {
        var request = URLRequest(url: URL(string: Urls.addUserConnection)!)
        request.httpMethod = "POST"
        request.authenticate()
        request.jsonRequest()
        request.httpBody = try! JSONSerialization.data(withJSONObject: addUserRequest.toJsonDictionary(), options: [])
        let session = URLSession.shared
        session.dataTask(with: request) {data, response, err in
            if data != nil {
                success()
            } else if err != nil {
                failure(err!)
            } else {
                print("MOOSH")
            }
            }.resume()
    }

}

extension Destination {
    
    struct Urls {
        static let loadSavedDestination = domain + "/destinations/retrieve"
    }
    
    static func loadSavedDestination(_ destination: Destination, success: @escaping(RichDestination) -> Void, failure: @escaping (Error) -> Void) {
        var request = URLRequest(url: URL(string: Urls.loadSavedDestination)!)
        request.httpMethod = "POST"
        request.authenticate()
        request.jsonRequest()
        request.httpBody = try! JSONSerialization.data(withJSONObject: destination.toJsonDictionary(), options: [])
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, err in
            if data != nil {
                success(RichDestination.parseRichDestination(data: data!)!)
            } else if err != nil {
                failure(err!)
            } else {
                print("bad")
            }
            }.resume()
    }
}

extension RichDestination {
    
    struct Urls {
        static let loadPersonalizedDestinations = domain + "/destinations/personalized"
    }
    
    static func fetchDestinations(location: CLLocationCoordinate2D, callback: @escaping ([RichDestination]) -> Void) {
        var request = URLRequest(url: URL(string: Urls.loadPersonalizedDestinations)!)
        request.httpMethod = "GET"
        request.authenticate()
        request.jsonRequest()
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, err in
            if let d = data {
                let dests = self.parseManyRichDestinations(data: d)
                callback(dests)
            } else if err != nil {
                print("BIG PROBLEMO")
            }
            }.resume()
    }
}

extension DestinationShareRequest {
    
    struct Urls {
        static let shareDestinations = domain+"/destinations/share"
    }
    
    static func shareMany(_ shareRequests: [DestinationShareRequest], success: @escaping() -> Void, failure: @escaping (Error) -> Void) {
        var request = URLRequest(url: URL(string: Urls.shareDestinations)!)
        request.httpMethod = "POST"
        request.authenticate()
        request.jsonRequest()
        request.httpBody = try! JSONSerialization.data(withJSONObject: shareRequests.map{$0.toJsonDictionary()}, options: [])
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, err in
            if data != nil {
                success()
            } else if err != nil {
                failure(err!)
            } else {
                print("bad")
            }
            }.resume()
    }
}

extension ReviewRequest {
    
    struct Urls {
        static let createReview = domain + "/destinations/review/save"
    }
    
    static func postReviewRequest(_ reviewRequest: ReviewRequest, success: @escaping() -> Void, failure: @escaping (Error) -> Void) {
        var request = URLRequest(url: URL(string: Urls.createReview)!)
        request.httpMethod = "POST"
        request.authenticate()
        request.jsonRequest()
        request.httpBody = try! JSONSerialization.data(withJSONObject: reviewRequest.toJsonDictionary(), options: [])
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, err in
            if data != nil {
                success()
            } else if err != nil {
                failure(err!)
            } else {
                print("oh deeeear")
            }
            }.resume()
    }
}

extension URLRequest {
    mutating func jsonRequest() {
        self.addValue("application/json",forHTTPHeaderField: "Content-Type")
        self.addValue("application/json",forHTTPHeaderField: "Accept")
    }
}

