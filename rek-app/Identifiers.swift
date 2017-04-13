//
//  Identifiers.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/10/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import Foundation

struct Identifiers {
    
    struct Cells {
        static let searchCell = "cell"
        static let destinationCell = "Destination Cell"
        static let userSearchCell = "user search cell"
        static let reviewCell = "Review Cell"
        static let destinationSectionCell = "destination section header cell"
        static let followUnfollowTableCell = "follow unfollow cell"
    }
    
    struct StoryBoards {
        static let mainStoryboard = "Main"
        static let loginStoryboard = "Login"
    }
    
    struct Segues {
        static let destinationDetail = "Destination Detail"
        static let suggestDestination = "Suggest Screen Segue"
        static let mapview = "mapview segue"
        static let mapToDetail = "Map Annotation To Detail"
        static let reviewPopover = "review popover segue"
        static let positiveReviewPopover="like review segue"
        static let profile = "profile segue"
        static let detailsToMap = "details to map segue"
    }
    
    struct ViewControllers {
        static let locationSearchTable = "LocationSearchTable"
    }
}

//let domain = "http://localhost:8080"
let domain = "http://rekkiapp-env.us-east-1.elasticbeanstalk.com"
    
