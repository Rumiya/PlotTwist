//
//  FriendTableViewCell.swift
//  PlotTwist
//
//  Created by Philip Henson on 11/8/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit

class FriendTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!

    @IBOutlet weak var friendButton: UIButton!

    var delegate: FriendButtonDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func onFriendButtonPressed(sender: UIButton) {
        delegate?.didPressFriendButton(sender)
    }


}
