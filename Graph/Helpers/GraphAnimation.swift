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
    
    static func chunkInGraph(vertexNodes: SCNNode, edgeNodes: SCNNode) {
        let scale = CABasicAnimation(keyPath: "scale")
        let easeInOut = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        scale.fromValue = NSValue(scnVector4: SCNVector4(x: 5, y: 5, z: 5, w: 0))
        scale.toValue = NSValue(scnVector4: SCNVector4(x: 1, y: 1, z: 1, w: 0))
        scale.duration = 0.5
        scale.repeatCount = 0
        scale.autoreverses = false
        scale.timingFunction = easeInOut
        scale.fillMode = kCAFillModeForwards
        scale.isRemovedOnCompletion = false
        vertexNodes.addAnimation(scale, forKey: "explode")
        edgeNodes.addAnimation(scale, forKey: "explode")
    }
    
    static func chunkOutGraph(vertexNodes: SCNNode, edgeNodes: SCNNode, clean: @escaping () -> ()) {
        let scale = CABasicAnimation(keyPath: "position")
        let easeInOut = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        scale.fromValue = NSValue(scnVector4: SCNVector4(x: 0, y: 0, z: 0, w: 0))
        scale.toValue = NSValue(scnVector4: SCNVector4(x: 0, y: 0, z: 35, w: 0))
        scale.duration = 0.5
        scale.repeatCount = 0
        scale.autoreverses = false
        scale.timingFunction = easeInOut
        scale.fillMode = kCAFillModeForwards
        scale.isRemovedOnCompletion = false
        vertexNodes.addAnimation(scale, forKey: "explode")
        edgeNodes.addAnimation(scale, forKey: "explode")
        
        GraphAnimation.delayWithSeconds(1) {
            clean()
        }
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
        scale.fillMode = kCAFillModeForwards
        scale.isRemovedOnCompletion = false
        vertexNodes.addAnimation(scale, forKey: "explode")
        edgeNodes.addAnimation(scale, forKey: "explode")
    }
    
    static func explodeEmitter(emitter: SCNNode) {
        let scale = CABasicAnimation(keyPath: "scale")
        let easeInOut = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        scale.fromValue = NSValue(scnVector4: SCNVector4(x: 0, y: 0, z: 0, w: 0))
        scale.toValue = NSValue(scnVector4: SCNVector4(x: 4, y: 4, z: 4, w: 0))
        scale.duration = 0.5
        scale.repeatCount = 0
        scale.autoreverses = false
        scale.timingFunction = easeInOut
        scale.fillMode = kCAFillModeForwards
        scale.isRemovedOnCompletion = false
        emitter.addAnimation(scale, forKey: "explode")
    }
    
    static func animateFloatView(_ view: UIView?) {
        guard let view = view else { return }
        let oldYCoordinate = view.center.y
        
        UIView.animate(withDuration: 1, animations: {
            view.center.y -= 10
        }, completion: { _ in
            UIView.animate(withDuration: 1, animations: {
                view.center.y = oldYCoordinate
            }, completion: { _ in
                self.animateFloatView(view)
            })
        })
    }
    
    static func emergeGraph(vertexNodes: SCNNode, findNode: SCNNode?) {
        var skipNode: SCNNode? = nil
        
        if let findNode = findNode {
            if let emitter: SCNNode = vertexNodes.findNodeInChildren(node: findNode) {
                emitter.position.z = -50
                emitter.opacity = 0
                let moveAction: SCNAction = SCNAction.move(to: SCNVector3(x: emitter.position.x, y: emitter.position.y, z: 0), duration: 0.75)
                let scaleAction: SCNAction = SCNAction.scale(to: 1, duration: 0.75)
                let fadeAction: SCNAction = SCNAction.fadeOpacity(to: 1, duration: 0.75)
                moveAction.timingMode = .easeInEaseOut
                scaleAction.timingMode = .easeInEaseOut
                fadeAction.timingMode = .easeInEaseOut
                emitter.runAction(moveAction)
                emitter.runAction(fadeAction)
                skipNode = emitter
            }
        }
        
        for node in vertexNodes.childNodes {            
            if node.geometry?.name == skipNode?.geometry?.name {
                continue
            }
            
            node.position.z = -50
            node.opacity = 0
            GraphAnimation.delayWithSeconds(Double.random(min: 0.75, max: 1)) {
                let moveAction: SCNAction = SCNAction.move(to: SCNVector3(x: node.position.x, y: node.position.y, z: 0), duration: 0.75)
                let scaleAction: SCNAction = SCNAction.scale(to: 1, duration: 0.75)
                let fadeAction: SCNAction = SCNAction.fadeOpacity(to: 1, duration: 0.75)
                moveAction.timingMode = .easeInEaseOut
                scaleAction.timingMode = .easeInEaseOut
                fadeAction.timingMode = .easeInEaseOut
                node.runAction(moveAction)
                node.runAction(fadeAction)
            }
        }
    }
    
    static func dissolveGraph(vertexNodes: SCNNode, lingerNode: SCNNode, clean: @escaping () -> ()) {
        let name: String = (lingerNode.geometry?.name)!
        
        GraphAnimation.delayWithSeconds(Double.random(min: 1.5, max: 1.75)) {
            let moveAction: SCNAction = SCNAction.move(to: SCNVector3(x: lingerNode.position.x, y: lingerNode.position.y, z: -50), duration: 0.45)
            let fadeAction: SCNAction = SCNAction.fadeOpacity(to: 0, duration: 0.4)
            moveAction.timingMode = .easeInEaseOut
            fadeAction.timingMode = .easeInEaseOut
            lingerNode.runAction(moveAction)
            lingerNode.runAction(fadeAction)
        }
        
        for node in vertexNodes.childNodes {
            if node.geometry?.name == name {
                continue
            }
            
            GraphAnimation.delayWithSeconds(Double.random(min: 0.4, max: 0.8)) {
                let moveAction: SCNAction = SCNAction.move(to: SCNVector3(x: node.position.x, y: node.position.y, z: -50), duration: 0.45)
                let fadeAction: SCNAction = SCNAction.fadeOpacity(to: 0, duration: 0.4)
                moveAction.timingMode = .easeInEaseOut
                fadeAction.timingMode = .easeInEaseOut
                node.runAction(moveAction)
                node.runAction(fadeAction)
            }
        }
        
        GraphAnimation.delayWithSeconds(2.5) {
            clean()
        }        
    }
    
    static func emergeGraph(edgeNodes: SCNNode) {
        for node in edgeNodes.childNodes {
            node.opacity = 0
            
            GraphAnimation.delayWithSeconds(2) {
                let fadeInAction: SCNAction = SCNAction.fadeIn(duration: 1)
                fadeInAction.timingMode = .easeInEaseOut
                node.runAction(fadeInAction)
            }
        }
    }
    
    static func fadeOutNode(node: SCNNode, duration: TimeInterval) {
        let fadeOutAction: SCNAction = SCNAction.fadeIn(duration: duration)
        fadeOutAction.timingMode = .easeInEaseOut
        node.runAction(fadeOutAction)
    }
    
    static func fadeInNode(node: SCNNode, duration: TimeInterval) {
        let fadeInAction: SCNAction = SCNAction.fadeOpacity(to: 0.8, duration: duration)
        fadeInAction.timingMode = .easeInEaseOut
        node.runAction(fadeInAction)
    }

    static func dissolveGraph(edgeNodes: SCNNode) {
        for node in edgeNodes.childNodes {
            let fadeOutAction: SCNAction = SCNAction.fadeOut(duration: 0.4)
            fadeOutAction.timingMode = .easeInEaseOut
            node.runAction(fadeOutAction)
        }
    }
    
    static func implodeGraph(vertexNodes: SCNNode, edgeNodes: SCNNode, clean: @escaping () -> ()) {
        let scale = CABasicAnimation(keyPath: "scale")
        let easeInOut = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        scale.fromValue = NSValue(scnVector4: SCNVector4(x: 1, y: 1, z: 1, w: 0))
        scale.toValue = NSValue(scnVector4: SCNVector4(x: 0, y: 0, z: 0, w: 0))
        scale.duration = 0.5
        scale.repeatCount = 0
        scale.autoreverses = false
        scale.timingFunction = easeInOut
        scale.fillMode = kCAFillModeForwards
        scale.isRemovedOnCompletion = false
        vertexNodes.addAnimation(scale, forKey: "implode")
        edgeNodes.addAnimation(scale, forKey: "implode")
        
        GraphAnimation.delayWithSeconds(0.5) {
            clean()
        }
    }
    
    static func swellGraphObject(vertexNodes: SCNNode, edgeNodes: SCNNode) {
        GraphAnimation.swellNode(node: vertexNodes, scaleAmount: 1.08, delta: 2)
        GraphAnimation.swellNode(node: edgeNodes, scaleAmount: 1.08, delta: 2)
    }
    
    static func swellNode(node: SCNNode, scaleAmount: Float, delta: Double) {
        let scale = CABasicAnimation(keyPath: "scale")
        let easeInOut = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        scale.fromValue = NSValue(scnVector4: SCNVector4(x: 1, y: 1, z: 1, w: 0))
        scale.toValue = NSValue(scnVector4: SCNVector4(x: scaleAmount, y: scaleAmount, z: scaleAmount, w: 0))
        scale.duration = delta
        scale.repeatCount = .infinity
        scale.autoreverses = true
        scale.timingFunction = easeInOut
        node.addAnimation(scale, forKey: "swell")
    }
    
    static func swellNodeCustom(node: SCNNode, from: Float, scaleAmount: Float, delta: Double) {
        let scale = CABasicAnimation(keyPath: "scale")
        let easeInOut = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        scale.fromValue = NSValue(scnVector4: SCNVector4(x: from, y: from, z: from, w: 0))
        scale.toValue = NSValue(scnVector4: SCNVector4(x: scaleAmount, y: scaleAmount, z: scaleAmount, w: 0))
        scale.duration = delta
        scale.repeatCount = .infinity
        scale.autoreverses = true
        scale.timingFunction = easeInOut
        node.addAnimation(scale, forKey: "swell")
    }
    static func rotateNodeX(node: SCNNode, delta: Double) {
        let spin = CABasicAnimation(keyPath: "rotation")
        spin.fromValue = NSValue(scnVector4: SCNVector4(x: 1, y: 0, z: 0, w: 0))
        spin.toValue = NSValue(scnVector4: SCNVector4(x: 1, y: 0, z: 0, w: Float(CGFloat(Double.pi*2))))
        spin.duration = delta
        spin.repeatCount = .infinity
        spin.autoreverses = false
        spin.fillMode = kCAFillModeForwards
        spin.isRemovedOnCompletion = false
        node.addAnimation(spin, forKey: "spin around")
    }
    
    static func rotateNodeZ(node: SCNNode, delta: Double) {
        let spin = CABasicAnimation(keyPath: "rotation")
        spin.fromValue = NSValue(scnVector4: SCNVector4(x: 0, y: 0, z: 1, w: 0))
        spin.toValue = NSValue(scnVector4: SCNVector4(x: 0, y: 0, z: 1, w: Float(CGFloat(Double.pi*2))))
        spin.duration = delta
        spin.repeatCount = .infinity
        spin.autoreverses = false
        node.addAnimation(spin, forKey: "spin around")
    }
    
    static func animateInCollectionView(view: UIView, collectionViewBottomConstraint: NSLayoutConstraint, completion: @escaping () -> Void) {
        collectionViewBottomConstraint.constant = 16
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            view.layoutIfNeeded()
        }, completion: { (finished) in
            completion()
        })
    }
    
    static func addPulse(to: UIView, duration: TimeInterval) {
        let pulseAnimation:CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = duration
        pulseAnimation.toValue = NSNumber(value: 1.1)
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .greatestFiniteMagnitude
        to.layer.add(pulseAnimation, forKey: nil)
    }
    
    static func addExplode(to: UIView) {
        let scale = CABasicAnimation(keyPath: "transform.scale")
        let easeInOut = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        scale.toValue = NSNumber(value: 1.2)
        scale.duration = 0.2
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


