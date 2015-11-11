//
//  InboxTableViewCell.swift
//  PlotTwist
//
//  Created by Rumiya Murtazina on 11/10/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit

class InboxTableViewCell: UITableViewCell {

    @IBOutlet weak var authorImage: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var previousContent: UILabel!
    @IBOutlet weak var dateCreatedLabel: UILabel!

   var timeString: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
