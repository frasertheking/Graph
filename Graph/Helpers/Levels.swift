//
//  Levels.swift
//  Graph
//
//  Created by Fraser King on 2017-11-12.
//  Copyright © 2017 Fraser King. All rights reserved.
//

import Foundation
import SceneKit

class Levels: NSObject, NSCopying {
    
    static let sharedInstance = Levels()
    var gameLevels: [Level] = []

    required override init() {
        
        var levels: NSArray?
        // Read curated levels from plist
        if let path = Bundle.main.path(forResource: "layer1", ofType: "plist") {
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
            
            guard let isMirror: Bool = levelDict["is_mirror"] as? Bool else {
                continue
            }
            
            guard let levelArray: NSArray = levelDict["nodes"] as? NSArray else {
                continue
            }
            
            guard let graphTypeInt: Int = levelDict["graph_type"] as? Int else {
                continue
            }
            
            var targetColor: String?
            if graphTypeInt == GraphType.mix.rawValue {
                guard let color: String = levelDict["target_color"] as? String else {
                    continue
                }
                targetColor = color
            }
            
            // Unpack graph nodes
            for node in levelArray {
                guard let nodeDict: Dictionary = node as? Dictionary<String, Any> else {
                    continue
                }
                
                guard let x: Double = nodeDict["x"] as? Double, let y: Double = nodeDict["y"] as? Double, let z: Double = nodeDict["z"] as? Double, let uid: Int = nodeDict["uid"] as? Int else {
                    continue
                }
                
                var nodeColor: String?
                if graphTypeInt == GraphType.mix.rawValue {
                    guard let color: String = nodeDict["color"] as? String else {
                        continue
                    }
                    nodeColor = color
                }
                
                // @Cleanup: Why is this here again?... Likely shouldn't be :/
                var scaleFactor: Float = 1
                if levelDict["name"] as? String == "Icosian" || levelDict["name"] as? String == "pyritohedron" {
                    scaleFactor = 3
                }
                
                var mirrorUID: Int? = nil
                
                if isMirror {
                    mirrorUID = nodeDict["mirror"] as? Int
                }
                
                var Zfuzz: Float = 0
                
                if graphTypeInt == 2 {
                    Zfuzz = (Float(arc4random()) / Float(UINT32_MAX) / 2) - 1
                }
                
                var posVector = SCNVector3(x: Float(x), y: Float(y), z: Float(z))
                
                if levelDict["name"] as? String == "pyritohedron" {
                    //let h: Float = 0
                    //let h: Float = -((sqrt(5) + 1) / 2)
                    let h: Float = ((sqrt(5) - 1) / 2)
                    //let h: Float = 1
                    posVector = Levels.getPyritohedronCoordinate(for: uid, h: h)
                }
                
                posVector = SCNVector3(x: posVector.x * scaleFactor, y: posVector.y * scaleFactor, z: (posVector.z * scaleFactor) + Zfuzz)
                
                let newNode = adjacencyList.createVertex(data: Node(position: posVector, uid: uid, color: UIColor.getColorFromStringName(color: nodeColor), mirrorUID: mirrorUID))
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
                    
                    if levelDict["name"] as? String == "LEVEL SELECT" {
                        if vertexBin.count > from_pos && vertexBin.count > to_pos {
                            adjacencyList.add(.undirected, from: vertexBin[from_pos], to: vertexBin[to_pos])
                        }
                    } else {
                        if vertexBin.count > from_pos-1 && vertexBin.count > to_pos-1 {
                            adjacencyList.add(.undirected, from: vertexBin[from_pos-1], to: vertexBin[to_pos-1])
                        }
                    }
                }
            }
            
            guard let timed: Bool = levelDict["timed"] as? Bool else {
                continue
            }
            
            guard let graphType: GraphType = GraphType(rawValue: graphTypeInt) else {
                return
            }
            
            gameLevels.append(Level(name: levelDict["name"] as? String, numberOfColorsProvided: levelDict["num_colors"] as? Int, graphType: graphType, timed: timed, isMirror: isMirror, targetColor: UIColor.getColorFromStringName(color: targetColor), adjacencyList: adjacencyList))
        }
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = type(of: self).init()
        return copy
    }
    
    static func getPyritohedronCoordinate(for id: Int, h: Float) -> SCNVector3 {
        switch id {
        case 1:
            return SCNVector3(x: -1, y: 1, z: 1)
        case 2:
            return SCNVector3(x: 0, y: (1 + h), z: (1 - pow(h, 2)))
        case 3:
            return SCNVector3(x: 1, y: 1, z: 1)
        case 4:
            return SCNVector3(x: (1 - pow(h, 2)), y: 0, z: (1 + h))
        case 5:
            return SCNVector3(x: 1, y: -1, z: 1)
        case 6:
            return SCNVector3(x: 0, y: -(1 + h ), z: (1 - pow(h, 2)))
        case 7:
            return SCNVector3(x: 0, y: -(1 + h), z: -(1 - pow(h, 2)))
        case 8:
            return SCNVector3(x: -1, y: -1, z: -1)
        case 9:
            return SCNVector3(x: -(1 + h), y: -(1 - pow(h, 2)), z: 0)
        case 10:
            return SCNVector3(x: -1, y: -1, z: 1)
        case 11:
            return SCNVector3(x: -(1 - pow(h, 2)), y: 0, z: (1 + h))
        case 12:
            return SCNVector3(x: -(1 - pow(h, 2)), y: 0, z: -(1 + h))
        case 13:
            return SCNVector3(x: (1 - pow(h, 2)), y: 0, z: -(1 + h))
        case 14:
            return SCNVector3(x: 1, y: -1, z: -1)
        case 15:
            return SCNVector3(x: (1 + h), y: -(1 - pow(h, 2)), z: 0)
        case 16:
            return SCNVector3(x: (1 + h), y: (1 - pow(h, 2)), z: 0)
        case 17:
            return SCNVector3(x: 1, y: 1, z: -1)
        case 18:
            return SCNVector3(x: 0, y: (1 + h), z: -(1 - pow(h, 2)))
        case 19:
            return SCNVector3(x: -1, y: 1, z: -1)
        default:
            return SCNVector3(x: -(1 + h), y: (1 - pow(h, 2)), z: 0)
        }
    }
    
    static func createLevel(index: Int) -> Level? {
        guard let levels = Levels.sharedInstance.copy() as? Levels else {
            return nil
        }
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
            
            let vertex = adjacencyList.createVertex(data: Node(position: SCNVector3(x: randomX, y: randomY, z: randomZ), uid: count, color: .white, mirrorUID: nil))
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
        
        return Level(name: "random", numberOfColorsProvided: 3, graphType: GraphType.kColor, timed: false, isMirror: false, targetColor: nil, adjacencyList: adjacencyList)
    }
}
