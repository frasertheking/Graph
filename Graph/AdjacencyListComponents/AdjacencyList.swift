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
    case sim
    case mix
}

public enum axis: Int {
    case x = 0
    case y
    case z
}

open class AdjacencyList<T: Hashable> {
    public var adjacencyDict : [Vertex<T>: [Edge<T>]] = [:]
    public init() {}
}

public var simPath: [Int] = []

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
    
    func checkIfSolved(forType type: GraphType, numberConfig: Int, edgeArray: [Edge<Node>], edgeNodes: SCNNode, targetColor: UIColor, selected: [String]) -> Bool {
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
                    if edge1 != edge2 && doEdgesIntersect(edge1: edge1, edge2: edge2, numberOfAxis: numberConfig) {
                        solved = false
                    }
                }
            }
            return solved
        case .sim:
            for (_, value) in (graph.adjacencyDict) {
                for edge1 in value {
                    let edge1Color = getEdgeColor(source: String(edge1.source.data.uid), destination: String(edge1.destination.data.uid), edgeArray: edgeArray, edgeNodes: edgeNodes)
                    
                    if edge1Color != .blue && edge1Color != .red {
                        continue
                    }
                    
                    for (_, value) in (graph.adjacencyDict) {
                        for edge2 in value {
                            let edge2Color = getEdgeColor(source: String(edge2.source.data.uid), destination: String(edge2.destination.data.uid), edgeArray: edgeArray, edgeNodes: edgeNodes)
                            if edge2Color != edge1Color {
                                continue
                            }
                            
                            for (_, value) in (graph.adjacencyDict) {
                                for edge3 in value {
                                    let edge3Color = getEdgeColor(source: String(edge3.source.data.uid), destination: String(edge3.destination.data.uid), edgeArray: edgeArray, edgeNodes: edgeNodes)
                                    if edge3Color != edge2Color {
                                        continue
                                    }
                                    
                                    if (edge1 != edge2 && edge1 != edge3 && edge2 != edge3) {
                                        let vertexSet = Set([edge1.source.data.uid, edge1.destination.data.uid,
                                                            edge2.source.data.uid, edge2.destination.data.uid,
                                                            edge3.source.data.uid, edge3.destination.data.uid])
                                        
                                        let positionArray: [SCNVector3] = [edge1.source.data.position, edge1.destination.data.position,
                                                                           edge2.source.data.position, edge2.destination.data.position,
                                                                           edge3.source.data.position, edge3.destination.data.position]
                                        
                                        if vertexSet.count == 3 {
                                            
                                            var thirdPosition: SCNVector3?
                                            for position in positionArray {
                                                if !position.equal(b: positionArray[0]) && !position.equal(b: positionArray[1]) {
                                                    thirdPosition = position
                                                    break
                                                }
                                            }

                                            let triangle = SCNGeometry.triangleFrom(vector1: positionArray[0], vector2: positionArray[1], vector3: thirdPosition!)
                                            let triangleNode = SCNNode(geometry: triangle)
                                            triangleNode.geometry?.firstMaterial?.diffuse.contents = edge1Color
                                            triangleNode.geometry?.firstMaterial?.isDoubleSided = true
                                            edgeNodes.addChildNode(triangleNode)
                                            
                                            return true
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            return false
        case .kColor:
            for (_, value) in (graph.adjacencyDict) {
                for edge in value {
                    if edge.source.data.color == edge.destination.data.color ||
                        edge.source.data.color == .white ||
                        edge.destination.data.color == .white {
                        return false
                    }
                }
            }
        case .mix:
            for (key, _) in (graph.adjacencyDict) {
                if ((key.data.color == targetColor && !selected.contains("\(key.data.uid)")) ||
                    (key.data.color != targetColor && selected.contains("\(key.data.uid)"))) {
                    return false
                }
            }
            return true
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
    
    func getMirrorNodeUID(id: String?) -> Int? {
        let graph: AdjacencyList<Node> = self as! AdjacencyList<Node>
        for (key, _) in (graph.adjacencyDict) {
            if "\(key.data.uid)" == id {
                return key.data.mirrorUID
            }
        }
        return nil
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
                    vertexNodes.childNodes[pos].geometry?.firstMaterial?.diffuse.contents = UIColor.defaultVertexColor()
                }
                pos += 1
            }
        }
    }
    
    func makeSimMove(edgeArray: [Edge<Node>], edgeNodes: SCNNode, simArray: [Int]) {
        var randomEdge: [Int] = []
        
        var count = 0
        while count < 100 {
            var edge = uniqueRandoms(numberOfRandoms: 2, minNum: 1, maxNum: 5)

            if !doesEdgeExistInArray(array: simArray, uid1: edge[0], uid2: edge[1]) {
                if !doesEdgeExistInArray(array: simPath, uid1: edge[0], uid2: edge[1]) {
                    randomEdge = edge
                    break
                }
            }
            count += 1
        }
        
        // Last edge, no move to make
        if randomEdge.count == 0 { return }
        
        for (_, value) in (self.adjacencyDict) {
            for case let edge as Edge<Node> in value  {
                if ( edge.source.data.uid      == randomEdge[0] &&
                     edge.destination.data.uid == randomEdge[1]) ||
                   ( edge.destination.data.uid == randomEdge[0] &&
                     edge.source.data.uid      == randomEdge[1]) {
                    var pos = 0
                    for edgeNode in edgeArray {
                        if edgeNode.source == edge.source && edgeNode.destination == edge.destination  {
                            edgeNodes.childNodes[pos].geometry?.firstMaterial?.diffuse.contents = UIColor.blue
                            
                            guard let edgeGeometry = edgeNodes.childNodes[pos].geometry else {
                                continue
                            }
                            
                            if let smokeEmitter = ParticleGeneration.createSmoke(color: UIColor.blue, geometry: edgeGeometry) {
                                edgeNodes.childNodes[pos].removeAllParticleSystems()
                                edgeNodes.childNodes[pos].addParticleSystem(smokeEmitter)
                            }
                            
                            edge.source.data.color = UIColor.blue
                            edge.destination.data.color = UIColor.blue
                            
                            simPath.append(edge.source.data.uid)
                            simPath.append(edge.destination.data.uid)
                        }
                        pos += 1
                    }
                }
            }
        }
    }
    
    func getEdgeColor(source: String, destination: String, edgeArray: [Edge<Node>], edgeNodes: SCNNode) -> UIColor? {
        var pos = 0
        for edgeNode in edgeArray {
            if String(edgeNode.source.data.uid) == source && String(edgeNode.destination.data.uid) == destination  {
                return edgeNodes.childNodes[pos].geometry?.firstMaterial?.diffuse.contents as? UIColor
            }
            pos += 1
        }
        return nil
    }
    
    func isLegalMove(simArray: [Int], uid1: Int, uid2: Int) -> Bool {
        return !doesEdgeExistInArray(array: simArray, uid1: uid1, uid2: uid2) && !doesEdgeExistInArray(array: simPath, uid1: uid1, uid2: uid2)
    }
    
    func doesEdgeExistInArray(array: [Int], uid1: Int, uid2: Int) -> Bool {
        var pos = 0
        while pos <= array.count-2 {
            if (array[pos] == uid1 && array[pos+1] == uid2) || (array[pos] == uid2 && array[pos+1] == uid1) {
                return true
            }
            pos += 2
        }
        return false
    }
    
    func uniqueRandoms(numberOfRandoms: Int, minNum: Int, maxNum: UInt32) -> [Int] {
        var uniqueNumbers = Set<Int>()
        while uniqueNumbers.count < numberOfRandoms {
            uniqueNumbers.insert(Int(arc4random_uniform(maxNum + 1)) + minNum)
        }
        return Array(uniqueNumbers).shuffle
    }
    
    func updateCorrectEdges(level: Level?, pathArray: [Int], mirrorArray: [Int], edgeArray: [Edge<Node>], edgeNodes: SCNNode) {
        
        guard let currentLevel = level else {
            return
        }
        
        guard let graphType = currentLevel.graphType else {
            return
        }

        guard let numberConfig = currentLevel.numberOfColorsProvided else {
            return
        }
        
        if graphType == .hamiltonian {
            if pathArray.count > 1 {
                for i in 0...pathArray.count-2 {
                    var pos = 0
                    for edgeNode in edgeArray {
                        if ((edgeNode.source.data.uid == pathArray[i] && edgeNode.destination.data.uid == pathArray[i+1]) ||
                            (mirrorArray.count > 0 && edgeNode.source.data.uid == mirrorArray[i] && edgeNode.destination.data.uid == mirrorArray[i+1])) ||
                           ((edgeNode.destination.data.uid == pathArray[i] && edgeNode.source.data.uid == pathArray[i+1]) ||
                            (mirrorArray.count > 0 && edgeNode.destination.data.uid == mirrorArray[i] && edgeNode.source.data.uid == mirrorArray[i+1])) {
                            edgeNodes.childNodes[pos].geometry?.firstMaterial?.diffuse.contents = UIColor.white
                            edgeNodes.childNodes[pos].geometry?.firstMaterial?.emission.contents = UIColor.glowColor()
                            
                            guard let edgeGeometry = edgeNodes.childNodes[pos].geometry else {
                                continue
                            }
                            
                            if let smokeEmitter = ParticleGeneration.createSmoke(color: UIColor.glowColor(), geometry: edgeGeometry) {
                                edgeNodes.childNodes[pos].removeAllParticleSystems()
                                edgeNodes.childNodes[pos].addParticleSystem(smokeEmitter)
                            }
                        } else if !isPartOfPath(path: pathArray, start: edgeNode.source.data.uid, end: edgeNode.destination.data.uid) &&
                                  !isPartOfPath(path: mirrorArray, start: edgeNode.source.data.uid, end: edgeNode.destination.data.uid) {
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
                    if edge1 != edge2 && doEdgesIntersect(edge1: edge1, edge2: edge2, numberOfAxis: numberConfig) {
                        intersectingEdges.append(edge1)
                        intersectingEdges.append(edge2)
                    }
                }
            }
            
            var pos = 0
            for edgeNode in edgeArray {
                if intersectingEdges.contains(edgeNode) {
                    edgeNodes.childNodes[pos].geometry?.firstMaterial?.diffuse.contents = UIColor.defaultVertexColor()
                } else {
                    edgeNodes.childNodes[pos].geometry?.firstMaterial?.diffuse.contents = UIColor.white
                    edgeNodes.childNodes[pos].geometry?.firstMaterial?.emission.contents = UIColor.glowColor()
                    
                    guard let edgeGeometry = edgeNodes.childNodes[pos].geometry else {
                        continue
                    }
                    
                    if let smokeEmitter = ParticleGeneration.createSmoke(color: UIColor.glowColor(), geometry: edgeGeometry) {
                        edgeNodes.childNodes[pos].removeAllParticleSystems()
                        edgeNodes.childNodes[pos].addParticleSystem(smokeEmitter)
                    }
                }
                pos += 1
            }
        } else if graphType == .sim {
            if pathArray.count > 1 {
                for i in 0...pathArray.count-2 {
                    var pos = 0
                    for edgeNode in edgeArray {
                        if (edgeNode.source.data.uid == pathArray[i] && edgeNode.destination.data.uid == pathArray[i+1]) ||
                            (edgeNode.destination.data.uid == pathArray[i] && edgeNode.source.data.uid == pathArray[i+1]) {
                            edgeNodes.childNodes[pos].geometry?.firstMaterial?.diffuse.contents = UIColor.red
                            edgeNodes.childNodes[pos].geometry?.firstMaterial?.emission.contents = UIColor.red
                            
                            guard let edgeGeometry = edgeNodes.childNodes[pos].geometry else {
                                continue
                            }
                            
                            if let smokeEmitter = ParticleGeneration.createSmoke(color: UIColor.red, geometry: edgeGeometry) {
                                edgeNodes.childNodes[pos].removeAllParticleSystems()
                                edgeNodes.childNodes[pos].addParticleSystem(smokeEmitter)
                            }
                        } else if !isPartOfPath(path: pathArray, start: edgeNode.source.data.uid, end: edgeNode.destination.data.uid) &&
                            edgeNodes.childNodes[pos].geometry?.firstMaterial?.diffuse.contents as! UIColor == UIColor.clear {
                                edgeNodes.childNodes[pos].geometry?.firstMaterial?.diffuse.contents = UIColor.clear
                                edgeNodes.childNodes[pos].geometry?.firstMaterial?.emission.contents = UIColor.clear
                        }
                        pos += 1
                    }
                }
            }
        } else if graphType == .mix {
            // Do not update in this case
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
                                    edgeNodes.childNodes[pos].removeAllParticleSystems()
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
        if path.count == 0 {
            return false
        }
        
        for i in 0...path.count-2 {
            if (start == path[i] && end == path[i+1]) ||
                (end == path[i] && start == path[i+1]) {
                return true
            }
        }
        
        return false
    }
    
    func doEdgesIntersect(edge1: Edge<Node>, edge2: Edge<Node>, numberOfAxis: Int) -> Bool {
        var checkEdgeZY = false
        var checkEdgeXZ = false
        
        let edge1StartXY: CGPoint = CGPoint(x: CGFloat(edge1.source.data.position.x), y: CGFloat(edge1.source.data.position.y)) // A
        let edge1EndXY: CGPoint = CGPoint(x: CGFloat(edge1.destination.data.position.x), y: CGFloat(edge1.destination.data.position.y)) // B
        let edge2StartXY: CGPoint = CGPoint(x: CGFloat(edge2.source.data.position.x), y: CGFloat(edge2.source.data.position.y)) // C
        let edge2EndXY: CGPoint = CGPoint(x: CGFloat(edge2.destination.data.position.x), y: CGFloat(edge2.destination.data.position.y)) // D
        let  checkEdgeXY = checkIntersection(edge1Start: edge1StartXY, edge1End: edge1EndXY, edge2Start: edge2StartXY, edge2End: edge2EndXY, edge1: edge1, edge2: edge2)
        
        let edge1StartZY: CGPoint = CGPoint(x: CGFloat(edge1.source.data.position.z), y: CGFloat(edge1.source.data.position.y)) // A
        let edge1EndZY: CGPoint = CGPoint(x: CGFloat(edge1.destination.data.position.z), y: CGFloat(edge1.destination.data.position.y)) // B
        let edge2StartZY: CGPoint = CGPoint(x: CGFloat(edge2.source.data.position.z), y: CGFloat(edge2.source.data.position.y)) // C
        let edge2EndZY: CGPoint = CGPoint(x: CGFloat(edge2.destination.data.position.z), y: CGFloat(edge2.destination.data.position.y)) // D
        if numberOfAxis > 0 {
            checkEdgeZY = checkIntersection(edge1Start: edge1StartZY, edge1End: edge1EndZY, edge2Start: edge2StartZY, edge2End: edge2EndZY, edge1: edge1, edge2: edge2)
        }
        
        let edge1StartXZ: CGPoint = CGPoint(x: CGFloat(edge1.source.data.position.x), y: CGFloat(edge1.source.data.position.z)) // A
        let edge1EndXZ: CGPoint = CGPoint(x: CGFloat(edge1.destination.data.position.x), y: CGFloat(edge1.destination.data.position.z)) // B
        let edge2StartXZ: CGPoint = CGPoint(x: CGFloat(edge2.source.data.position.x), y: CGFloat(edge2.source.data.position.z)) // C
        let edge2EndXZ: CGPoint = CGPoint(x: CGFloat(edge2.destination.data.position.x), y: CGFloat(edge2.destination.data.position.z)) // D
        if numberOfAxis > 1 {
            checkEdgeXZ = checkIntersection(edge1Start: edge1StartXZ, edge1End: edge1EndXZ, edge2Start: edge2StartXZ, edge2End: edge2EndXZ, edge1: edge1, edge2: edge2)
        }
        
        return checkEdgeXY || checkEdgeZY || checkEdgeXZ
    }

    func checkIntersection(edge1Start: CGPoint, edge1End: CGPoint, edge2Start: CGPoint, edge2End: CGPoint, edge1: Edge<Node>, edge2: Edge<Node>) -> Bool {
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
    
    ///// Color Mixing Stuff
    func getColorForScreen(trueColor: UIColor, screen: UIColor) -> UIColor {
        if trueColor == .white {
            return screen
        }
                
        if screen == .red && (trueColor == .red || trueColor == .yellow || trueColor == .magenta) {
            return .red
        }
        
        if screen == .green && (trueColor == .green || trueColor == .yellow || trueColor == .cyan) {
            return .green
        }
        
        if screen == .blue && (trueColor == .blue || trueColor == .cyan || trueColor == .magenta) {
            return .blue
        }
        
        return .black        
    }

}
