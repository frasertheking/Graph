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

        let level1_1 = adjacencyListLevel1.createVertex(data: Node(position: SCNVector3(x: 2.0, y: 2.0, z: 2.0), uid: 1, color: .white))
        let level1_2 = adjacencyListLevel1.createVertex(data: Node(position: SCNVector3(x: 2.0, y: 2.0, z: -2.0), uid: 2, color: .white))
        let level1_3 = adjacencyListLevel1.createVertex(data: Node(position: SCNVector3(x: 2.0, y: -2.0, z: 2.0), uid: 3, color: .white))
        let level1_4 = adjacencyListLevel1.createVertex(data: Node(position: SCNVector3(x: 2.0, y: -2.0, z: -2.0), uid: 4, color: .white))
        let level1_5 = adjacencyListLevel1.createVertex(data: Node(position: SCNVector3(x: -2.0, y: 2.0, z: 2.0), uid: 5, color: .white))
        let level1_6 = adjacencyListLevel1.createVertex(data: Node(position: SCNVector3(x: -2.0, y: 2.0, z: -2.0), uid: 6, color: .white))
        let level1_7 = adjacencyListLevel1.createVertex(data: Node(position: SCNVector3(x: -2.0, y: -2.0, z: 2.0), uid: 7, color: .white))
        let level1_8 = adjacencyListLevel1.createVertex(data: Node(position: SCNVector3(x: -2.0, y: -2.0, z: -2.0), uid: 8, color: .white))
        
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
        
        let level1 = Level(name: "level1", adjacencyList: adjacencyListLevel1)
        
        playable.append(level1)
        
        // Level 2
        let adjacencyListLevel2 = AdjacencyList<Node>()
        
        let level2_1 = adjacencyListLevel2.createVertex(data: Node(position: SCNVector3(x: -2.0, y: 0.0, z: 0.0), uid: 1, color: .white))
        let level2_2 = adjacencyListLevel2.createVertex(data: Node(position: SCNVector3(x: 2.0, y: 0.0, z: 0.0), uid: 2, color: .white))
        
        adjacencyListLevel2.add(.undirected, from: level2_1, to: level2_2)
        
        let level2 = Level(name: "level2", adjacencyList: adjacencyListLevel2)
        
        playable.append(level2)
    }
    
    static func createLevel(index: Int) -> Level? {
        
        let levels = Levels.sharedInstance
        var level = levels.getRandomLevel()
        
        if index >= 0 && index < levels.playable.count {
            level =  levels.playable[index]
        }
        
        return level
    }
    
    // Randomization
    
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
            
            let vertex = adjacencyList.createVertex(data: Node(position: SCNVector3(x: randomX, y: randomY, z: randomZ), uid: count, color: .white))
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
