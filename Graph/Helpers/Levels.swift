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
        var levels: NSArray?
        if let path = Bundle.main.path(forResource: "levels", ofType: "plist") {
            levels = NSArray(contentsOfFile: path)
        }
        
        guard let levelArray = levels else {
            return
        }
        
        for level in levelArray {
            let levelDict: Dictionary = level as! Dictionary<String, Any>
            let adjacencyList = AdjacencyList<Node>()
            var vertexBin: [Vertex<Node>] = []
            
            for node in levelDict["nodes"] as! NSArray {
                let nodeDict: Dictionary = node as! Dictionary<String, Any>
                let newNode = adjacencyList.createVertex(data: Node(position: SCNVector3(x: nodeDict["x"] as! Float, y: nodeDict["y"] as! Float, z: nodeDict["z"] as! Float), uid: nodeDict["uid"] as! Int, color: .white))
                vertexBin.append(newNode)
            }
            
            for node in levelDict["nodes"] as! NSArray {
                let nodeDict: Dictionary = node as! Dictionary<String, Any>
                
                for edge in nodeDict["edges"] as! NSArray {
                    adjacencyList.add(.undirected, from: vertexBin[(nodeDict["uid"] as! Int)-1], to: vertexBin[(edge as! Int)-1])
                }
            }
            
            playable.append(Level(name: levelDict["name"] as? String, adjacencyList: adjacencyList))
        }
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
