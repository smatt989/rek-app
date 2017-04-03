//
//  Review.swift
//  rek-app
//
//  Created by Matthew Slotkin on 4/1/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import Foundation

struct ReviewRequest {
    var destinationId: Int
    var positiveRating: Bool
    var note: String?
}
