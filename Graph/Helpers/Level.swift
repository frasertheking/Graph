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
    var adjacencyList: AdjacencyList<Node>?
    
    init(name: String?, numberOfColorsProvided: Int?, graphType: GraphType?, adjacencyList: AdjacencyList<Node>?) {
        self.name = name
        self.numberOfColorsProvided = numberOfColorsProvided
        self.graphType = graphType
        self.adjacencyList = adjacencyList
    }
}
