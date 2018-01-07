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
    var gameLevels: [Level] = []

    override init() {
        var levels: NSArray?
        
        // Read curated levels from plist
        if let path = Bundle.main.path(forResource: "levels", ofType: "plist") {
            levels = NSArray(contentsOfFile: path)
        }
        
        guard let levelArray = levels else {
            return
        }
        
        for level in levelArray {
            
            // Unpack level
            guard let levelDict: Dictionary = level as? Dictionary<String, Any> else {
                continue
            }
            let adjacencyList = AdjacencyList<Node>()
            var vertexBin: [Vertex<Node>] = []
            
            guard let levelArray: NSArray = levelDict["nodes"] as? NSArray else {
                continue
            }
            
            // Unpack graph nodes
            for node in levelArray {
                guard let nodeDict: Dictionary = node as? Dictionary<String, Any> else {
                    continue
                }
                
                guard let x: Float = nodeDict["x"] as? Float, let y: Float = nodeDict["y"] as? Float, let z: Float = nodeDict["z"] as? Float, let uid: Int = nodeDict["uid"] as? Int else {
                    continue
                }
                
                let newNode = adjacencyList.createVertex(data: Node(position: SCNVector3(x: x, y: y, z: z), uid: uid, color: .white))
                vertexBin.append(newNode)
            }
                        
            // Unpack graph edges
            for node in levelArray {
                guard let nodeDict: Dictionary = node as? Dictionary<String, Any> else {
                    continue
                }
                
                guard let edgeArray: NSArray = nodeDict["edges"] as? NSArray else {
                    continue
                }
                
                for edge in edgeArray {
                    guard let from_pos: Int = nodeDict["uid"] as? Int, let to_pos: Int = edge as? Int else {
                        continue
                    }
                    
                    adjacencyList.add(.undirected, from: vertexBin[from_pos - 1], to: vertexBin[to_pos - 1])
                }
            }
            
            guard let graphTypeInt: Int = levelDict["graph_type"] as? Int else {
                continue
            }
            
            guard let graphType: GraphType = GraphType(rawValue: graphTypeInt) else {
                return
            }
            
            gameLevels.append(Level(name: levelDict["name"] as? String, numberOfColorsProvided: levelDict["num_colors"] as? Int, graphType: graphType, adjacencyList: adjacencyList))
        }
    }
    
    static func createLevel(index: Int) -> Level? {
        let levels = Levels.sharedInstance
        var level = levels.getRandomLevel()
        
        // Check to see if we have a level for current progress
        // If yes, provide level else, provide randomly generated level
        if index >= 0 && index < levels.gameLevels.count {
            level = levels.gameLevels[index]
        }
        
        return level
    }
    
    // Randomization
    func randomNumber<T : SignedInteger>(inRange range: ClosedRange<T> = 1...6) -> T {
        let length = Int64(range.upperBound - range.lowerBound + 1)
        let value = Int64(arc4random()) % length + Int64(range.lowerBound)
        return T(value)
    }
    
    // TODO: Improve this generation and abstract to other graph types
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
        
        return Level(name: "random", numberOfColorsProvided: 3, graphType: GraphType.kColor, adjacencyList: adjacencyList)
    }
}
