//
//  Layers.swift
//  Graph
//
//  Created by Fraser King on 2018-09-11.
//  Copyright © 2018 Fraser King. All rights reserved.
//

import Foundation
import SceneKit

class Layers: NSObject, NSCopying {
    
    static let sharedInstance = Layers()
    var gameLayers: [Layer] = []
    
    required override init() {
        super.init()
        
        var layers: NSArray?
        // Read curated layers from plist
        if let path = Bundle.main.path(forResource: "layers", ofType: "plist") {
            layers = NSArray(contentsOfFile: path)
        }
        
        guard let layerArray = layers else {
            return
        }
        
        for layer in layerArray {
            guard let layerDict: Dictionary = layer as? Dictionary<String, Any> else {
                continue
            }
            
            guard let name: String = layerDict["name"] as? String else {
                continue
            }
            
            guard let active: Bool = layerDict["active"] as? Bool else {
                continue
            }
            
            guard let locked: Bool = layerDict["locked"] as? Bool else {
                continue
            }
            
            guard let colors: [String] = layerDict["colors"] as? [String] else {
                continue
            }
            
            guard let levelPath: String = layerDict["level_path"] as? String else {
                continue
            }
            
            guard let completePercent: NSNumber = layerDict["completed_percent"] as? NSNumber else {
                continue
            }
            
            guard let animatedImagePath: String = layerDict["image_anim"] as? String else {
                continue
            }
            
            guard let idleImagePath: String = layerDict["image_idle"] as? String else {
                continue
            }
            
            guard let gameLevels: [Level] = getLevelsForPath(levelPath: levelPath) else {
                continue
            }
            
            gameLayers.append(Layer(name: name, active: active, locked: locked, colors: colors, levelPath: levelPath, completePercent: completePercent, animatedImagePath: animatedImagePath, idleImagePath: idleImagePath, gameLevels: gameLevels))
        }
    }
    
    func getLevelsForPath(levelPath: String) -> [Level]? {
        var levels: NSArray?
        // Read curated levels from plist
        if let path = Bundle.main.path(forResource: levelPath, ofType: "plist") {
            levels = NSArray(contentsOfFile: path)
        }
        
        guard let levelArray = levels else {
            return nil
        }
        
        var gameLevels: [Level] = []
        
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
                
//                if levelDict["name"] as? String == "pyritohedron" {
//                    //let h: Float = 0
//                    //let h: Float = -((sqrt(5) + 1) / 2)
//                    let h: Float = ((sqrt(5) - 1) / 2)
//                    //let h: Float = 1
//                    posVector = Levels.getPyritohedronCoordinate(for: uid, h: h)
//                }
                
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
                return nil
            }
            
            gameLevels.append(Level(name: levelDict["name"] as? String, numberOfColorsProvided: levelDict["num_colors"] as? Int, graphType: graphType, timed: timed, isMirror: isMirror, targetColor: UIColor.getColorFromStringName(color: targetColor), adjacencyList: adjacencyList))
        }
        
        return gameLevels
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = type(of: self).init()
        return copy
    }
    
    static func instantiateLayer(index: Int) -> Layer? {
        guard let layers = Layers.sharedInstance.copy() as? Layers else {
            return nil
        }
        
        if index >= 0 && index < layers.gameLayers.count {
            return layers.gameLayers[index]
        }
        
        return nil
    }
}

