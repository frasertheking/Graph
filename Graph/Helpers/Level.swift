//
//  Level.swift
//  Graph
//
//  Created by Fraser King on 2017-11-12.
//  Copyright © 2017 Fraser King. All rights reserved.
//

import Foundation
import SceneKit

class Level: NSObject {
    var name: String?
    var adjacencyList: AdjacencyList<Node>?
    
    init(name: String?, adjacencyList: AdjacencyList<Node>?) {
        self.name = name
        self.adjacencyList = adjacencyList
    }
    
}
