//
//  ListOfStoriesTableViewCell.swift
//  PlotTwist
//
//  Created by Rumiya Murtazina on 11/8/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit

class ListOfStoriesTableViewCell: UITableViewCell {

    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var storyTitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
