//
//  UserDefaultsInteractor.swift
//  Graph
//
//  Created by Fraser King on 2018-04-12.
//  Copyright © 2018 Fraser King. All rights reserved.
//

import Foundation

struct UserDefaultsInteractor {
    private init() {}
    
    fileprivate static let completedLevelsKey: String = "completedLevels"
    
    fileprivate static func setCompletedLevels(completedLevels: [Int]) {
        UserDefaults.standard.set(completedLevels, forKey: completedLevelsKey)
    }
    
    static func getCompletedLevels() -> [Int] {
        if isKeyPresentInUserDefaults(key: completedLevelsKey) {
            guard let levelArray = UserDefaults.standard.object(forKey: completedLevelsKey) as? [Int] else {
                return [0]
            }
            return levelArray
        }
        
        // Initialize default value if key is not yet set (level 0 is complete by default)
        UserDefaults.standard.set([0], forKey: completedLevelsKey)
        return [0]
    }
    
    static func updateCompletedLevelsWithLevel(level: Int) {
        let completedLevels: [Int] = getCompletedLevels()
        
        if !completedLevels.contains(level) {
            var newLevels: [Int] = completedLevels
            newLevels.append(level)
            setCompletedLevels(completedLevels: newLevels)
        }
    }
    
    static func clearCompletedLevels() {
        UserDefaults.standard.set(nil, forKey: completedLevelsKey)
    }
    
    fileprivate static func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
}
