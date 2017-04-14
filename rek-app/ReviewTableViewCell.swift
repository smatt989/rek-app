//
//  ReviewTableViewCell.swift
//  rek-app
//
//  Created by Matthew Slotkin on 4/3/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit

class ReviewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var reviewTextView: UITextView!
    
    @IBOutlet weak var thanksButton: UIButton!
    @IBOutlet weak var thankedLabel: UILabel!
    
    @IBAction func thanksButtonTap(_ sender: UIButton) {
        thanksButtonTap?()
    }
    
    var thanksButtonTap: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
