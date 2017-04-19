//
//  TableViewUtilities.swift
//  rek-app
//
//  Created by Matthew Slotkin on 4/18/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import Foundation

import UIKit

extension UITableView {
    
    func showBackground(headline: String, informationText1: String, informationText2: String?, instructionsText: String?) {
        
        let newBackgroundView = EmptyTableView(frame: frame)
        newBackgroundView.setupText(headline: headline, informationText1: informationText1, informationText2: informationText2, instructionsText: instructionsText)
        backgroundView = newBackgroundView
        separatorStyle = .none
    }

    func showTable() {
        backgroundView = nil
        separatorStyle = .singleLine
    }
}

