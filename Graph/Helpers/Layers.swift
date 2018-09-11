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
            
            gameLayers.append(Layer(name: name, active: active, locked: locked, colors: colors, levelPath: levelPath, completePercent: completePercent, animatedImagePath: animatedImagePath, idleImagePath: idleImagePath))
        }
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

