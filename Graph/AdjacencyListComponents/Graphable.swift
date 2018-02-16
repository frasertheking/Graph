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
    
    // Helpers
    func checkIfSolved(forType type: GraphType, edgeArray: [Edge<Node>], edgeNodes: SCNNode) -> Bool
    func isLastStep() -> Bool 
    func updateGraphState(id: String?, color: UIColor) -> AdjacencyList<Node>
    func updateCorrectEdges(level: Level?, pathArray: [Int], edgeArray: [Edge<Node>], edgeNodes: SCNNode)
    func getNeighbours(for id: String?) -> [String]
    func updateNeighbourColors(level: Level?, neighbours: [String], vertexNodes: SCNNode)
    func updateNodePosition(id: String?, newPosition: SCNVector3)
    func doEdgesIntersect(edge1: Edge<Node>, edge2: Edge<Node>) -> Bool
    func makeSimMove(edgeArray: [Edge<Node>], edgeNodes: SCNNode, simArray: [Int])
    func isLegalMove(simArray: [Int], uid1: Int, uid2: Int) -> Bool
}
