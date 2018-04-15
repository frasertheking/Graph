//
//  UserDefaultsInteractor.swift
//  Graph
//
//  Created by Fraser King on 2018-04-12.
//  Copyright © 2018 Fraser King. All rights reserved.
//

import Foundation

public enum LevelState: Int {
    case base = 0
    case completed
    case locked
    case random
    case emitter
}

struct UserDefaultsInteractor {
    private init() {}
    
    fileprivate static let levelStateKey: String = "levelStates"
    
    fileprivate static func setLevelStates(levels: [Int]) {
        UserDefaults.standard.set(levels, forKey: levelStateKey)
    }
    
    static func getLevelStates() -> [Int] {
        var baseLevels: [Int] = [Int](repeatElement(0, count: 64))
        
        // Setup basic level states
        baseLevels[1] = LevelState.emitter.rawValue
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
