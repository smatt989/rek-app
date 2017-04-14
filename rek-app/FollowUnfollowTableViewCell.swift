//
//  FollowUnfollowTableViewCell.swift
//  rek-app
//
//  Created by Matthew Slotkin on 4/12/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit

class FollowUnfollowTableViewCell: UITableViewCell {

    var user: User?
    
    var following = true {
        didSet {
            DispatchQueue.main.async { [weak weakself = self] in
                weakself?.usernameLabel.text = weakself?.user?.username
                if weakself!.following {
                    weakself?.followButton.isHidden = true
                    weakself?.unfollowButton.isHidden = false
                } else {
                    weakself?.followButton.isHidden = false
                    weakself?.unfollowButton.isHidden = true
                }
            }
        }
    }
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var unfollowButton: UIButton!
    
    @IBAction func tapFollowButton(_ sender: UIButton) {
        addUserConnection()
    }
    
    @IBAction func tapUnfollowButton(_ sender: UIButton) {
        removeUserConnection()
    }
    
    private func addUserConnection() {
        let connectionRequest = UserConnectionAddRequest(addUserId: user!.id)
        User.addUser(addUserRequest: connectionRequest, success: { [weak weakself = self] _ in
            weakself?.following = true
            }, failure: { _ in
                print("failed to add")
        })
    }
    
    private func removeUserConnection() {
        User.removeUser(userId: user!.id, success: { [weak weakself = self] in
            weakself?.following = false
            }, failure: { _ in
                print("failed to remove")
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
