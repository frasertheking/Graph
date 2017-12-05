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

class GameViewController: UIViewController {

    var scnView: SCNView!
    var scnScene: SCNScene!
    var edgeNodes: SCNNode!
    var edgeArray: [Edge<Node>]!
    var vertexNodes: SCNNode!
    var game = GameHelper.sharedInstance
    let base = SKLabelNode(text: "Not solved")

    // GLOBAL VARS
    var paintColor: UIColor = UIColor.customRed()
    var activeLevel: Level!
    var animating: Bool = false
    
    // UI Elements
    var redButton: UIButton!
    var greenButton: UIButton!
    var blueButton: UIButton!
    
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
        setupSounds()
        
        let overlayScene = SKScene(size: CGSize(width: scnView.frame.size.width, height: scnView.frame.size.height))
        base.position = CGPoint(x: scnView.frame.size.width/2, y: 50)
        overlayScene.addChild(base)
        scnView.overlaySKScene?.isUserInteractionEnabled = true
        scnView.overlaySKScene = overlayScene
        
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
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
    
    func setupLevel() {
        edgeNodes = SCNNode()
        vertexNodes = SCNNode()

        activeLevel = Levels.createLevel(index: 0)
        
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

        let moveAnimation = SCNAction.move(to: SCNVector3Make(0, 0, 25), duration: 2.0)
        moveAnimation.timingMode = .easeInEaseOut
        cameraNode.runAction(moveAnimation)
        
        // @Cleanup: Move together?
        
        rotate(edgeNodes, around: SCNVector3(x: 0, y: 1, z: 0), by: CGFloat(3*Double.pi), duration: 2) {
            print("done")
            self.scnView.allowsCameraControl = true
        }
        
        rotate(vertexNodes, around: SCNVector3(x: 0, y: 1, z: 0), by: CGFloat(3*Double.pi), duration: 2) {
            print("done")
        }

        scale(vertexNodes, size: 2, duration: 0.5) {
            self.scale(self.vertexNodes, size: 0.5, duration: 0.5) {
                print("done")
            }
        }
        
        scale(edgeNodes, size: 2, duration: 0.5) {
            self.scale(self.edgeNodes, size: 0.5, duration: 0.5) {
                print("done")
            }
        }
        
    }
    
    func rotate(_ node: SCNNode, around axis: SCNVector3, by angle: CGFloat, duration: TimeInterval, completionBlock: (()->())?) {
        let rotation = SCNMatrix4MakeRotation(Float(angle), axis.x, axis.y, axis.z)
        let newTransform = SCNMatrix4Mult(node.worldTransform, rotation)
        let easeInOut = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        // Animate the transaction
        SCNTransaction.begin()
        
        // Set the duration and the completion block
        SCNTransaction.animationDuration = duration
        SCNTransaction.completionBlock = completionBlock
        SCNTransaction.animationTimingFunction = easeInOut

        // Set the new transform
        node.transform = newTransform
        
        SCNTransaction.commit()
    }
    
    func scale(_ node: SCNNode, size: Float, duration: TimeInterval, completionBlock: (()->())?) {
        let scale = SCNMatrix4MakeScale(size, size, size)
        let newTransform = SCNMatrix4Mult(node.worldTransform, scale)
        let easeInOut = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        // Animate the transaction
        SCNTransaction.begin()
        // Set the duration and the completion block
        SCNTransaction.animationDuration = duration
        SCNTransaction.completionBlock = completionBlock
        SCNTransaction.animationTimingFunction = easeInOut
        
        // Set the new transform
        node.transform = newTransform
        
        SCNTransaction.commit()
    }
    
    func setupView() {
        scnView = self.view as! SCNView
        scnView.showsStatistics = true
        scnView.allowsCameraControl = false
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
    
    func cleanScene() {
        for node in scnScene.rootNode.childNodes {
            if node.presentation.position.y < -2 {
                node.removeFromParentNode()
            }
        }
    }
    
    func createTrail(color: UIColor, geometry: SCNGeometry) -> SCNParticleSystem {
        let trail = SCNParticleSystem(named: "Trail.scnp", inDirectory: nil)!
        trail.particleColor = color
        trail.emitterShape = geometry
        return trail
    }

    func createSmoke(color: UIColor, geometry: SCNGeometry) -> SCNParticleSystem {
        let smoke = SCNParticleSystem(named: "Smoke.scnp", inDirectory: nil)!
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
            
            let trailEmitter = createTrail(color: paintColor, geometry: geometry)
            node.removeAllParticleSystems()
            node.addParticleSystem(trailEmitter)
            
            activeLevel.adjacencyList = activeLevel.adjacencyList!.updateGraphState(id: geometry.name, color: paintColor)
            //game.playSound(node: scnScene.rootNode, name: "SpawnGood")
        }
        
        updateCorrectEdges()
        
        if activeLevel.adjacencyList!.checkIfSolved() {
            base.text = "Solved"
            
            scale(vertexNodes, size: 1.5, duration: 0.5) {
                self.scale(self.vertexNodes, size: 0.75, duration: 0.5) {
                    print("done")
                }
            }
            
            scale(edgeNodes, size: 1.5, duration: 0.5) {
                self.scale(self.edgeNodes, size: 0.75, duration: 0.5) {
                    print("done")
                }
            }
        } else {
            base.text = "Not solved"
        }
    }
    
    func updateCorrectEdges() {
        for (_, value) in (activeLevel.adjacencyList!.adjacencyDict) {
            for edge in value {
                if edge.source.data.color != edge.destination.data.color &&
                    edge.source.data.color != .white &&
                    edge.destination.data.color != .white {
                    
                    var pos = 0
                    for edgeNode in edgeArray {
                        if edgeNode.source == edge.source && edgeNode.destination == edge.destination {
                            edgeNodes.childNodes[pos].geometry?.firstMaterial?.diffuse.contents = UIColor.white
                            edgeNodes.childNodes[pos].geometry?.firstMaterial?.emission.contents = UIColor.glowColor()
                            let smokeEmitter = createSmoke(color: UIColor.glowColor(), geometry: edgeNodes.childNodes[pos].geometry!)
                            edgeNodes.childNodes[pos].addParticleSystem(smokeEmitter)
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
    
    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        let location = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(location, options: nil)
        
        if hitResults.count > 0 {
            let result = hitResults.first!
            handleTouchFor(node: result.node)
        }
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
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
}

extension GameViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        //spawnShape()
        //game.updateHUD()
    }
}


