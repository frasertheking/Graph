//
//  Layer.swift
//  Graph
//
//  Created by Fraser King on 2018-09-11.
//  Copyright © 2018 Fraser King. All rights reserved.
//

import Foundation
import UIKit

class Layer: NSObject {
    var name: String!
    var active: Bool!
    var locked: Bool!
    var colors: [UIColor]!
    var levelPath: String!
    var completePercent: Float!
    var animatedImagePath: String!
    var idleImagePath: String!
    
    init(name: String, active: Bool, locked: Bool, colors: [String], levelPath: String, completePercent: NSNumber, animatedImagePath: String, idleImagePath: String) {
        self.name = name
        self.active = active
        self.locked = locked
        
        var colorList: [UIColor] = []
        for color in colors {
            colorList.append(UIColor.hexStringToUIColor(hex: color))
        }
        self.colors = colorList
        
        self.levelPath = levelPath
        self.completePercent = Float(truncating: completePercent)
        self.animatedImagePath = animatedImagePath
        self.idleImagePath = idleImagePath
    }
}
