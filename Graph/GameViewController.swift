//
//  GameViewController.swift
//  Graph
//
//  Created by Fraser King on 2017-11-10.
//  Copyright © 2017 Fraser King. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import SpriteKit

class GameViewController: UIViewController, UIPopoverPresentationControllerDelegate {

    // SCENE VARS
    var scnView: SCNView!
    var scnScene: SCNScene!
    var edgeNodes: SCNNode!
    var edgeArray: [Edge<Node>]!
    var vertexNodes: SCNNode!
    var game = GameHelper.sharedInstance

    // GLOBAL VARS
    var paintColor: UIColor = UIColor.customRed()
    var activeLevel: Level!
    var animating: Bool = false
    var currentLevel: Int = 0
    
    // UI Elements
    var redButton: UIButton!
    var greenButton: UIButton!
    var blueButton: UIButton!
    var colorSelectionButton: UIButton!
    
    // CAMERA VARS
    var cameraOrbit: SCNNode!
    var cameraNode: SCNNode!
    let camera = SCNCamera()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupScene()
        setupCamera()
        setupLevel()
        setupInteractions()
    }
    
    func setupView() {
        guard let sceneView = self.view as? SCNView else {
            return
        }
        
        scnView = sceneView
        scnView.showsStatistics = false
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = true
        scnView.antialiasingMode = .multisampling4X
        scnView.delegate = self
        scnView.isPlaying = true
    }
    
    func setupScene() {
        scnScene = SCNScene()
        scnView.scene = scnScene
        scnScene.background.contents = "background"
    }
    
    func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 25)
        scnScene.rootNode.addChildNode(cameraNode)
    }
    
    func setupLevel() {
        createObjects()
        setupSounds()
        explodeGraph()
        Timer.scheduledTimer(timeInterval: TimeInterval(0.5), target: self, selector: #selector(rotateGraphObject), userInfo: nil, repeats: false)
        Timer.scheduledTimer(timeInterval: TimeInterval(0.5), target: self, selector: #selector(swellGraphObject), userInfo: nil, repeats: false)
        Timer.scheduledTimer(timeInterval: TimeInterval(1.0), target: self, selector: #selector(scaleGraphObject), userInfo: nil, repeats: false)
    }
    
    func setupInteractions() {
        let width = scnView.frame.size.width
        let height = scnView.frame.size.height
        
        redButton = UIButton(frame: CGRect(x: 50, y: 50, width: 60, height: 20))
        redButton.backgroundColor = UIColor.customRed()
        redButton.layer.borderColor = UIColor.white.cgColor
        redButton.layer.borderWidth = 2
        self.scnView.addSubview(redButton)
        redButton.addTarget(self, action: #selector(redButtonPress), for: .touchUpInside)
        
        greenButton = UIButton(frame: CGRect(x: 150, y: 50, width: 60, height: 20))
        greenButton.backgroundColor = UIColor.customGreen()
        greenButton.layer.borderColor = UIColor.white.cgColor
        self.scnView.addSubview(greenButton)
        greenButton.addTarget(self, action: #selector(greenButtonPress), for: .touchUpInside)
        
        blueButton = UIButton(frame: CGRect(x: 250, y: 50, width: 60, height: 20))
        blueButton.backgroundColor = UIColor.customBlue()
        blueButton.layer.borderColor = UIColor.white.cgColor
        self.scnView.addSubview(blueButton)
        blueButton.addTarget(self, action: #selector(blueButtonPress), for: .touchUpInside)
        
        colorSelectionButton = UIButton(frame: CGRect(x: 16 , y: height - 86, width: width - 32, height: 60))
        colorSelectionButton.backgroundColor = UIColor.customRed()
        colorSelectionButton.setTitle("Change Color", for: .normal)
        colorSelectionButton.layer.cornerRadius = 8
        self.scnView.addSubview(colorSelectionButton)
        colorSelectionButton.addTarget(self, action: #selector(colorSelectionPress(_:)), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
    }
    
    func createObjects() {
        edgeNodes = SCNNode()
        vertexNodes = SCNNode()
        
        vertexNodes.pivot = SCNMatrix4MakeRotation(Float(CGFloat(Double.pi / 2)), 0, 1, 0)
        edgeNodes.pivot = SCNMatrix4MakeRotation(Float(CGFloat(Double.pi / 2)), 0, 1, 0)
        
        activeLevel = Levels.createLevel(index: currentLevel)
        
        guard let adjacencyDict = activeLevel.adjacencyList?.adjacencyDict else {
            return
        }
        
        edgeArray = []
        
        for (key, value) in adjacencyDict {
            // Create nodes
            Shapes.spawnShape(type: .Custom, position: key.data.position, color: key.data.color, id: key.data.uid, node: vertexNodes)
            
            // Create edges
            for edge in value {
                if edgeArray.filter({ el in (el.destination.data.position.equal(b: edge.source.data.position) && el.source.data.position.equal(b: edge.destination.data.position)) }).count == 0 {
                    let node = SCNNode()
                    edgeNodes.addChildNode(node.buildLineInTwoPointsWithRotation(from: edge.source.data.position, to: edge.destination.data.position, radius: 0.1, color: .black))
                    
                    edgeArray.append(edge)
                }
                
            }
        }
        
        scnScene.rootNode.addChildNode(vertexNodes)
        scnScene.rootNode.addChildNode(edgeNodes)
    }
    
    func createTrail(color: UIColor, geometry: SCNGeometry) -> SCNParticleSystem? {
        guard let particles = SCNParticleSystem(named: "Trail.scnp", inDirectory: nil) else {
            return nil
        }
        
        let trail = particles
        trail.particleColor = color
        trail.emitterShape = geometry
        return trail
    }

    func createSmoke(color: UIColor, geometry: SCNGeometry) -> SCNParticleSystem? {
        guard let particles = SCNParticleSystem(named: "Smoke.scnp", inDirectory: nil) else {
            return nil
        }

        let smoke = particles
        smoke.particleColor = color
        smoke.emitterShape = geometry
        return smoke
    }
    
    func handleTouchFor(node: SCNNode) {
        
        guard let geometry = node.geometry else {
            return
        }
        
        if geometry.name != "edge" {
                        
            let scaleUpAction = SCNAction.scale(by: 1.25, duration: 0.1)
            scaleUpAction.timingMode = .easeInEaseOut
            let scaleDownAction = SCNAction.scale(by: 0.8, duration: 0.1)
            scaleDownAction.timingMode = .easeInEaseOut
            
            if !animating {
                self.animating = true
                node.runAction(scaleUpAction) {
                    node.runAction(scaleDownAction) {
                        self.animating = false
                    }
                }
            }
            
            geometry.materials.first?.diffuse.contents = paintColor
            geometry.materials.first?.emission.contents = UIColor.black
            
            if let trailEmitter = createTrail(color: paintColor, geometry: geometry) {
                node.removeAllParticleSystems()
                node.addParticleSystem(trailEmitter)
            }
            
            if let _ = activeLevel.adjacencyList {
                activeLevel.adjacencyList = activeLevel.adjacencyList!.updateGraphState(id: geometry.name, color: paintColor)
            }
            
            //game.playSound(node: scnScene.rootNode, name: "SpawnGood")
        }
        
        updateCorrectEdges()
        
        if let _ = activeLevel.adjacencyList {
            if activeLevel.adjacencyList!.checkIfSolved() {
                self.implodeGraph()
            }
        }
    }
    
    func updateCorrectEdges() {
        guard let adjacencyList = activeLevel.adjacencyList else {
            return
        }
        
        for (_, value) in (adjacencyList.adjacencyDict) {
            for edge in value {
                if edge.source.data.color != edge.destination.data.color &&
                    edge.source.data.color != .white &&
                    edge.destination.data.color != .white {
                    
                    var pos = 0
                    for edgeNode in edgeArray {
                        if edgeNode.source == edge.source && edgeNode.destination == edge.destination {
                            edgeNodes.childNodes[pos].geometry?.firstMaterial?.diffuse.contents = UIColor.white
                            edgeNodes.childNodes[pos].geometry?.firstMaterial?.emission.contents = UIColor.glowColor()
                            
                            guard let edgeGeometry = edgeNodes.childNodes[pos].geometry else {
                                continue
                            }
                            
                            if let smokeEmitter = createSmoke(color: UIColor.glowColor(), geometry: edgeGeometry) {
                                edgeNodes.childNodes[pos].addParticleSystem(smokeEmitter)
                            }
                        }
                        pos += 1
                    }
                } else {
                    var pos = 0
                    for edgeNode in edgeArray {
                        if edgeNode.source == edge.source && edgeNode.destination == edge.destination {
                            edgeNodes.childNodes[pos].geometry?.firstMaterial?.diffuse.contents = UIColor.black
                            edgeNodes.childNodes[pos].geometry?.firstMaterial?.emission.contents = UIColor.black
                            edgeNodes.childNodes[pos].removeAllParticleSystems()
                        }
                        pos += 1
                    }
                }
            }
        }
    }
    
    func setupSounds() {
        game.loadSound(name: "ExplodeGood",
                       fileNamed: "Graph.scnassets/Sounds/ExplodeGood.wav")
        game.loadSound(name: "SpawnGood",
                       fileNamed: "Graph.scnassets/Sounds/SpawnGood.wav")
        game.loadSound(name: "ExplodeBad",
                       fileNamed: "Graph.scnassets/Sounds/ExplodeBad.wav")
        game.loadSound(name: "SpawnBad",
                       fileNamed: "Graph.scnassets/Sounds/SpawnBad.wav")
        game.loadSound(name: "GameOver",
                       fileNamed: "Graph.scnassets/Sounds/GameOver.wav")
    }
    
    // Animations
    @objc func rotateGraphObject() {
        let spin = CABasicAnimation(keyPath: "rotation")
        let easeInOut = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        spin.fromValue = NSValue(scnVector4: SCNVector4(x: 0, y: 1, z: 0, w: 0))
        spin.toValue = NSValue(scnVector4: SCNVector4(x: 0, y: 1, z: 0, w: Float(CGFloat(Double.pi*2))))
        spin.duration = 2
        spin.repeatCount = 1
        spin.timingFunction = easeInOut
        vertexNodes.addAnimation(spin, forKey: "spin around")
        edgeNodes.addAnimation(spin, forKey: "spin around")
    }
    
    @objc func scaleGraphObject() {
        let scale = CABasicAnimation(keyPath: "scale")
        let easeInOut = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        scale.fromValue = NSValue(scnVector4: SCNVector4(x: 1, y: 1, z: 1, w: 0))
        scale.toValue = NSValue(scnVector4: SCNVector4(x: 2, y: 2, z: 2, w: 0))
        scale.duration = 0.5
        scale.repeatCount = 0
        scale.autoreverses = true
        scale.timingFunction = easeInOut
        vertexNodes.addAnimation(scale, forKey: "scale up")
        edgeNodes.addAnimation(scale, forKey: "scale up")
    }
    
    @objc func explodeGraph() {
        let scale = CABasicAnimation(keyPath: "scale")
        let easeInOut = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        scale.fromValue = NSValue(scnVector4: SCNVector4(x: 0, y: 0, z: 0, w: 0))
        scale.toValue = NSValue(scnVector4: SCNVector4(x: 1, y: 1, z: 1, w: 0))
        scale.duration = 0.5
        scale.repeatCount = 0
        scale.autoreverses = true
        scale.timingFunction = easeInOut
        vertexNodes.addAnimation(scale, forKey: "explode")
        edgeNodes.addAnimation(scale, forKey: "explode")
    }
    
    @objc func implodeGraph() {
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
        
        Timer.scheduledTimer(timeInterval: TimeInterval(0.5), target: self, selector: #selector(cleanScene), userInfo: nil, repeats: false)
    }
    
    @objc func swellGraphObject() {
        let scale = CABasicAnimation(keyPath: "scale")
        let easeInOut = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        scale.fromValue = NSValue(scnVector4: SCNVector4(x: 1, y: 1, z: 1, w: 0))
        scale.toValue = NSValue(scnVector4: SCNVector4(x: 1.05, y: 1.05, z: 1.05, w: 0))
        scale.duration = 2
        scale.repeatCount = .infinity
        scale.autoreverses = true
        scale.timingFunction = easeInOut
        vertexNodes.addAnimation(scale, forKey: "swell")
        edgeNodes.addAnimation(scale, forKey: "swell")
    }
    
    // Actions
    @objc func colorSelectionPress(_ sender: UIButton) {
        
    }
    
    func updateButtonWithColor(color: UIColor) {
        colorSelectionButton.backgroundColor = color
        paintColor = color
    }
    
    @objc func redButtonPress() {
        DispatchQueue.main.async {
            self.paintColor = UIColor.customRed()
            self.redButton.layer.borderWidth = 2
            self.greenButton.layer.borderWidth = 0
            self.blueButton.layer.borderWidth = 0
        }
    }
    
    @objc func greenButtonPress() {
        DispatchQueue.main.async {
            self.paintColor = UIColor.customGreen()
            self.redButton.layer.borderWidth = 0
            self.greenButton.layer.borderWidth = 2
            self.blueButton.layer.borderWidth = 0
        }
    }
    
    @objc func blueButtonPress() {
        DispatchQueue.main.async {
            self.paintColor = UIColor.customBlue()
            self.redButton.layer.borderWidth = 0
            self.greenButton.layer.borderWidth = 0
            self.blueButton.layer.borderWidth = 2
        }
    }
    
    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        let location = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(location, options: nil)
        
        if hitResults.count > 0 {
            let result = hitResults.first!
            handleTouchFor(node: result.node)
        }
    }
    
    @objc func cleanScene() {
        self.vertexNodes.removeFromParentNode()
        self.edgeNodes.removeFromParentNode()
        
        currentLevel += 1
        setupLevel()
    }
}

extension GameViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        //spawnShape()
        //game.updateHUD()
    }
}


