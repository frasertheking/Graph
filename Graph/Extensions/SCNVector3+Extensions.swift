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
}
