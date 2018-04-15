//
//  LevelSelectViewController.swift
//  Graph
//
//  Created by Fraser King on 2017-11-10.
//  Copyright © 2017 Fraser King. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import SpriteKit
import Pastel
import M13Checkbox
import CountdownLabel

class LevelSelectViewController: UIViewController {

    // SCENE VARS
    @IBOutlet var scnView: SCNView!
    var scnScene: SCNScene!
    var edgeNodes: SCNNode!
    var edgeArray: [Edge<Node>]!
    var vertexNodes: SCNNode!
    var lightNodes: SCNNode!
    var colorSelectNodes: SCNNode!

    // GLOBAL VARS
    var activeLevel: Level?
    var currentLevel: Int = 0
    var selectedLevel: Int = 1
    var h: Float = 1
    var axisPanGestureRecognizer: UIPanGestureRecognizer!

    // UI
    @IBOutlet var skView: SKView!
    
    // CAMERA VARS
    var cameraOrbit: SCNNode!
    var cameraNode: SCNNode!
    let camera = SCNCamera()
    
    struct GameConstants {
        static let kCameraZ: Float = 25
        static let kScaleShrink: CGFloat = 0.8
        static let kScaleGrow: CGFloat = 1.25
        static let kPanTranslationScaleFactor: CGFloat = 25
        static let kPlanarMaxMagnitude: Float = 7
        
        // Timing Constants
        static let kVeryShortTimeDelay: Double = 0.1
        static let kShortTimeDelay: Double = 0.3
        static let kMediumTimeDelay: Double = 0.55
        static let kLongTimeDelay: Double = 1.05
        static let kVeryLongDelay: Double = 1.5
        
        // CollectionView Constants
        static let kPaintCellReuseIdentifier: String = "cell"
        static let kPaintCellWidthHeight: Int = 60
        static let kPaintCellPadding: Int = 10
        static let kCollectionViewBottomOffsetShowing: CGFloat = -115
        static let kCollectionViewBottomOffsetHidden: CGFloat = 16
        static let kDefaultCellsInSection: Int = 3
    }

    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupScene()
        setupCamera()
        
        setupLevel()
        setupInteractions()
    }
    
    func setupView() {
        guard let sceneView = scnView else {
            return
        }
        
        axisPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGesture(gestureRecognize:)))
        scnView.addGestureRecognizer(axisPanGestureRecognizer)
        
        scnView = sceneView
        scnView.showsStatistics = false
        scnView.allowsCameraControl = false
        scnView.autoenablesDefaultLighting = true
        scnView.antialiasingMode = .multisampling4X
        scnView.delegate = self
        scnView.isPlaying = true
    }
    
    func setupScene() {
        scnScene = SCNScene()
        scnView.scene = scnScene
        scnView.backgroundColor = UIColor.clear
        scnScene.background.contents = UIColor.clear
        
        let gradientLayer:CAGradientLayer = CAGradientLayer()
        gradientLayer.frame.size = self.view.frame.size
        gradientLayer.colors = [UIColor.white.cgColor, UIColor.clear] //Use diffrent colors
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
        gradientLayer.opacity = 0.5
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: GameConstants.kCameraZ)
        scnScene.rootNode.addChildNode(cameraNode)
    }
    
    @objc func setupLevel() {
        scnView.isUserInteractionEnabled = true
        activeLevel = Levels.createLevel(index: currentLevel)
        scnView.pointOfView?.runAction(SCNAction.move(to: SCNVector3(x: 0, y: 0, z: GameConstants.kCameraZ), duration: 0.5))
        scnView.pointOfView?.runAction(SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 0.5))
        
        createObjects()
        GraphAnimation.explodeGraph(vertexNodes: vertexNodes, edgeNodes: edgeNodes)
    }
    
    func setupInteractions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        UIColor.setupBackgrounds(view: view, skView: skView)
    }
    
    func createObjects() {
        edgeNodes = SCNNode()
        vertexNodes = SCNNode()
        let edgeColor = UIColor.defaultVertexColor()
        let levelStates = UserDefaultsInteractor.getLevelStates()
        
        guard let adjacencyDict = activeLevel?.adjacencyList?.adjacencyDict else {
            return
        }

        edgeArray = []
        
        for (key, value) in adjacencyDict {
            var nodeType: Shapes = .Hexagon
            if levelStates[key.data.uid] == LevelState.completed.rawValue {
                nodeType = .HexagonComplete
            } else if levelStates[key.data.uid] == LevelState.locked.rawValue {
                nodeType = .HexagonLocked
            }
            
            Shapes.spawnShape(type: nodeType, position: key.data.position, color: key.data.color, id: key.data.uid, node: vertexNodes)
            
            // Create edges
            for edge in value {
                if edgeArray.filter({ el in (el.destination.data.position.equal(b: edge.source.data.position) && el.source.data.position.equal(b: edge.destination.data.position)) }).count == 0 {
                    let node = SCNNode()
                    edgeNodes.addChildNode(node.buildLineInTwoPointsWithRotation(from: edge.source.data.position, to: edge.destination.data.position, radius: Shapes.ShapeConstants.cylinderRadius, color: edgeColor))
                    
                    edgeArray.append(edge)
                }
            }
        }
        
        scnScene.rootNode.addChildNode(vertexNodes)
        scnScene.rootNode.addChildNode(edgeNodes)
    }
    
    func handleTouchFor(node: SCNNode) {
        
        guard let geometry = node.geometry else {
            return
        }

        guard let geoName = geometry.name else {
            return
        }
//
//        guard let graphType: GraphType = activeLevel?.graphType else {
//            return
//        }
//
//        guard let isMirror: Bool = activeLevel?.isMirror else {
//            return
//        }
        
        // First check for legal moves - return early if illegal
        if geoName != "edge" {
            if checkIfAvailable(level: Int(geoName)!) {
                selectedLevel = Int(geoName)!
                GraphAnimation.implodeGraph(vertexNodes: vertexNodes, edgeNodes: edgeNodes, clean: cleanScene)
            }
        }
    }
    
    func checkIfAvailable(level: Int) -> Bool {
        let levelStates = UserDefaultsInteractor.getLevelStates()
        let levelState = levelStates[level]
        
        if levelState == LevelState.locked.rawValue {
            return false
        }
        
        return true
    }
    
    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        let location = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(location, options: nil)
        
        if hitResults.count > 0 {
            if let result = hitResults.first {
                handleTouchFor(node: result.node)
            }
        }
    }
    
    @objc func cleanScene() {
        vertexNodes.removeFromParentNode()
        edgeNodes.removeFromParentNode()
        simPath.removeAll()
        
        performSegue(withIdentifier: "gameSegue", sender: nil)
    }
    
    @objc func panGesture(gestureRecognize: UIPanGestureRecognizer){
        if gestureRecognize.state == .changed {
            guard let recognizerView = gestureRecognize.view else {
                return
            }
            
            let translation = gestureRecognize.translation(in: recognizerView)
            
            vertexNodes.position = SCNVector3(x: vertexNodes.position.x + Float(translation.x / GameConstants.kPanTranslationScaleFactor),
                                                    y: vertexNodes.position.y - Float(translation.y / GameConstants.kPanTranslationScaleFactor),
                                                    z: vertexNodes.position.z)
        
            edgeNodes.position = SCNVector3(x: edgeNodes.position.x + Float(translation.x / GameConstants.kPanTranslationScaleFactor),
                                              y: edgeNodes.position.y - Float(translation.y / GameConstants.kPanTranslationScaleFactor),
                                              z: edgeNodes.position.z)
            
            gestureRecognize.setTranslation(CGPoint.zero, in: recognizerView)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gameSegue" {
            let viewController: GameViewController = segue.destination as! GameViewController
            viewController.currentLevel = selectedLevel
        }
    }
    
    @IBAction func unwindToLevelSelect(segue: UIStoryboardSegue) {
        GraphAnimation.delayWithSeconds(GameConstants.kShortTimeDelay) {
            self.setupLevel()
            GraphAnimation.explodeGraph(vertexNodes: self.vertexNodes, edgeNodes: self.edgeNodes)
        }
    }
}

// Draw Loop
extension LevelSelectViewController: SCNSceneRendererDelegate {
//    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
//
//    }
}
