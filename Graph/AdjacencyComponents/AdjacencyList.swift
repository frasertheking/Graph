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
        var solved: Bool = true
        
        switch type {
        case .hamiltonian:
            return false
        default:
            for (_, value) in (graph.adjacencyDict) {
                for edge in value {
                    if edge.source.data.color == edge.destination.data.color ||
                        edge.source.data.color == .white ||
                        edge.destination.data.color == .white {
                        solved = false
                    }
                }
            }
        }
        
        return solved
    }
    
    // TODO: Actually finish 
    func getKColor() -> Int {
        let colors: [UIColor] = [.customRed(), .customGreen(), .customBlue(), .customPurple(), .customOrange(), .cyan]
        let graph: AdjacencyList<Node> = self as! AdjacencyList<Node>

        // USE BACKTRACKING?
        // FIRST PASS TO CATALOGUE ALL EDGES
        
        // solve graph
        var count = 0
        for (key, value) in (graph.adjacencyDict) {
            if count == 0 {
                key.data.color = colors[0]
            } else {
                var colorIndex = -1

                for (key2, value2) in (graph.adjacencyDict) {

                    for edge in value {
                        if colors.index(of: getlowestColor(for: edge.destination.data.color))! > colorIndex {
                            colorIndex = colors.index(of: getlowestColor(for: edge.destination.data.color))!
                        }
                    }
                }
                
                key.data.color = colors[colorIndex]
            }
            
            count += 1
        }
        
        var colorCount = [UIColor]()
        
        // count colors needed
        for (key, _) in (graph.adjacencyDict) {
            print(key.data.color)
            if !colorCount.contains(key.data.color) {
                colorCount.append(key.data.color)
            }
        }
        
        return colorCount.count
    }
    
    func getlowestColor(for node_color: UIColor) -> UIColor {
        let colors: [UIColor] = [.customRed(), .customGreen(), .customBlue(), .customPurple(), .customOrange(), .cyan]
        
        var count = 0
        for color in colors {
            count += 1
            
            if node_color == color {
                return colors[count]
            }
        }
        
        return colors[0]
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
    
}
