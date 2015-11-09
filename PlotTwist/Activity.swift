//
//  Activity.swift
//  PlotTwist
//
//  Created by Philip Henson on 11/2/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import Foundation
import Parse

class Activity: PFObject, PFSubclassing {

    @NSManaged var fromUser: User
    @NSManaged var toUser: User
    @NSManaged var toStory: Story
    @NSManaged var type: String
    @NSManaged var requestType: String

    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }

    static func parseClassName() -> String {
        return "Activity"
    }
}
