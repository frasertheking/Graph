//
//  Node.swift
//  Graph
//
//  Created by Fraser King on 2017-11-18.
//  Copyright © 2017 Fraser King. All rights reserved.
//

import Foundation
import SceneKit

class Node: Hashable {
    
    var position: SCNVector3
    var uid: Int
    var color: UIColor
    
    public var hashValue: Int {
        return uid
    }
    
    static func ==(lhs: Node, rhs: Node) -> Bool {
        return lhs.uid == rhs.uid
    }
    
    public init(position: SCNVector3, uid: Int, color: UIColor) {
        self.position = position
        self.uid = uid
        self.color = color
    }
}

