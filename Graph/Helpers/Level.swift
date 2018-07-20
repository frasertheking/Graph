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
    var numberOfColorsProvided: Int?
    var graphType: GraphType?
    var timed: Bool?
    var isMirror: Bool?
    var targetColor: UIColor?
    var adjacencyList: AdjacencyList<Node>?
    
    init(name: String?, numberOfColorsProvided: Int?, graphType: GraphType?, timed: Bool?, isMirror: Bool?, targetColor: UIColor?, adjacencyList: AdjacencyList<Node>?) {
        self.name = name
        self.numberOfColorsProvided = numberOfColorsProvided
        self.graphType = graphType
        self.timed = timed
        self.isMirror = isMirror
        self.targetColor = targetColor
        self.adjacencyList = adjacencyList
    }
}
