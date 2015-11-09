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
        static let allAuthorIds = "allAuthorIds"
        static let pages = "pages"
        static let isLiked = "isLiked"
        static let isPublished = "isPublished"
        static let voteCount = "voteCount"
        static let viewCount = "viewCount"
        static let pageCount = "pageCount"
        static let objectId = "objectId"
    }

    struct Page {
        static let author = "author"
        static let story = "story"
        static let content = "content"
        static let textContent = "textContent"
        static let pageNumber = "pageNum"
    }

    struct Activity {
        static let fromUser = "fromUser"
        static let toUser = "toUser"
        static let toStory = "toStory"
        static let type = "type"
        static let requestType = "requestType"
        struct Requests {
            static let incoming = "incoming"
            static let outgoing = "outgoing"
            static let confirmed = "confirmed"
            
        }

        struct Type {
            static let vote = "vote"
            static let friend = "friend"
            static let comment = "comment"
        }
    }

    struct User {
        static let objectId = "objectId"
        static let fullName = "fullName"
        static let profilePicture = "profilePicture"
        static let friends = "friends"
        static let viewedStories = "viewedStories"
        static let votedStories = "votedStories"
        static let authoredStories = "authoredStories"
        static let coAuthoredStories = "coAuthoredStories"
        static let invitedStories = "invitedStories"
        static let buttonKey = "buttonKey"

        struct ButtonType {
            static let accepted = "AcceptedButton"
            static let pending = "PendingButton"
            static let sendRequest = "SendRequestButton"
            static let incoming = "IncomingButton"
        }
    }
}