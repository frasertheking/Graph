//
//  AdjacencyList.swift
//  Graph
//
//  Created by Fraser King on 2017-11-11.
//  Copyright © 2017 Fraser King. All rights reserved.
//

import Foundation
import SceneKit

public enum GraphType {
    case kColor
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
            return false
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
    
    func updateCorrectEdges(level: Level?, pathArray: [Int], edgeArray: [Edge<Node>], edgeNodes: SCNNode) {
        
        guard let currentLevel = level else {
            return
        }
        
        guard let hamiltonian = currentLevel.hamiltonian else {
            return
        }
        
        if hamiltonian {
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
            
            //            // update neighbours
            //            let neighbours = activeLevel?.adjacencyList?.getNeighbours(for: currentStep)
            //
            //            for vertexNode in vertexNodes.childNodes {
            //                if !pathArray.contains(Int((vertexNode.geometry?.name)!)!) {
            //                    if (neighbours?.contains((vertexNode.geometry?.name)!))! {
            //                        vertexNode.geometry?.firstMaterial?.diffuse.contents = UIColor.gray
            //                    } else if (vertexNode.geometry?.name)! != currentStep {
            //                        vertexNode.geometry?.firstMaterial?.diffuse.contents = UIColor.black
            //                    }
            //                }
            //            }
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
}
