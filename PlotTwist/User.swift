//
//  User.swift
//  PlotTwist
//
//  Created by Philip Henson on 11/2/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import Foundation
import Parse


class User: PFUser {

    @NSManaged var fullName: String
    @NSManaged var profilePicture: PFFile
    @NSManaged var friends: PFRelation
    @NSManaged var viewedStories: PFRelation
    @NSManaged var votedStories: PFRelation
    @NSManaged var authoredStories: PFRelation
    @NSManaged var coAuthoredStories: PFRelation
    @NSManaged var invitedStories: PFRelation
    @NSManaged var buttonKey: String
    @NSManaged var reportedStories: Array<String>

    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }

}
