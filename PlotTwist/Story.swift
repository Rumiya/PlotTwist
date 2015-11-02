//
//  Story.swift
//  PlotTwist
//
//  Created by Philip Henson on 11/2/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import Foundation
import Parse

class Story: PFObject, PFSubclassing {

    @NSManaged var storyTitle: String
    @NSManaged var mainAuthor: User
    @NSManaged var allAuthors: PFRelation
    @NSManaged var currentAuthor: User
    @NSManaged var pages: Array<Page>
    @NSManaged var isLiked: Bool
    @NSManaged var isPublished: Bool
    @NSManaged var voteCount: String
    @NSManaged var viewCount: String
    @NSManaged var pageCount: String

    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }

    static func parseClassName() -> String {
        return "Story"
    }
}