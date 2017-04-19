//
//  DestinationTableViewCell.swift
//  rek-app
//
//  Created by Matthew Slotkin on 4/3/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit
import CoreLocation

class DestinationTableViewCell: UITableViewCell {
    
    var destination: RichDestination?
    var currentLocation: CLLocationCoordinate2D? 
    
    private var reviewed: Bool {
        get {
            return destination!.reviewCount > 0
        }
    }
    private var suggested: Bool {
        get {
            return destination!.inboundRecommendations.count > 0
        }
    }

    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var sharedByLabel: UILabel!
    @IBOutlet weak var reviewRating: RatingView!
    @IBOutlet weak var reviewCountLabel: UILabel!
    @IBOutlet weak var reviewView: UIView!
    @IBOutlet weak var distanceAwayLabel: UILabel!
    
    
    func setup() {
        if destination != nil {
            DispatchQueue.main.async{ [weak weakself = self] in
                weakself?.nameLabel.text = weakself?.destination!.destination.name
                weakself?.addressLabel.text = weakself?.destination!.destination.address
                weakself?.setupReviewView()
                if weakself!.currentLocation != nil {
                    weakself?.distanceAwayLabel.text = DestinationUtilities.distanceToString(distance: weakself!.destination!.distanceAway(currentLocation: weakself!.currentLocation!))
                    weakself?.distanceAwayLabel.isHidden = false
                } else {
                    weakself?.distanceAwayLabel.isHidden = true
                }
                weakself?.setupSharedByLabel()
            }
        }
    }
    
    private func setupSharedByLabel() {
        DispatchQueue.main.async { [weak weakself = self] in
            if weakself!.destination!.inboundRecommendations.count > 0 {
                weakself?.sharedByLabel.isHidden = false
                weakself?.sharedByLabel.text = weakself?.recommendationsToString(recommendations: weakself!.destination!.inboundRecommendations)
            } else {
                weakself?.sharedByLabel.isHidden = true
            }
        }
    }
    
    private func recommendationsToString(recommendations: [Recommendation]) -> String {
        var str = "Shared by "+recommendations.first!.sender.username
        var other = "other"
        if recommendations.count > 2 {
            other = "others"
        }
        if recommendations.count > 1 {
            str = str + " and \(recommendations.count - 1) \(other)"
        }
        return str
    }
    
    private func setupReviewView() {
        DispatchQueue.main.async { [weak weakself = self] in
            if weakself!.reviewed {
                weakself?.reviewView.isHidden = false
                weakself?.reviewRating.rating = weakself!.destination!.reviewRating
                weakself?.reviewRating.interactable = false
                weakself?.reviewCountLabel.text = "\(weakself!.destination!.reviewCount) reviews"
            } else {
                weakself?.reviewView.isHidden = true
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
