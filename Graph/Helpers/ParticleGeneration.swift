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
        
//        let exp = SCNParticleSystem()
//        exp.loops = true
//        exp.particleMass = 1
//        exp.birthRate = 100
//        exp.emissionDuration = 0.5
//        exp.emitterShape = SCNSphere(radius: 0.25)
//        exp.particleLifeSpan = 1
//        exp.particleVelocity = 1.5
//        exp.particleSize = 0.05
//        exp.particleImage = UIImage(named: "CircleParticle")
//        exp.particleColor = UIColor.white
//        exp.isAffectedByPhysicsFields = true
//        return exp
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
