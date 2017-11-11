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
    var cameraNode: SCNNode!
    var game = GameHelper.sharedInstance
    let asd = SKSpriteNode(imageNamed:"storm-small")
    let base = SKLabelNode(text: "Hello world")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupScene()
        setupCamera()
        
        // @cleanup: formalize shape setup
        spawnShape(type: .Cylinder, position: SCNVector3(x: -2.0, y: 0.0, z: 2.0), color: UIColor.white, rotation: SCNVector4(x: 0, y: 0, z: 0, w: 0))
        spawnShape(type: .Sphere, position: SCNVector3(x: -2.0, y: 2.0, z: 2.0), color: UIColor.blue, rotation: SCNVector4(x: 0, y: 0, z: 0, w: 0))
        spawnShape(type: .Sphere, position: SCNVector3(x: -2.0, y: -2.0, z: 2.0), color: UIColor.blue, rotation: SCNVector4(x: 0, y: 0, z: 0, w: 0))
        
        spawnShape(type: .Cylinder, position: SCNVector3(x: 2.0, y: 0.0, z: 2.0), color: UIColor.white, rotation: SCNVector4(x: 0, y: 0, z: 0, w: 0))
        spawnShape(type: .Sphere, position: SCNVector3(x: 2.0, y: 2.0, z: 2.0), color: UIColor.blue, rotation: SCNVector4(x: 0, y: 0, z: 0, w: 0))
        spawnShape(type: .Sphere, position: SCNVector3(x: 2.0, y: -2.0, z: 2.0), color: UIColor.blue, rotation: SCNVector4(x: 0, y: 0, z: 0, w: 0))
        
        spawnShape(type: .Cylinder, position: SCNVector3(x: 0.0, y: -2.0, z: 2.0), color: UIColor.white, rotation: SCNVector4(x: 0, y: 0, z: 1, w: Float(Double.pi/2)))
        spawnShape(type: .Cylinder, position: SCNVector3(x: 0.0, y: 2.0, z: 2.0), color: UIColor.white, rotation: SCNVector4(x: 0, y: 0, z: 1, w: Float(Double.pi/2)))

        spawnShape(type: .Cylinder, position: SCNVector3(x: -2.0, y: 0.0, z: -2.0), color: UIColor.white, rotation: SCNVector4(x: 0, y: 0, z: 0, w: 0))
        spawnShape(type: .Sphere, position: SCNVector3(x: -2.0, y: 2.0, z: -2.0), color: UIColor.blue, rotation: SCNVector4(x: 0, y: 0, z: 0, w: 0))
        spawnShape(type: .Sphere, position: SCNVector3(x: -2.0, y: -2.0, z: -2.0), color: UIColor.blue, rotation: SCNVector4(x: 0, y: 0, z: 0, w: 0))
        
        spawnShape(type: .Cylinder, position: SCNVector3(x: 2.0, y: 0.0, z: -2.0), color: UIColor.white, rotation: SCNVector4(x: 0, y: 0, z: 0, w: 0))
        spawnShape(type: .Sphere, position: SCNVector3(x: 2.0, y: 2.0, z: -2.0), color: UIColor.blue, rotation: SCNVector4(x: 0, y: 0, z: 0, w: 0))
        spawnShape(type: .Sphere, position: SCNVector3(x: 2.0, y: -2.0, z: -2.0), color: UIColor.blue, rotation: SCNVector4(x: 0, y: 0, z: 0, w: 0))
        
        spawnShape(type: .Cylinder, position: SCNVector3(x: 0.0, y: -2.0, z: -2.0), color: UIColor.white, rotation: SCNVector4(x: 0, y: 0, z: 1, w: Float(Double.pi/2)))
        spawnShape(type: .Cylinder, position: SCNVector3(x: 0.0, y: 2.0, z: -2.0), color: UIColor.white, rotation: SCNVector4(x: 0, y: 0, z: 1, w: Float(Double.pi/2)))
        
        spawnShape(type: .Cylinder, position: SCNVector3(x: 2.0, y: 2.0, z: 0.0), color: UIColor.white, rotation: SCNVector4(x: 1, y: 0, z: 0, w: Float(Double.pi/2)))
        spawnShape(type: .Cylinder, position: SCNVector3(x: 2.0, y: -2.0, z: 0.0), color: UIColor.white, rotation: SCNVector4(x: 1, y: 0, z: 0, w: Float(Double.pi/2)))
        spawnShape(type: .Cylinder, position: SCNVector3(x: -2.0, y: 2.0, z: 0.0), color: UIColor.white, rotation: SCNVector4(x: 1, y: 0, z: 0, w: Float(Double.pi/2)))
        spawnShape(type: .Cylinder, position: SCNVector3(x: -2.0, y: -2.0, z: 0.0), color: UIColor.white, rotation: SCNVector4(x: 1, y: 0, z: 0, w: Float(Double.pi/2)))

        setupHUD()
        setupSounds()
        
        let overlayScene = SKScene(size: CGSize(width: scnView.frame.size.width, height: scnView.frame.size.height))
        base.position = CGPoint(x: scnView.frame.size.width/2, y: 50)
        //base.size = CGSize(width: 25, height: 25)
        overlayScene.addChild(base)
        scnView.overlaySKScene?.isUserInteractionEnabled = true
        scnView.overlaySKScene = overlayScene
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
    }
    
    func setupView() {
        scnView = self.view as! SCNView
        //scnView.showsStatistics = true
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = true
        
        scnView.delegate = self
        scnView.isPlaying = true
    }
    
    func setupScene() {
        scnScene = SCNScene()
        scnView.scene = scnScene
        
        scnScene.background.contents = "Graph.scnassets/Textures/Background_Diffuse.png"
    }
    
    func setupHUD() {
        game.hudNode.position = SCNVector3(x: 0.0, y: 4.0, z: 0.0)
        scnScene.rootNode.addChildNode(game.hudNode)
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
    
    func spawnShape(type: ShapeType, position: SCNVector3, color: UIColor, rotation: SCNVector4) {
        var geometry:SCNGeometry

        switch type {
        case .Box:
            geometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
        case .Sphere:
            geometry = SCNSphere(radius: 0.5)
        case .Pyramid:
            geometry = SCNPyramid(width: 1.0, height: 1.0, length: 1.0)
        case .Torus:
            geometry = SCNTorus(ringRadius: 0.5, pipeRadius: 0.25)
        case .Capsule:
            geometry = SCNCapsule(capRadius: 0.3, height: 2.5)
        case .Cylinder:
            geometry = SCNCylinder(radius: 0.2, height: 3.1)
        case .Cone:
            geometry = SCNCone(topRadius: 0.25, bottomRadius: 0.5, height: 1.0)
        case .Tube:
            geometry = SCNTube(innerRadius: 0.25, outerRadius: 0.5, height: 1.0)
        }
        
        geometry.materials.first?.diffuse.contents = color
        
        let geometryNode = SCNNode(geometry: geometry)
        geometryNode.position = position
        geometryNode.rotation = rotation
        scnScene.rootNode.addChildNode(geometryNode)
    }
    
    func handleTouchFor(node: SCNNode) {
        node.geometry?.materials.first?.diffuse.contents = UIColor.red
        
        //game.playSound(node: scnScene.rootNode, name: "SpawnGood")
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
        return true
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
