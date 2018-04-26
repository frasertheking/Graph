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
    var emitterNode: SCNNode!

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
        
        UserDefaultsInteractor.clearLevelSelectPosition()
        
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
        cameraNode.position = SCNVector3(x: 0, y: 0, z: GameConstants.kCameraZ - 5)
        scnScene.rootNode.addChildNode(cameraNode)
    }
    
    @objc func setupLevel() {
        scnView.isUserInteractionEnabled = true
        activeLevel = Levels.createLevel(index: currentLevel)
        scnView.pointOfView?.runAction(SCNAction.move(to: SCNVector3(x: 0, y: 0, z: GameConstants.kCameraZ - 5), duration: 0.5))
        scnView.pointOfView?.runAction(SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 0.5))
        
        createObjects()
        GraphAnimation.explodeGraph(vertexNodes: vertexNodes, edgeNodes: edgeNodes)
        
        GraphAnimation.delayWithSeconds(GameConstants.kMediumTimeDelay) {
            GraphAnimation.swellGraphObject(vertexNodes: self.vertexNodes, edgeNodes: self.edgeNodes)
        }
        
        // Set the levels to the correct position they were last left at
        edgeNodes.position = UserDefaultsInteractor.getLevelSelectPosition()
        vertexNodes.position = UserDefaultsInteractor.getLevelSelectPosition()
        
        // TODO: move this??
        GraphAnimation.delayWithSeconds(0.25) {
            if let trail = ParticleGeneration.createTrail(color: UIColor.red, geometry: self.emitterNode.geometry!) {
                self.emitterNode.removeAllParticleSystems()
                self.emitterNode.addParticleSystem(trail)
            }
        }
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
        
        guard let adjacencyDict = activeLevel?.adjacencyList?.adjacencyDict else {
            return
        }

        edgeArray = []
        
        for (key, value) in adjacencyDict {
            var shapeType: Shape = .Node

            if let shape = getShapeTypeForLevel(level: key.data.uid) {
                shapeType = shape
            }
            
            Shape.spawnShape(type: shapeType, position: key.data.position, color: key.data.color, id: key.data.uid, node: vertexNodes)
            
            if shapeType == .Emitter {
                if let node = vertexNodes.childNodes.last {
                    emitterNode = node
                    GraphAnimation.rotateNode(node: node, delta: 20)
                }
            }
            
            // Create edges
            for edge in value {
                if edgeArray.filter({ el in (el.destination.data.position.equal(b: edge.source.data.position) && el.source.data.position.equal(b: edge.destination.data.position)) }).count == 0 {
                    let node = SCNNode()
                    edgeNodes.addChildNode(node.buildLineInTwoPointsWithRotation(from: edge.source.data.position, to: edge.destination.data.position, radius: Shape.ShapeConstants.cylinderRadius, color: edgeColor))
                    
                    edgeArray.append(edge)
                }
            }
        }
        
        scnScene.rootNode.addChildNode(vertexNodes)
        scnScene.rootNode.addChildNode(edgeNodes)
    }
    
    func getShapeTypeForLevel(level: Int) -> Shape? {
        let levelStates = UserDefaultsInteractor.getLevelStates()
        
        guard let levelType: GraphType = Levels.sharedInstance.gameLevels[level].graphType else {
            return nil
        }
        
        guard let levelState: LevelState = LevelState(rawValue: levelStates[level]) else {
            return nil
        }
        
        if levelState == .emitter {
            return Shape.Emitter
        }
        
        if levelType == .hamiltonian {
            if levelState == .base {
                return Shape.Hamiltonian
            } else if levelState == .completed {
                return Shape.HamiltonianComplete
            } else if levelState == .locked {
                return Shape.HamiltonianLocked
            } else if levelState == .random {
                return Shape.HamiltonianRandom
            }
        } else if levelType == .planar {
            if levelState == .base {
                return Shape.Planar
            } else if levelState == .completed {
                return Shape.PlanarComplete
            } else if levelState == .locked {
                return Shape.PlanarLocked
            } else if levelState == .random {
                return Shape.PlanarRandom
            }
        } else if levelType == .kColor {
            if levelState == .base {
                return Shape.kColor
            } else if levelState == .completed {
                return Shape.kColorComplete
            } else if levelState == .locked {
                return Shape.kColorLocked
            } else if levelState == .random {
                return Shape.kColorRandom
            }
        }
        
        return nil
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
                
                let scaleUpAction = SCNAction.scale(by: GameConstants.kScaleGrow, duration: GameConstants.kVeryShortTimeDelay)
                scaleUpAction.timingMode = .easeInEaseOut
                let scaleDownAction = SCNAction.scale(by: GameConstants.kScaleShrink, duration: GameConstants.kVeryShortTimeDelay)
                scaleDownAction.timingMode = .easeInEaseOut
                
                node.runAction(scaleUpAction) {
                    node.runAction(scaleDownAction) {}
                }
                
                if let explode = ParticleGeneration.createExplosion(color: UIColor.glowColor(), geometry: node.geometry!) {
                    node.removeAllParticleSystems()
                    node.addParticleSystem(explode)
                }
                
                GraphAnimation.delayWithSeconds(0.3) {
                    self.selectedLevel = Int(geoName)!
                    GraphAnimation.implodeGraph(vertexNodes: self.vertexNodes, edgeNodes: self.edgeNodes, clean: self.cleanScene)
                }
            }
        }
    }
    
    func checkIfAvailable(level: Int) -> Bool {
        let levelStates = UserDefaultsInteractor.getLevelStates()
        let levelState = levelStates[level]
        
        if levelState == LevelState.locked.rawValue || levelState == LevelState.emitter.rawValue {
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
            
            UserDefaultsInteractor.setLevelSelectPosition(pos: [edgeNodes.position.x, edgeNodes.position.y])
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
