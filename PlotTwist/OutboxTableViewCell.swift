//
//  OutboxTableViewCell.swift
//  PlotTwist
//
//  Created by Philip Henson on 11/9/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit

class OutboxTableViewCell: UITableViewCell {

    @IBOutlet weak var storyTitleLabel: UILabel!
    @IBOutlet weak var dateCreatedLabel: UILabel!
    @IBOutlet weak var invitedAuthorLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
