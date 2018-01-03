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
    var hamiltonian: Bool?
    var planar: Bool?
    var adjacencyList: AdjacencyList<Node>?
    
    init(name: String?, numberOfColorsProvided: Int?, hamiltonian: Bool?, planar: Bool?, adjacencyList: AdjacencyList<Node>?) {
        self.name = name
        self.numberOfColorsProvided = numberOfColorsProvided
        self.hamiltonian = hamiltonian
        self.planar = planar
        self.adjacencyList = adjacencyList
    }
}
