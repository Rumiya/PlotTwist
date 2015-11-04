//
//  NewPageDelegate.swift
//  PlotTwist
//
//  Created by Philip Henson on 11/3/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import Foundation

protocol NewPageDelegate {
    func didAddNewPage(editedStory: Story, nextAuthor: User)
    func didEndStory(endedStory: Story)
    func didCancelNewPage()
}
