//
//  DestinationShareRequest.swift
//  rek-app
//
//  Created by Matthew Slotkin on 4/3/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import Foundation

struct DestinationShareRequest {
    let destinationId: Int
    let shareWithUserId: Int
    let note: String?
}
