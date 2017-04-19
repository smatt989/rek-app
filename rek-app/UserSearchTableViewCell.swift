//
//  UserSearchTableViewCell.swift
//  rek-app
//
//  Created by Matthew Slotkin on 4/2/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit

class UserSearchTableViewCell: UITableViewCell {
    
    var user: User?
    var added = false
    var toBeShared = false

    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var addConnectionButton: UIButton!
    @IBOutlet weak var shareButton: UIImageView!
    
    private let checked = #imageLiteral(resourceName: "Checkbox full")
    private let unchecked = #imageLiteral(resourceName: "Checkbox empty")
    
    var addShareCallback: ((User) -> Void)?
    var removeShareCallback: ((User) -> Void)?
    
    @IBAction func addConnectionButtonTap(_ sender: UIButton) {
        print("hmm")
        addUserConnection()
    }
    
    func setup() {
        DispatchQueue.main.async{ [weak weakself = self] in
            if weakself?.user != nil {
                weakself?.usernameLabel.text = weakself?.user?.username
            }
            weakself?.shareButton.isHidden = true
            weakself?.addConnectionButton.isHidden = true
            if weakself!.toBeShared {
                weakself?.shareButton.image = weakself?.checked
            } else {
                weakself?.shareButton.image = weakself?.unchecked
            }
            if !weakself!.added {
                weakself?.addConnectionButton.isHidden = false
            } else {
                weakself?.addConnectionButton.isHidden = true
                weakself?.shareButton.isHidden = false
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if added {
            toBeShared = !toBeShared
            if toBeShared {
                addShareCallback?(user!)
            } else {
                removeShareCallback?(user!)
            }
        }
        setup()
    }
    
    private func addUserConnection() {
        let connectionRequest = UserConnectionAddRequest(addUserId: user!.id)
        User.addUser(addUserRequest: connectionRequest, success: { [weak weakself = self] _ in
            weakself?.added = true
            weakself?.setup()
            }, failure: { _ in
                print("failed to add")
        })
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
