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
    let base = SKLabelNode(text: "Not solved")

    // GLOBAL VARS
    var paintColor: UIColor = UIColor.red
    var activeLevel: Level!
    
    // UI Elements
    var redButton: UIButton!
    var greenButton: UIButton!
    var blueButton: UIButton!
    
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
        redButton.backgroundColor = UIColor.red
        redButton.layer.borderColor = UIColor.black.cgColor
        redButton.layer.borderWidth = 1
        self.view.addSubview(redButton)
        redButton.addTarget(self, action: #selector(redButtonPress), for: .touchUpInside)
        
        greenButton = UIButton(frame: CGRect(x: 150, y: 50, width: 60, height: 20))
        greenButton.backgroundColor = UIColor.green
        greenButton.layer.borderColor = UIColor.black.cgColor
        self.view.addSubview(greenButton)
        greenButton.addTarget(self, action: #selector(greenButtonPress), for: .touchUpInside)
        
        blueButton = UIButton(frame: CGRect(x: 250, y: 50, width: 60, height: 20))
        blueButton.backgroundColor = UIColor.blue
        blueButton.layer.borderColor = UIColor.black.cgColor
        self.view.addSubview(blueButton)
        blueButton.addTarget(self, action: #selector(blueButtonPress), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
    }
    
    @objc func redButtonPress() {
        paintColor = UIColor.red
        redButton.layer.borderWidth = 1
        greenButton.layer.borderWidth = 0
        blueButton.layer.borderWidth = 0
    }
    
    @objc func greenButtonPress() {
        paintColor = UIColor.green
        redButton.layer.borderWidth = 0
        greenButton.layer.borderWidth = 1
        blueButton.layer.borderWidth = 0
    }
    
    @objc func blueButtonPress() {
        paintColor = UIColor.blue
        redButton.layer.borderWidth = 0
        greenButton.layer.borderWidth = 0
        blueButton.layer.borderWidth = 1
    }
    
    func setupLevel() {
        activeLevel = Levels.createLevel(index: 0)
        
        guard let adjacencyDict = activeLevel.adjacencyList?.adjacencyDict else {
            return
        }
        
        for (key, value) in adjacencyDict {
            // Create nodes
            Shapes.spawnShape(type: .Sphere, position: key.data.position, color: key.data.color, id: key.data.uid, scnScene: scnScene)
            
            // Create edges
            for edge in value {
                let node = SCNNode()
                scnScene.rootNode.addChildNode(node.buildLineInTwoPointsWithRotation(from: edge.source.data.position, to: edge.destination.data.position, radius: 0.1, color: .white))
            }
        }
    }
    
    func setupView() {
        scnView = self.view as! SCNView
        scnView.showsStatistics = false
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
    
    func handleTouchFor(node: SCNNode) {
        
        guard let geometry = node.geometry else {
            return
        }
        
        if geometry.name != "edge" {
            geometry.materials.first?.diffuse.contents = paintColor
            activeLevel.adjacencyList = activeLevel.adjacencyList!.updateGraphState(id: geometry.name, color: paintColor)
            game.playSound(node: scnScene.rootNode, name: "SpawnGood")
        }
        
        if activeLevel.adjacencyList!.checkIfSolved() {
            base.text = "Solved"
        } else {
            base.text = "Not solved"
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


