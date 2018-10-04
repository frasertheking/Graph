//
//  UserDefaultsInteractor.swift
//  Graph
//
//  Created by Fraser King on 2018-04-12.
//  Copyright © 2018 Fraser King. All rights reserved.
//

import Foundation
import SceneKit

public enum LevelState: Int {
    case base = 0
    case completed
    case locked
    case random
    case timed
    case emitter
}

struct UserDefaultsInteractor {
    private init() {}
    
    fileprivate static let layerStateKeys: [String] = ["layer1", "layer2", "layer3", "layer4", "layer5"]
    fileprivate static let levelSelectPosition: String = "levelPosition"
    fileprivate static let levelZoomFactor: String = "levelZoom"
    fileprivate static let currentLayer: String = "currentLayer"

    // Level select scrolled position
    // The positions array is action as a vector to track the x and y position of the level select graph
    // It was always be len = 2 with pos[0] = x and pos[1] = y
    static func setLevelSelectPosition(pos: [Float]) {
        UserDefaults.standard.set(pos, forKey: levelSelectPosition)
    }
    
    static func getLevelSelectPosition() -> SCNVector3 {
        let basePosition = SCNVector3(x: 0, y: 0, z: 0)
        
        if isKeyPresentInUserDefaults(key: levelSelectPosition) {
            guard let position = UserDefaults.standard.object(forKey: levelSelectPosition) as? [Float] else {
                return basePosition
            }
            return SCNVector3(x: position[0], y: position[1], z: 0)
        }
        
        // Initialize default value to 0 0 if key is not yet set
        UserDefaults.standard.set([0.0, 0.0], forKey: levelSelectPosition)
        return basePosition
    }
    
    static func clearLevelSelectPosition() {
        UserDefaults.standard.set(nil, forKey: levelSelectPosition)
    }
    
    // Level select zoomed level
    // This is a Float between 14 and 36 where 25 represents no zoom,
    // 14 represents zoomed in max and 36 represents zoomed out max
    static func setZoomFactor(pos: Float) {
        UserDefaults.standard.set(pos, forKey: levelZoomFactor)
    }
    
    static func getZoomFactor() -> Float {
        let baseFactor: Float = 25
        
        if isKeyPresentInUserDefaults(key: levelZoomFactor) {
            guard let factor = UserDefaults.standard.object(forKey: levelZoomFactor) as? Float else {
                return baseFactor
            }
            return factor
        }
        
        // Initialize default value to 0 0 if key is not yet set
        UserDefaults.standard.set(25, forKey: levelZoomFactor)
        return baseFactor
    }
    
    static func clearZoomFactor() {
        UserDefaults.standard.set(nil, forKey: levelZoomFactor)
    }
    
    // Level States Interaction
    fileprivate static func setLevelStates(levels: [Int], for layer: Int) {
        UserDefaults.standard.set(levels, forKey: layerStateKeys[layer])
    }
    
    static func getLevelStates(for layer: Int) -> [Int] {
        var baseLevels: [Int] = [Int](repeatElement(LevelState.locked.rawValue, count: 64))
        
        // Setup basic level states
        baseLevels[0] = LevelState.emitter.rawValue
        let layerBaseLevels: [Int] = Layers.sharedInstance.gameLayers[layer].baseLevels
        
        for baseLevel in layerBaseLevels {
            baseLevels[baseLevel] = LevelState.base.rawValue
        }
        
        if isKeyPresentInUserDefaults(key: layerStateKeys[layer]) {
            guard let levelArray = UserDefaults.standard.object(forKey: layerStateKeys[layer]) as? [Int] else {
                return baseLevels
            }
            return levelArray
        }
        
        // Initialize default value if key is not yet set (level 0 is complete by default)
        UserDefaults.standard.set(baseLevels, forKey: layerStateKeys[layer])
        return baseLevels
    }
    
    static func getLevelState(position: Int, for layer: Int) -> Int {
        var baseLevels: [Int] = [Int](repeatElement(LevelState.locked.rawValue, count: 64))
        
        // Setup basic level states
        baseLevels[0] = LevelState.emitter.rawValue
        let layerBaseLevels: [Int] = Layers.sharedInstance.gameLayers[layer].baseLevels

        for baseLevel in layerBaseLevels {
            baseLevels[baseLevel] = LevelState.base.rawValue
        }
        
        if isKeyPresentInUserDefaults(key: layerStateKeys[layer]) {
            guard let levelArray = UserDefaults.standard.object(forKey: layerStateKeys[layer]) as? [Int] else {
                return baseLevels[position]
            }
            return levelArray[position]
        }
        
        // Initialize default value if key is not yet set (level 0 is complete by default)
        UserDefaults.standard.set(baseLevels, forKey: layerStateKeys[layer])
        return baseLevels[position]
    }
    
    static func getCompletionPercentFromLevelStates(for layer: Int) -> CGFloat {
        if isKeyPresentInUserDefaults(key: layerStateKeys[layer]) {
            guard let levelArray = UserDefaults.standard.object(forKey: layerStateKeys[layer]) as? [Int] else {
                return 0.0
            }
                var completeCount: Int = 0
                for level in levelArray {
                    if level == 1 {
                        completeCount += 1
                    }
                }
            return (CGFloat(completeCount) / CGFloat((Layers.getGameLayers()![layer].gameLevels.count) - 1))
        }
        
        return 0.0
    }
    
    static func checkIfLayerIsLocked(for layer: Int) -> Bool {
        if layer == 0 {
            return false
        }
        
        if getCompletionPercentFromLevelStates(for: (layer-1)) > 0.5 {
            return false
        }
        
        return false
    }
    
    static func updateLevelsWithState(position: Int, newState: LevelState, for layer: Int) {
        var levels: [Int] = getLevelStates(for: layer)
        levels[position] = newState.rawValue
        setLevelStates(levels: levels, for: layer)
    }
    
    static func clearLevelStates(for layer: Int) {
        UserDefaults.standard.set(nil, forKey: layerStateKeys[layer])
    }
    
    static func setCurrentLayer(pos: Int) {
        UserDefaults.standard.set(pos, forKey: currentLayer)
    }
    
    static func getCurrentLayer() -> Int {
        let baseLayer: Int = 0
        
        if isKeyPresentInUserDefaults(key: currentLayer) {
            guard let layer = UserDefaults.standard.object(forKey: currentLayer) as? Int else {
                return baseLayer
            }
            return layer
        }
        
        // Initialize default value to 0 0 if key is not yet set
        UserDefaults.standard.set(0, forKey: currentLayer)
        return baseLayer
    }
    
    static func clearCurrentLayer() {
        UserDefaults.standard.set(nil, forKey: currentLayer)
    }
    
    fileprivate static func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
}
