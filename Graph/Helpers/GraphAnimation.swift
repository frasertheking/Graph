//
//  GraphAnimation.swift
//  Graph
//
//  Created by Fraser King on 2018-01-07.
//  Copyright © 2018 Fraser King. All rights reserved.
//

import Foundation
import SceneKit

struct GraphAnimation {

    static func rotateGraphObject(vertexNodes: SCNNode, edgeNodes: SCNNode) {
        let spin = CABasicAnimation(keyPath: "rotation")
        let easeInOut = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        spin.fromValue = NSValue(scnVector4: SCNVector4(x: 0, y: 1, z: 0, w: 0))
        spin.toValue = NSValue(scnVector4: SCNVector4(x: 0, y: 1, z: 0, w: Float(CGFloat(Double.pi*2))))
        spin.duration = 2.25
        spin.repeatCount = 1
        spin.timingFunction = easeInOut
        vertexNodes.addAnimation(spin, forKey: "spin around")
        edgeNodes.addAnimation(spin, forKey: "spin around")
    }
    
    static func scaleGraphObject(vertexNodes: SCNNode, edgeNodes: SCNNode, duration: TimeInterval, toScale: SCNVector4) {
        let scale = CABasicAnimation(keyPath: "scale")
        let easeInOut = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        scale.fromValue = NSValue(scnVector4: SCNVector4(x: 1, y: 1, z: 1, w: 0))
        scale.toValue = NSValue(scnVector4: toScale)
        scale.duration = duration
        scale.repeatCount = 0
        scale.autoreverses = true
        scale.timingFunction = easeInOut
        vertexNodes.addAnimation(scale, forKey: "scale up")
        edgeNodes.addAnimation(scale, forKey: "scale up")
    }
    
    static func explodeGraph(vertexNodes: SCNNode, edgeNodes: SCNNode) {
        let scale = CABasicAnimation(keyPath: "scale")
        let easeInOut = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        scale.fromValue = NSValue(scnVector4: SCNVector4(x: 0, y: 0, z: 0, w: 0))
        scale.toValue = NSValue(scnVector4: SCNVector4(x: 1, y: 1, z: 1, w: 0))
        scale.duration = 0.5
        scale.repeatCount = 0
        scale.autoreverses = false
        scale.timingFunction = easeInOut
        vertexNodes.addAnimation(scale, forKey: "explode")
        edgeNodes.addAnimation(scale, forKey: "explode")
    }
    
    static func implodeGraph(vertexNodes: SCNNode, edgeNodes: SCNNode, clean: @escaping () -> ()) {
        let scale = CABasicAnimation(keyPath: "scale")
        let easeInOut = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        scale.fromValue = NSValue(scnVector4: SCNVector4(x: 1, y: 1, z: 1, w: 0))
        scale.toValue = NSValue(scnVector4: SCNVector4(x: 0, y: 0, z: 0, w: 0))
        scale.duration = 0.5
        scale.repeatCount = 0
        scale.autoreverses = true
        scale.timingFunction = easeInOut
        vertexNodes.addAnimation(scale, forKey: "implode")
        edgeNodes.addAnimation(scale, forKey: "implode")
        
        GraphAnimation.delayWithSeconds(0.5) {
            clean()
        }
    }
    
    static func swellGraphObject(vertexNodes: SCNNode, edgeNodes: SCNNode) {
        GraphAnimation.swellNode(node: vertexNodes)
        GraphAnimation.swellNode(node: edgeNodes)
    }
    
    static func swellNode(node: SCNNode) {
        let scale = CABasicAnimation(keyPath: "scale")
        let easeInOut = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        scale.fromValue = NSValue(scnVector4: SCNVector4(x: 1, y: 1, z: 1, w: 0))
        scale.toValue = NSValue(scnVector4: SCNVector4(x: 1.08, y: 1.08, z: 1.08, w: 0))
        scale.duration = 2
        scale.repeatCount = .infinity
        scale.autoreverses = true
        scale.timingFunction = easeInOut
        node.addAnimation(scale, forKey: "swell")
    }
    
    static func animateInCollectionView(view: UIView, collectionViewBottomConstraint: NSLayoutConstraint) {
        collectionViewBottomConstraint.constant = 16
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            view.layoutIfNeeded()
        }, completion: nil)
    }
    
    static func addPulse(to: UIView) {
        let pulseAnimation:CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 0.75
        pulseAnimation.toValue = NSNumber(value: 1.1)
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .greatestFiniteMagnitude
        to.layer.add(pulseAnimation, forKey: nil)
    }
    
    static func addExplode(to: UIView) {
        let scale = CABasicAnimation(keyPath: "transform.scale")
        let easeInOut = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        scale.toValue = NSNumber(value: 1.25)
        scale.duration = 0.25
        scale.repeatCount = 0
        scale.autoreverses = true
        scale.timingFunction = easeInOut
        to.layer.add(scale, forKey: nil)
    }
    
    static func addShake(to: UIView) {
        let animation = CABasicAnimation(keyPath: "position")
        let easeInOut = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.duration = 0.1
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: to.center.x - 15, y: to.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: to.center.x + 15, y: to.center.y))
        animation.timingFunction = easeInOut
        to.layer.add(animation, forKey: "position")
    }
    
    static func addOpacityPulse(to: CALayer) {
        let pulseAnimation:CABasicAnimation = CABasicAnimation(keyPath: "opacity")
        pulseAnimation.duration = 8
        pulseAnimation.toValue = NSNumber(value: to.opacity + 0.2)
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .greatestFiniteMagnitude
        to.add(pulseAnimation, forKey: nil)
    }
    
    static func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
}


