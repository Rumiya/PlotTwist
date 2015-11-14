//
//  OutgoingFriendTableViewCell.swift
//  PlotTwist
//
//  Created by Philip Henson on 11/14/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit

class OutgoingFriendTableViewCell: UITableViewCell {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var friendButton: UIButton!

    var delegate: OutgoingFriendButtonDelegate?

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
