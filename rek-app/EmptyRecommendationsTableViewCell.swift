//
//  EmptyRecommendationsTableViewCell.swift
//  rek-app
//
//  Created by Matthew Slotkin on 4/18/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit

class EmptyRecommendationsTableViewCell: UITableViewCell {

    
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var actionLabel: UILabel!
    
    
    func setup(headline: String, information: String, action: String?) {
        DispatchQueue.main.async { [weak weakself = self] in
            weakself?.headlineLabel.text = headline
            weakself?.informationLabel.text = information
            weakself?.actionLabel.text = action
            weakself?.actionLabel.isHidden = weakself?.action == nil
            weakself?.isUserInteractionEnabled = weakself?.action != nil
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
