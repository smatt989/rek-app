//
//  DestinationTableSection.swift
//  rek-app
//
//  Created by Matthew Slotkin on 4/18/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import Foundation

struct DestinationTableSection {
    var name: String
    var section: Int
    var headlineForMissingItems: String
    var informationForMissingItems: String
    var actionTextForMissingItems: String?
    var actionForMissingItems: (() -> Void)?
    var itemsArray: () -> [RichDestination]
}
