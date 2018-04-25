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
    case question
    case emitter
}

struct UserDefaultsInteractor {
    private init() {}
    
    fileprivate static let levelStateKey: String = "levelStates"
    fileprivate static let levelSelectPosition: String = "levelPosition"

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
    
    // Level States Interaction
    fileprivate static func setLevelStates(levels: [Int]) {
        UserDefaults.standard.set(levels, forKey: levelStateKey)
    }
    
    static func getLevelStates() -> [Int] {
        var baseLevels: [Int] = [Int](repeatElement(0, count: 64))
        
        // Setup basic level states
        baseLevels[1] = LevelState.emitter.rawValue
        baseLevels[2] = LevelState.question.rawValue
        baseLevels[3] = LevelState.locked.rawValue
        
        if isKeyPresentInUserDefaults(key: levelStateKey) {
            guard let levelArray = UserDefaults.standard.object(forKey: levelStateKey) as? [Int] else {
                return baseLevels
            }
            return levelArray
        }
        
        // Initialize default value if key is not yet set (level 0 is complete by default)
        UserDefaults.standard.set(baseLevels, forKey: levelStateKey)
        return baseLevels
    }
    
    static func updateLevelsWithState(position: Int, newState: LevelState) {
        var levels: [Int] = getLevelStates()
        levels[position] = newState.rawValue
        setLevelStates(levels: levels)
    }
    
    static func clearLevelStates() {
        UserDefaults.standard.set(nil, forKey: levelStateKey)
    }
    
    fileprivate static func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
}
