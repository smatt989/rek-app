//
//  Thank.swift
//  rek-app
//
//  Created by Matthew Slotkin on 4/13/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import Foundation

struct Thank {
    var senderUserId: Int
    var receiverUserId: Int
    var destinationId: Int
}

struct ThankRequest {
    var receiverUserId: Int
    var destinationId: Int
}
