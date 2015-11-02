//
//  PTConstants.swift
//  PlotTwist
//
//  Created by Philip Henson on 11/2/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import Foundation

struct Constants {

    struct Story {
        static let title = "storyTitle"
        static let mainAuthor = "mainAuthor"
        static let allAuthors = "allAuthors"
        static let currentAuthor = "currentAuthor"
        static let pages = "pages"
        static let isLiked = "isLiked"
        static let isPublished = "isPublished"
        static let voteCount = "voteCount"
        static let viewCount = "viewCount"
        static let pageCount = "pageCount"
    }

    struct Page {
        static let author = "author"
        static let story = "story"
        static let content = "content"
        static let pageNumber = "pageNum"
    }

    struct Activity {
        static let fromUser = "fromUser"
        static let toUser = "toUser"
        static let toStory = "toStory"

        struct Type {
            static let vote = "vote"
            static let follow = "follow"
            static let comment = "comment"
        }
    }

    struct User {
        static let fullName = "fullName"
        static let profilePicture = "profilePicture"
        static let friends = "friends"
        static let viewedStories = "viewedStories"
        static let votedStories = "votedStories"
        static let authoredStories = "authoredStories"
        static let coAuthoredStories = "coAuthoredStories"
        static let invitedStories = "invitedStories"
    }
}