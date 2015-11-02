//
//  Page.swift
//  PlotTwist
//
//  Created by Philip Henson on 11/2/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import Foundation
import Parse

class Page: PFObject, PFSubclassing {

    @NSManaged var author: User
    @NSManaged var story: Story
    @NSManaged var content: PFFile
    @NSManaged var pageNum: Int

    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }

    static func parseClassName() -> String {
        return "Page"
    }
}
