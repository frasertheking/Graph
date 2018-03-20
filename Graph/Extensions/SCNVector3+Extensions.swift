//
//  SCNVector3+Extensions.swift
//  Graph
//
//  Created by Fraser King on 2017-11-11.
//  Copyright © 2017 Fraser King. All rights reserved.
//

import Foundation
import SceneKit

extension SCNVector3 {
    
    static func subtract(a: SCNVector3, b: SCNVector3) -> SCNVector3 {
        return SCNVector3(x: a.x - b.x, y: a.y - b.y, z: a.z - b.z)
    }
    
    static func cross(a: SCNVector3, b: SCNVector3) -> SCNVector3 {
        return SCNVector3(x: (a.y*b.z - a.z*b.y), y: (a.z*b.x - a.x*b.z), z: (a.x*b.y - a.y*b.x))
    }
    
    static func dot(a: SCNVector3, b: SCNVector3) -> Double {
        return Double(a.x*b.x + a.y*b.y + a.z*b.z)
    }
    
    func equal(b: SCNVector3) -> Bool {
        return self.x == b.x && self.y == b.y && self.z == b.z
    }
    
    func length() -> Double {
        return Double(sqrtf(x*x + y*y + z*z))
    }
    
    func distance(receiver:SCNVector3) -> Float {
        let xd = receiver.x - self.x
        let yd = receiver.y - self.y
        let zd = receiver.z - self.z
        let distance = Float(sqrt(xd * xd + yd * yd + zd * zd))

        if (distance < 0) {
            return (distance * -1)
        } else {
            return (distance)
        }
    }
    
    func normalizeVector() -> SCNVector3 {
        let length = sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
        if length == 0 {
            return SCNVector3(0.0, 0.0, 0.0)
        }
        
        return SCNVector3( self.x / length, self.y / length, self.z / length)
    }
    
//    func rotate(vector: SCNVector4, angle: Float) -> SCNVector3 {
//        let rotationMatrix = SCNMatrix4MakeRotation(angle, 1, 0, 0)
//        return vector * rotationMatrix
//    }
}

// MARK: Int Extension

public extension Int {
    
    /// Returns a random Int point number between 0 and Int.max.
    public static var random: Int {
        return Int.random(n: Int.max)
    }
    
    /// Random integer between 0 and n-1.
    ///
    /// - Parameter n:  Interval max
    /// - Returns:      Returns a random Int point number between 0 and n max
    public static func random(n: Int) -> Int {
        return Int(arc4random_uniform(UInt32(n)))
    }
    
    ///  Random integer between min and max
    ///
    /// - Parameters:
    ///   - min:    Interval minimun
    ///   - max:    Interval max
    /// - Returns:  Returns a random Int point number between 0 and n max
    public static func random(min: Int, max: Int) -> Int {
        return Int.random(n: max - min + 1) + min
        
    }
}

// MARK: Double Extension

public extension Double {
    
    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    public static var random: Double {
        return Double(arc4random()) / 0xFFFFFFFF
    }
    
    /// Random double between 0 and n-1.
    ///
    /// - Parameter n:  Interval max
    /// - Returns:      Returns a random double point number between 0 and n max
    public static func random(min: Double, max: Double) -> Double {
        return Double.random * (max - min) + min
    }
}

// MARK: Float Extension

public extension Float {
    
    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    public static var random: Float {
        return Float(arc4random()) / 0xFFFFFFFF
    }
    
    /// Random float between 0 and n-1.
    ///
    /// - Parameter n:  Interval max
    /// - Returns:      Returns a random float point number between 0 and n max
    public static func random(min: Float, max: Float) -> Float {
        return Float.random * (max - min) + min
    }
}

// MARK: CGFloat Extension

public extension CGFloat {
    
    /// Randomly returns either 1.0 or -1.0.
    public static var randomSign: CGFloat {
        return (arc4random_uniform(2) == 0) ? 1.0 : -1.0
    }
    
    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    public static var random: CGFloat {
        return CGFloat(Float.random)
    }
    
    /// Random CGFloat between 0 and n-1.
    ///
    /// - Parameter n:  Interval max
    /// - Returns:      Returns a random CGFloat point number between 0 and n max
    public static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat.random * (max - min) + min
    }
}
