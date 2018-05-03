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
import ChameleonFramework

class LevelSelectViewController: UIViewController {

    // SCENE VARS
    @IBOutlet var scnView: SCNView!
    var scnScene: SCNScene!
    var edgeNodes: SCNNode!
    var edgeArray: [Edge<Node>]!
    var vertexNodes: SCNNode!
    var lightNodes: SCNNode!
    var colorSelectNodes: SCNNode!
    var emitterNodes: [SCNNode]!
    var simNodes: [SCNNode]!

    // GLOBAL VARS
    var activeLevel: Level?
    var currentLevel: Int = 0
    var selectedLevel: Int = 1
    var h: Float = 1
    var axisPanGestureRecognizer: UIPanGestureRecognizer!
    var zoomPinchGestureRecognizer: UIPinchGestureRecognizer!
    var resetTapGestureRecognizer: UITapGestureRecognizer!
    var previousDirection: String = ""
    
    // LANDING SCREEN VARS
    var currentlyAtLanding: Bool = true
    var landingEmitter: SCNNode!
    var oldPrimaryColor: UIColor = RandomFlatColor()
    var oldSecondaryColor: UIColor = RandomFlatColor()

    // UI
    @IBOutlet var skView: SKView!
    
    // CAMERA VARS
    var cameraOrbit: SCNNode!
    var cameraNode: SCNNode!
    let camera = SCNCamera()
    
    struct GameConstants {
        static let kCameraZ: Float = 20
        static let kScaleShrink: CGFloat = 0.8
        static let kScaleGrow: CGFloat = 1.25
        static let kPanTranslationScaleFactor: CGFloat = 25
        static let kPanVelocityFactor: CGFloat = 40
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
        UserDefaultsInteractor.clearZoomFactor()
        //UserDefaultsInteractor.clearLevelStates()
        
        setupView()
        setupScene()
        setupCamera()
        
        if !currentlyAtLanding {
            setupLevelSelect()
            setupInteractions()
        } else {
            setupLanding()
        }
    }
    
    func setupView() {
        guard let sceneView = scnView else {
            return
        }
        
        axisPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGesture(gestureRecognizer:)))
        zoomPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchGesture(gestureRecognizer:)))
        resetTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGesture(gestureRecognizer:)))
        resetTapGestureRecognizer.numberOfTapsRequired = 2

        scnView = sceneView
        scnView.showsStatistics = false
        scnView.allowsCameraControl = currentlyAtLanding ? true : false
        scnView.autoenablesDefaultLighting = true
        scnView.antialiasingMode = .multisampling4X
        scnView.delegate = self
        scnView.isPlaying = true
        scnView.preferredFramesPerSecond = 60
    }
    
    func setupScene() {
        scnScene = SCNScene()
        scnView.scene = scnScene
        scnView.backgroundColor = UIColor.clear
        scnScene.background.contents = UIColor.clear
        simNodes = []
        emitterNodes = []
        
        let gradientLayer:CAGradientLayer = CAGradientLayer()
        gradientLayer.frame.size = self.view.frame.size
        gradientLayer.colors = [UIColor.white.cgColor, UIColor.clear] //Use diffrent colors
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
        gradientLayer.opacity = 0.5
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        UIColor.setupBackgrounds(view: view, skView: skView)
    }
    
    func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: UserDefaultsInteractor.getZoomFactor())
        scnScene.rootNode.addChildNode(cameraNode)
    }
    
    @objc func setupLevelSelect() {
        activeLevel = Levels.createLevel(index: 0)
        scnView.pointOfView?.runAction(SCNAction.move(to: SCNVector3(x: 0, y: 0, z: UserDefaultsInteractor.getZoomFactor()), duration: 0.5))
        scnView.pointOfView?.runAction(SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 0.5))
        
        createObjects()
        GraphAnimation.emergeGraph(vertexNodes: vertexNodes)
        GraphAnimation.emergeGraph(edgeNodes: edgeNodes)
        
        GraphAnimation.delayWithSeconds(GameConstants.kMediumTimeDelay) {
            GraphAnimation.swellGraphObject(vertexNodes: self.vertexNodes, edgeNodes: self.edgeNodes)
        }
        
        // Set the levels to the correct position they were last left at
        edgeNodes.position = UserDefaultsInteractor.getLevelSelectPosition()
        vertexNodes.position = UserDefaultsInteractor.getLevelSelectPosition()
        
        // TODO: move this??
        GraphAnimation.delayWithSeconds(0.75) {
            for node in self.emitterNodes {
                if let trail = ParticleGeneration.createTrail(color: UIColor.white, geometry: node.geometry!) {
                    node.removeAllParticleSystems()
                    node.addParticleSystem(trail)
                }
            }
            
            for node in self.simNodes {
                if let spiral = ParticleGeneration.createSpiral(color: self.getColorForLevelState(level: Int((node.geometry?.name)!)), geometry: node.geometry!) {
                    node.removeAllParticleSystems()
                    node.addParticleSystem(spiral)
                }
            }
        }
    }
    
    func setupLanding() {
        landingEmitter = SCNNode()
        
        Shape.spawnShape(type: .Emitter,
                         position: SCNVector3(x: 0, y: 0, z: 0),
                         color: UIColor.cyan,
                         id: -1,
                         node: landingEmitter)
        
        landingEmitter.scale = SCNVector3(x: 4, y: 4, z: 4)
        GraphAnimation.swellEmitterNode(node: landingEmitter, scaleAmount: 4.25, delta: 1)
        GraphAnimation.rotateNodeX(node: landingEmitter, delta: 20)
        
        scnScene.rootNode.addChildNode(landingEmitter)
        
        runNodeColorAnimations(node: landingEmitter, oldColor: oldPrimaryColor, material: landingEmitter.childNodes[0].geometry?.firstMaterial, duration: 2)
        runNodeColorAnimations(node: landingEmitter, oldColor: oldSecondaryColor, material: landingEmitter.childNodes[0].geometry?.materials[1], duration: 3)
    }
    
    func runNodeColorAnimations(node: SCNNode, oldColor: UIColor, material: SCNMaterial?, duration: TimeInterval) {
        let newColor: UIColor = RandomFlatColor()
        
        if let trail1 = ParticleGeneration.createTrail(color: oldColor, geometry: self.landingEmitter.childNodes[0].geometry!) {
            if let trail2 = ParticleGeneration.createTrail(color: newColor, geometry: self.landingEmitter.childNodes[0].geometry!) {
                self.landingEmitter.removeAllParticleSystems()
                self.landingEmitter.addParticleSystem(trail1)
                self.landingEmitter.addParticleSystem(trail2)
            }
        }
        
        let changeColor = SCNAction.customAction(duration: duration) { (node, elapsedTime) -> () in
            let percentage = elapsedTime / CGFloat(duration)
            material?.diffuse.contents = UIColor.aniColor(from: oldColor, to: newColor, percentage: percentage)
        }
        
        node.runAction(changeColor) {
            self.runNodeColorAnimations(node: node, oldColor: newColor, material: material, duration: duration)
        }
    }
    
    func setupInteractions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        scnView.addGestureRecognizer(axisPanGestureRecognizer)
        scnView.addGestureRecognizer(zoomPinchGestureRecognizer)
        scnView.addGestureRecognizer(resetTapGestureRecognizer)
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
            var shapeType: Shape = .Node

            if let shape = getShapeTypeForLevel(level: key.data.uid) {
                shapeType = shape
            }
            
            Shape.spawnShape(type: shapeType,
                             position: key.data.position,
                             color: getColorForLevelState(level: key.data.uid),
                             id: key.data.uid,
                             node: vertexNodes)
            
            if shapeType == .Emitter {
                if let node = vertexNodes.childNodes.last {
                    emitterNodes.append(node)
                    GraphAnimation.rotateNodeX(node: node, delta: 20)
                }
            } else if shapeType == .Spiral {
                if let node = vertexNodes.childNodes.last {
                    simNodes.append(node)
                    GraphAnimation.rotateNodeZ(node: node, delta: 5)
                }
            }
            
            // Create edges
            for edge in value {
                if edgeArray.filter({ el in (el.destination.data.position.equal(b: edge.source.data.position) && el.source.data.position.equal(b: edge.destination.data.position)) }).count == 0 {
                    
                    let node = SCNNode()
                    edgeNodes.addChildNode(node.buildLineInTwoPointsWithRotation(from: edge.source.data.position, to: edge.destination.data.position, radius: Shape.ShapeConstants.cylinderRadius, color: edgeColor))
                    
                    if let levelStateSource: LevelState = LevelState(rawValue: levelStates[edge.source.data.uid]) {
                        if let levelStateDestination: LevelState = LevelState(rawValue: levelStates[edge.destination.data.uid]) {
                            if levelStateSource == LevelState.emitter || levelStateDestination == LevelState.emitter ||
                               levelStateSource == LevelState.completed || levelStateDestination == LevelState.completed {
                                node.geometry?.firstMaterial?.diffuse.contents = UIColor.white
                                node.geometry?.firstMaterial?.emission.contents = UIColor.goldColor()
                            }
                        }
                    }
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
            } else if levelState == .timed {
                return Shape.HamiltonianTimed
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
            } else if levelState == .timed {
                return Shape.PlanarTimed
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
            } else if levelState == .timed {
                return Shape.kColorTimed
            }
        } else if levelType == .sim {
            return Shape.Spiral
        }
        
        return nil
    }
    
    func getColorForLevelState(level: Int?) -> UIColor {
        guard let level = level else {
            return .black
        }
        
        let levelStates = UserDefaultsInteractor.getLevelStates()

        guard let levelState: LevelState = LevelState(rawValue: levelStates[level]) else {
            return .black
        }
        
        if levelState == .base {
            return .black
        } else if levelState == .completed {
            return .customGreen()
        } else if levelState == .locked {
            return .customBlue()
        } else if levelState == .random {
            return .customRed()
        } else if levelState == .timed {
            return .orange
        }
        
        return .black
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
                    GraphAnimation.dissolveGraph(vertexNodes: self.vertexNodes, clean: self.cleanSceneAndSegue)
                    GraphAnimation.dissolveGraph(edgeNodes: self.edgeNodes)
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
        
        var isAvailable = false
        for edge in edgeArray {
            if edge.source.data.uid == level {
                if levelStates[edge.destination.data.uid] == LevelState.completed.rawValue ||
                   levelStates[edge.destination.data.uid] == LevelState.emitter.rawValue {
                    isAvailable = true
                }
            } else if edge.destination.data.uid == level {
                if levelStates[edge.source.data.uid] == LevelState.completed.rawValue ||
                   levelStates[edge.source.data.uid] == LevelState.emitter.rawValue {
                    isAvailable = true
                }
            }
        }
                
        return isAvailable
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
    
    @objc func cleanSceneAndSegue() {
        GraphAnimation.delayWithSeconds(0.25) {
            self.cleanScene()
            self.performSegue(withIdentifier: "gameSegue", sender: nil)
        }
    }
    
    @objc func cleanScene() {
        vertexNodes.removeFromParentNode()
        edgeNodes.removeFromParentNode()
        simPath.removeAll()
        
        scnView.removeGestureRecognizer(axisPanGestureRecognizer)
        scnView.removeGestureRecognizer(zoomPinchGestureRecognizer)
        scnView.removeGestureRecognizer(resetTapGestureRecognizer)
    }
    
    @objc func panGesture(gestureRecognizer: UIPanGestureRecognizer) {
        guard let recognizerView = gestureRecognizer.view else {
            return
        }
        
        let translation = gestureRecognizer.translation(in: recognizerView)
        let velocity = gestureRecognizer.velocity(in: recognizerView)

        if gestureRecognizer.state == .began {
            vertexNodes.removeAllActions()
            edgeNodes.removeAllActions()
        } else if gestureRecognizer.state == .changed {
            vertexNodes.position = SCNVector3(x: vertexNodes.position.x + Float(translation.x / GameConstants.kPanTranslationScaleFactor),
                                                    y: vertexNodes.position.y - Float(translation.y / GameConstants.kPanTranslationScaleFactor),
                                                    z: vertexNodes.position.z)
            
            edgeNodes.position = SCNVector3(x: edgeNodes.position.x + Float(translation.x / GameConstants.kPanTranslationScaleFactor),
                                              y: edgeNodes.position.y - Float(translation.y / GameConstants.kPanTranslationScaleFactor),
                                              z: edgeNodes.position.z)
            
            UserDefaultsInteractor.setLevelSelectPosition(pos: [edgeNodes.position.x, edgeNodes.position.y])
            gestureRecognizer.setTranslation(CGPoint.zero, in: recognizerView)
            
            var directionX: CGFloat = 0
            var directionY: CGFloat = 0
            
            if abs(velocity.x) > 50 && velocity.x > 0 {
                directionX = 1
            }
            if abs(velocity.y) > 50 && velocity.y > 0 {
                directionY = 1
            }
            
            if abs(velocity.x) > 50 && velocity.x < 0 {
                directionX = -1
            }
            if abs(velocity.y) > 50 && velocity.y < 0 {
                directionY = -1
            }
            
            if abs(velocity.x) > abs(velocity.y) {
                if previousDirection == "y" && abs(velocity.x) > 100 {
                    previousDirection = "x"
                    directionY = 0
                } else if previousDirection == "" || previousDirection == "x" {
                    previousDirection = "x"
                    directionY = 0
                }
            } else {
                if previousDirection == "x" && abs(velocity.y) > 100 {
                    previousDirection = "y"
                    directionX = 0
                } else if previousDirection == "" || previousDirection == "y" {
                    previousDirection = "y"
                    directionX = 0
                }
            }
            
            let zoomFactor: CGFloat = 2*(CGFloat(44 - cameraNode.position.z))
            let rotateAction: SCNAction = SCNAction.rotateTo(x: directionY * CGFloat.pi/zoomFactor, y: directionX * CGFloat.pi/zoomFactor, z: 0, duration: 0.2)
            vertexNodes.runAction(rotateAction)
            edgeNodes.runAction(rotateAction)
        } else if gestureRecognizer.state == .ended {
            if abs(velocity.x) > 200 || abs(velocity.y) > 200 {
                let newX: Float = vertexNodes.position.x + (Float(velocity.x*0.4)) / Float(GameConstants.kPanVelocityFactor)
                let newY: Float = vertexNodes.position.y - (Float(velocity.y*0.4)) / Float(GameConstants.kPanVelocityFactor)
                
                let newPosition: SCNVector3 = SCNVector3(x: newX, y: newY, z: vertexNodes.position.z)
                let moveAction = SCNAction.move(to: newPosition, duration: 0.4)
                moveAction.timingMode = .easeOut
                
                vertexNodes.runAction(moveAction)
                edgeNodes.runAction(moveAction)
                
                UserDefaultsInteractor.setLevelSelectPosition(pos: [newX, newY])
            }
            
            let rotateAction: SCNAction = SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 0.4)
            vertexNodes.runAction(rotateAction)
            edgeNodes.runAction(rotateAction)
            previousDirection = ""
        }
    }
    
    @objc func pinchGesture(gestureRecognizer: UIPinchGestureRecognizer) { guard gestureRecognizer.view != nil else { return }
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            if abs(1 - gestureRecognizer.scale) > 0.001 {
                if gestureRecognizer.scale > 1 {
                    if cameraNode.position.z > 14 {
                        cameraNode.position = SCNVector3(x: cameraNode.position.x, y: cameraNode.position.y, z: (cameraNode.position.z - 0.5))
                    }
                } else if cameraNode.position.z < 36 {
                    cameraNode.position = SCNVector3(x: cameraNode.position.x, y: cameraNode.position.y, z: (cameraNode.position.z + 0.5))
                }
                UserDefaultsInteractor.setZoomFactor(pos: cameraNode.position.z)
            }
            gestureRecognizer.scale = 1.0
        }
    }
    
    @objc func tapGesture(gestureRecognizer: UITapGestureRecognizer) { guard gestureRecognizer.view != nil else { return }
        vertexNodes.removeAllActions()
        edgeNodes.removeAllActions()
        
        let rotateAction: SCNAction = SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 0.4)
        let moveAction: SCNAction = SCNAction.move(to: SCNVector3(x: 0, y: 0, z: 0), duration: 0.4)
        let zoomAction: SCNAction = SCNAction.move(to: SCNVector3(x: 0, y: 0, z: GameConstants.kCameraZ), duration: 0.4)
        
        vertexNodes.runAction(rotateAction)
        vertexNodes.runAction(moveAction)
        edgeNodes.runAction(rotateAction)
        edgeNodes.runAction(moveAction)
        cameraNode.runAction(zoomAction)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gameSegue" {
            let viewController: GameViewController = segue.destination as! GameViewController
            viewController.currentLevel = selectedLevel
        }
    }
    
    @IBAction func unwindToLevelSelect(segue: UIStoryboardSegue) {
        GraphAnimation.delayWithSeconds(GameConstants.kShortTimeDelay) {
            self.setupLevelSelect()
        }
    }
}

// Draw Loop
extension LevelSelectViewController: SCNSceneRendererDelegate {
//    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
//
//    }
}
