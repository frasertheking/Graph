//
//  ParticleGeneration.swift
//  Graph
//
//  Created by Fraser King on 2018-01-07.
//  Copyright © 2018 Fraser King. All rights reserved.
//

import Foundation
import SceneKit

public enum ParticleGeneration: Int {
    
    case Trail = 0
    case Smoke
    
    static func createTrail(color: UIColor, geometry: SCNGeometry) -> SCNParticleSystem? {
        guard let particles = SCNParticleSystem(named: "Trail.scnp", inDirectory: nil) else {
            return nil
        }
        
        let trail = particles
        trail.particleColor = color
        trail.emitterShape = geometry
        return trail
    }
    
    static func createSpiral(color: UIColor, geometry: SCNGeometry) -> SCNParticleSystem? {
        guard let particles = SCNParticleSystem(named: "Spiral.scnp", inDirectory: nil) else {
            return nil
        }

        let trail = particles
        trail.particleColor = color
        trail.emitterShape = geometry
        return trail
    }
    
    static func createSmoke(color: UIColor, geometry: SCNGeometry) -> SCNParticleSystem? {
        guard let particles = SCNParticleSystem(named: "Glow.scnp", inDirectory: nil) else {
            return nil
        }
        
        let smoke = particles
        smoke.particleColor = color
        smoke.emitterShape = geometry
        return smoke
    }
    
    static func createExplosion(color: UIColor, geometry: SCNGeometry) -> SCNParticleSystem? {
        guard let particles = SCNParticleSystem(named: "Explode.scnp", inDirectory: nil) else {
            return nil
        }
        
        let explosion = particles
        explosion.particleColor = color
        explosion.emitterShape = geometry
        return explosion
    }
}
