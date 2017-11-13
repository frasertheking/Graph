//
//  Levels.swift
//  Graph
//
//  Created by Fraser King on 2017-11-12.
//  Copyright © 2017 Fraser King. All rights reserved.
//

import Foundation
import SceneKit

class Levels: NSObject {
    
    static let sharedInstance = Levels()
    var playable: [Level] = []

    override init() {
        let adjacencyListLevel1 = AdjacencyList<Node>()

        let level1_1 = adjacencyListLevel1.createVertex(data: Node(position: SCNVector3(x: 2.0, y: 2.0, z: 2.0), uid: 1))
        let level1_2 = adjacencyListLevel1.createVertex(data: Node(position: SCNVector3(x: 2.0, y: 2.0, z: -2.0), uid: 2))
        let level1_3 = adjacencyListLevel1.createVertex(data: Node(position: SCNVector3(x: 2.0, y: -2.0, z: 2.0), uid: 3))
        let level1_4 = adjacencyListLevel1.createVertex(data: Node(position: SCNVector3(x: 2.0, y: -2.0, z: -2.0), uid: 4))
        let level1_5 = adjacencyListLevel1.createVertex(data: Node(position: SCNVector3(x: -2.0, y: 2.0, z: 2.0), uid: 5))
        let level1_6 = adjacencyListLevel1.createVertex(data: Node(position: SCNVector3(x: -2.0, y: 2.0, z: -2.0), uid: 6))
        let level1_7 = adjacencyListLevel1.createVertex(data: Node(position: SCNVector3(x: -2.0, y: -2.0, z: 2.0), uid: 7))
        let level1_8 = adjacencyListLevel1.createVertex(data: Node(position: SCNVector3(x: -2.0, y: -2.0, z: -2.0), uid: 8))
        
        adjacencyListLevel1.add(.undirected, from: level1_1, to: level1_5)
        adjacencyListLevel1.add(.undirected, from: level1_1, to: level1_3)
        adjacencyListLevel1.add(.undirected, from: level1_1, to: level1_2)
        adjacencyListLevel1.add(.undirected, from: level1_6, to: level1_5)
        adjacencyListLevel1.add(.undirected, from: level1_6, to: level1_8)
        adjacencyListLevel1.add(.undirected, from: level1_6, to: level1_2)
        adjacencyListLevel1.add(.undirected, from: level1_4, to: level1_2)
        adjacencyListLevel1.add(.undirected, from: level1_4, to: level1_3)
        adjacencyListLevel1.add(.undirected, from: level1_4, to: level1_8)
        adjacencyListLevel1.add(.undirected, from: level1_7, to: level1_8)
        adjacencyListLevel1.add(.undirected, from: level1_7, to: level1_3)
        adjacencyListLevel1.add(.undirected, from: level1_7, to: level1_5)
        
        let start = Level(name: "start", adjacencyList: adjacencyListLevel1)
        
        playable.append(start)
    }
    
    func randomNumber<T : SignedInteger>(inRange range: ClosedRange<T> = 1...6) -> T {
        let length = Int64(range.upperBound - range.lowerBound + 1)
        let value = Int64(arc4random()) % length + Int64(range.lowerBound)
        return T(value)
    }
    
    func getRandomLevel() -> Level {
        let adjacencyList = AdjacencyList<Node>()
        let numberOfVertices = randomNumber(inRange: 4...8)
        let numberOfEdges = randomNumber(inRange: (numberOfVertices + 1)...(numberOfVertices + 5))
        var vertices: [Vertex<Node>] = []
        
        var count = 0
        for _ in 0...numberOfVertices {
            let randomX = Float(randomNumber(inRange: -5...5))
            let randomY = Float(randomNumber(inRange: -7...7))
            let randomZ = Float(randomNumber(inRange: -5...5))
            
            let vertex = adjacencyList.createVertex(data: Node(position: SCNVector3(x: randomX, y: randomY, z: randomZ), uid: count))
            vertices.append(vertex)
            count += 1
        }
        
        for index in 0...numberOfEdges {
            let edgeStart = index % (numberOfVertices + 1)
            var edgeEnd = randomNumber(inRange: 0...vertices.count-1)
            while (edgeStart == edgeEnd) {
                edgeEnd = randomNumber(inRange: 0...vertices.count-1)
            }
            adjacencyList.add(.undirected, from: vertices[edgeStart], to: vertices[edgeEnd])
        }
        
        return Level(name: "random", adjacencyList: adjacencyList)
    }
}
