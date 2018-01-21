//
//  AdjacencyList.swift
//  Graph
//
//  Created by Fraser King on 2017-11-11.
//  Copyright © 2017 Fraser King. All rights reserved.
//

import Foundation
import SceneKit

public enum GraphType: Int {
    case kColor = 0
    case hamiltonian
    case planar
    case euler
}

open class AdjacencyList<T: Hashable> {
    public var adjacencyDict : [Vertex<T>: [Edge<T>]] = [:]
    public init() {}
}

extension AdjacencyList: Graphable {
    public typealias Element = T
    
    public var description: CustomStringConvertible {
        var result = ""
        for (vertex, edges) in adjacencyDict {
            var edgeString = ""
            for (index, edge) in edges.enumerated() {
                if index != edges.count - 1 {
                    edgeString.append("\(edge.destination), ")
                } else {
                    edgeString.append("\(edge.destination)")
                }
            }
            result.append("\(vertex) ---> [ \(edgeString) ] \n ")
        }
        return result
    }
    
    public func createVertex(data: Element) -> Vertex<Element> {
        let vertex = Vertex(data: data)
        
        if adjacencyDict[vertex] == nil {
            adjacencyDict[vertex] = []
        }
        
        return vertex
    }
    
    public func add(_ type: EdgeType, from source: Vertex<Element>, to destination: Vertex<Element>) {
        switch type {
        case .directed:
            addDirectedEdge(from: source, to: destination)
        case .undirected:
            addUndirectedEdge(vertices: (source, destination))
        }
    }
    
    fileprivate func addDirectedEdge(from source: Vertex<Element>, to destination: Vertex<Element>) {
        let edge = Edge(source: source, destination: destination)
        adjacencyDict[source]?.append(edge) 
    }
    
    fileprivate func addUndirectedEdge(vertices: (Vertex<Element>, Vertex<Element>)) {
        let (source, destination) = vertices
        addDirectedEdge(from: source, to: destination)
        addDirectedEdge(from: destination, to: source)
    }
    
    public func edges(from source: Vertex<Element>) -> [Edge<Element>]? {
        return adjacencyDict[source]
    }
    
    func checkIfSolved(forType type: GraphType) -> Bool {
        let graph: AdjacencyList<Node> = self as! AdjacencyList<Node>
        
        switch type {
        case .hamiltonian:
            for (key, _) in (graph.adjacencyDict) {
                if key.data.color != UIColor.goldColor() {
                    return false
                }
            }
        case .planar:
            var edgeArray: [Edge<Node>] = []
            for (_, value) in (graph.adjacencyDict) {
                for edge in value {
                    let temp_edge = Edge(source: edge.destination, destination: edge.source)
                    if !edgeArray.contains(temp_edge) {
                        edgeArray.append(edge)
                    }
                }
            }
            
            var solved: Bool = true
            for edge1 in edgeArray {
                for edge2 in edgeArray {
                    if edge1 != edge2 && doEdgesIntersect(edge1: edge1, edge2: edge2) {
                        solved = false
                    }
                }
            }
            return solved
        case .euler:
            return false
        default:
            for (_, value) in (graph.adjacencyDict) {
                for edge in value {
                    if edge.source.data.color == edge.destination.data.color ||
                        edge.source.data.color == .white ||
                        edge.destination.data.color == .white {
                        return false
                    }
                }
            }
        }
        
        return true
    }
    
    func isLastStep() -> Bool {
        let graph: AdjacencyList<Node> = self as! AdjacencyList<Node>
        
        var count = 0
        for (key, _) in (graph.adjacencyDict) {
            if key.data.color == UIColor.goldColor() {
                count += 1
            }
        }

        return (count == graph.adjacencyDict.count) ? true : false
    }
    
    func getlowestColor(for node_color: UIColor) -> UIColor {        
        var count = 0
        for color in kColors {
            count += 1
            
            if node_color == color {
                return kColors[count]
            }
        }
        
        return kColors[0]
    }
    
    func updateGraphState(id: String?, color: UIColor) -> AdjacencyList<Node> {
        let graph: AdjacencyList<Node> = self as! AdjacencyList<Node>
        for (key, _) in (graph.adjacencyDict) {
            if "\(key.data.uid)" == id {
                key.data.color = color
            }
        }
        return graph
    }
    
    func updateNodePosition(id: String?, newPosition: SCNVector3) {
        let graph: AdjacencyList<Node> = self as! AdjacencyList<Node>
        for (key, _) in (graph.adjacencyDict) {
            if "\(key.data.uid)" == id {
                key.data.position = newPosition
            }
        }
    }
    
    func getNeighbours(for id: String?) -> [String] {
        let graph: AdjacencyList<Node> = self as! AdjacencyList<Node>
        var neighbours: [String] = []
        
        for (key, value) in (graph.adjacencyDict) {
            if "\(key.data.uid)" == id {
                for edge in value {
                    neighbours.append("\(edge.destination.data.uid)")
                }
            }
        }
        return neighbours
    }
    
    func updateNeighbourColors(level: Level?, neighbours: [String], vertexNodes: SCNNode) {
        guard let currentLevel = level else {
            return
        }
        
        guard let graphType = currentLevel.graphType else {
            return
        }
        
        let graph: AdjacencyList<Node> = self as! AdjacencyList<Node>

        if graphType == .planar {
            var pos = 0
            for (key, _) in (graph.adjacencyDict) {
                if neighbours.contains("\(key.data.uid)") {
                    vertexNodes.childNodes[pos].geometry?.firstMaterial?.diffuse.contents = UIColor.goldColor()
                } else if vertexNodes.childNodes[pos].geometry?.firstMaterial?.diffuse.contents as! UIColor != UIColor.red {
                    vertexNodes.childNodes[pos].geometry?.firstMaterial?.diffuse.contents = UIColor.black
                }
                pos += 1
            }
        }
    }
    
    func updateCorrectEdges(level: Level?, pathArray: [Int], edgeArray: [Edge<Node>], edgeNodes: SCNNode) {
        
        guard let currentLevel = level else {
            return
        }
        
        guard let graphType = currentLevel.graphType else {
            return
        }
        
        if graphType == .hamiltonian {
            if pathArray.count > 1 {
                for i in 0...pathArray.count-2 {
                    var pos = 0
                    for edgeNode in edgeArray {
                        if (edgeNode.source.data.uid == pathArray[i] && edgeNode.destination.data.uid == pathArray[i+1]) ||
                            (edgeNode.destination.data.uid == pathArray[i] && edgeNode.source.data.uid == pathArray[i+1]) {
                            edgeNodes.childNodes[pos].geometry?.firstMaterial?.diffuse.contents = UIColor.white
                            edgeNodes.childNodes[pos].geometry?.firstMaterial?.emission.contents = UIColor.glowColor()
                            
                            guard let edgeGeometry = edgeNodes.childNodes[pos].geometry else {
                                continue
                            }
                            
                            if let smokeEmitter = ParticleGeneration.createSmoke(color: UIColor.glowColor(), geometry: edgeGeometry) {
                                edgeNodes.childNodes[pos].addParticleSystem(smokeEmitter)
                            }
                        } else if !isPartOfPath(path: pathArray, start: edgeNode.source.data.uid, end: edgeNode.destination.data.uid) {
                            edgeNodes.childNodes[pos].geometry?.firstMaterial?.diffuse.contents = UIColor.defaultVertexColor()
                            edgeNodes.childNodes[pos].geometry?.firstMaterial?.emission.contents = UIColor.defaultVertexColor()
                            edgeNodes.childNodes[pos].removeAllParticleSystems()
                        }
                        pos += 1
                    }
                }
            }
        } else if graphType == .planar {
            var intersectingEdges: [Edge<Node>] = []
            for edge1 in edgeArray {
                for edge2 in edgeArray {
                    if edge1 != edge2 && doEdgesIntersect(edge1: edge1, edge2: edge2) {
                        intersectingEdges.append(edge1)
                        intersectingEdges.append(edge2)
                    }
                }
            }
            
            var pos = 0
            for edgeNode in edgeArray {
                if intersectingEdges.contains(edgeNode) {
                    edgeNodes.childNodes[pos].geometry?.firstMaterial?.diffuse.contents = UIColor.black
                } else {
                    edgeNodes.childNodes[pos].geometry?.firstMaterial?.diffuse.contents = UIColor.white
                    edgeNodes.childNodes[pos].geometry?.firstMaterial?.emission.contents = UIColor.glowColor()
                }
                pos += 1
            }
        } else {
            for (_, value) in (self.adjacencyDict) {
                for case let edge as Edge<Node> in value  {
                    if edge.source.data.color != edge.destination.data.color &&
                        edge.source.data.color != .white &&
                        edge.destination.data.color != .white {
                        
                        var pos = 0
                        for edgeNode in edgeArray {
                            if edgeNode.source == edge.source && edgeNode.destination == edge.destination {
                                edgeNodes.childNodes[pos].geometry?.firstMaterial?.diffuse.contents = UIColor.white
                                edgeNodes.childNodes[pos].geometry?.firstMaterial?.emission.contents = UIColor.glowColor()
                                
                                guard let edgeGeometry = edgeNodes.childNodes[pos].geometry else {
                                    continue
                                }
                                
                                if let smokeEmitter = ParticleGeneration.createSmoke(color: UIColor.glowColor(), geometry: edgeGeometry) {
                                    edgeNodes.childNodes[pos].addParticleSystem(smokeEmitter)
                                }
                            }
                            pos += 1
                        }
                    } else {
                        var pos = 0
                        for edgeNode in edgeArray {
                            if edgeNode.source == edge.source && edgeNode.destination == edge.destination {
                                edgeNodes.childNodes[pos].geometry?.firstMaterial?.diffuse.contents = UIColor.defaultVertexColor()
                                edgeNodes.childNodes[pos].geometry?.firstMaterial?.emission.contents = UIColor.defaultVertexColor()
                                edgeNodes.childNodes[pos].removeAllParticleSystems()
                            }
                            pos += 1
                        }
                    }
                }
            }
        }
    }
    
    func isPartOfPath(path: [Int], start: Int, end: Int) -> Bool {
        for i in 0...path.count-2 {
            if (start == path[i] && end == path[i+1]) ||
                (end == path[i] && start == path[i+1]) {
                return true
            }
        }
        
        return false
    }
    
    func doEdgesIntersect(edge1: Edge<Node>, edge2: Edge<Node>) -> Bool {
        let edge1Start: CGPoint = CGPoint(x: CGFloat(edge1.source.data.position.x), y: CGFloat(edge1.source.data.position.y)) // A
        let edge1End: CGPoint = CGPoint(x: CGFloat(edge1.destination.data.position.x), y: CGFloat(edge1.destination.data.position.y)) // B
        let edge2Start: CGPoint = CGPoint(x: CGFloat(edge2.source.data.position.x), y: CGFloat(edge2.source.data.position.y)) // C
        let edge2End: CGPoint = CGPoint(x: CGFloat(edge2.destination.data.position.x), y: CGFloat(edge2.destination.data.position.y)) // D
        
        let distance = (edge1End.x - edge1Start.x) * (edge2End.y - edge2Start.y) - (edge1End.y - edge1Start.y) * (edge2End.x - edge2Start.x)
        
        if distance == 0 && edge1.source != edge2.destination && edge1.destination != edge2.source  {
            return false
        }

        let u = ((edge2Start.x - edge1Start.x) * (edge2End.y - edge2Start.y) - (edge2Start.y - edge1Start.y) * (edge2End.x - edge2Start.x)) / distance
        let v = ((edge2Start.x - edge1Start.x) * (edge1End.y - edge1Start.y) - (edge2Start.y - edge1Start.y) * (edge1End.x - edge1Start.x)) / distance

        if (u <= 0.0 || u >= 1.0) {
            return false
        }
        if (v <= 0.0 || v >= 1.0) {
            return false
        }
    
        return true
    }
}
