//
//  Graphable.swift
//  Graph
//
//  Created by Fraser King on 2017-11-11.
//  Copyright © 2017 Fraser King. All rights reserved.
//

import Foundation
import SceneKit

protocol Graphable {
    associatedtype Element: Hashable
    var description: CustomStringConvertible { get }
    
    func createVertex(data: Element) -> Vertex<Element>
    func add(_ type: EdgeType, from source: Vertex<Element>, to destination: Vertex<Element>)
    func edges(from source: Vertex<Element>) -> [Edge<Element>]?
    
    // Helper functions
    func checkIfSolved(forType type: GraphType) -> Bool
    func isLastStep() -> Bool 
    func updateGraphState(id: String?, color: UIColor) -> AdjacencyList<Node>
    func getNeighbours(for id: String?) -> [String]
    func updateNodePosition(id: String?, newPosition: SCNVector3)
}
