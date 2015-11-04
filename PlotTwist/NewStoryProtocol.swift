//
//  NewStoryProtocol.swift
//  PlotTwist
//
//  Created by Philip Henson on 11/3/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import Foundation

protocol NewStoryDelegate {
    func didAddNewStory(newStory: Story, nextAuthor: User)
}