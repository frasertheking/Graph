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
    var gridLines: SCNNode!
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
    var landingPanGestureRecognizer: UIPanGestureRecognizer!
    var previousDirection: String = ""
    var showingModalView: Bool = false
    
    // LANDING SCREEN VARS
    @IBOutlet var playButton: UIButton!
    @IBOutlet var settingsButton: UIButton!
    @IBOutlet var playButtonBackgroundView: UIVisualEffectView!
    @IBOutlet var settingsButtonBackgroundView: UIView!
    @IBOutlet var settingsButtonBorderView: UIView!
    @IBOutlet var settingsButtonBorderBackgroundView: UIView!
    @IBOutlet var playButtonBackgroundViewTopLayoutConstraint: NSLayoutConstraint!
    var currentlyAtLanding: Bool = true
    var landingEmitter: SCNNode!
    var landingTitle: SCNNode!
    var emitter1: SCNParticleSystem?
    var emitter2: SCNParticleSystem?
    var continueColorCycle: Bool = true

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
        
        settingsButtonBackgroundView.alpha = 0
        settingsButton.isUserInteractionEnabled = false
        let maskView2 = UIView(frame: self.settingsButtonBackgroundView.bounds)
        maskView2.backgroundColor = .clear
        
        let settingsMask = UIImageView(image: UIImage(named: "settings"))
        settingsMask.frame = self.settingsButtonBackgroundView.bounds
        
        maskView2.addSubview(settingsMask)
        self.settingsButtonBackgroundView.backgroundColor = .clear
        self.settingsButtonBackgroundView.mask = maskView2
        
        // BORDER
        settingsButtonBorderView.alpha = 0
        let maskView3 = UIView(frame: self.settingsButtonBorderView.bounds)
        maskView3.backgroundColor = .clear
        
        let settingsBorderMask = UIImageView(image: UIImage(named: "settings_border"))
        settingsBorderMask.frame = self.settingsButtonBorderView.bounds
        
        maskView3.addSubview(settingsBorderMask)
        self.settingsButtonBorderView.backgroundColor = .clear
        self.settingsButtonBorderView.mask = maskView3
        UIColor.insertModalButtonGradient(for: self.settingsButtonBorderBackgroundView)

        if !currentlyAtLanding {
            setupLevelSelect()
            setupInteractions()
        } else {
            
            self.playButtonBackgroundView.alpha = 0
            self.playButton.alpha = 0
            
            GraphAnimation.delayWithSeconds(1) {
                self.setupLanding()
                
                let maskView = UIView(frame: self.playButtonBackgroundView.bounds)
                maskView.backgroundColor = .clear
                maskView.layer.borderWidth = 3
                maskView.layer.borderColor = UIColor.black.cgColor
                maskView.layer.cornerRadius = 40

                let labelMask = UILabel(frame: self.playButtonBackgroundView.bounds)
                labelMask.text = "START"
                labelMask.textAlignment = .center
                labelMask.font = UIFont.systemFont(ofSize: 50, weight: .semibold)
                maskView.addSubview(labelMask)
                self.playButtonBackgroundView.contentView.mask = maskView
                
                UIColor.insertButtonGradient(for: self.playButtonBackgroundView.contentView)
                self.playButtonBackgroundView.addParallaxToView(amount: 25)
                self.playButton.addParallaxToView(amount: 25)
                
                GraphAnimation.delayWithSeconds(0.75) {
                    self.playButtonBackgroundViewTopLayoutConstraint.constant = CGFloat(1/Float.pi * Float(self.view.frame.size.height))
                    GraphAnimation.addPulse(to: self.playButtonBackgroundView, duration: 2)
                    GraphAnimation.addPulse(to: self.playButton, duration: 2)
                    
                    UIView.animate(withDuration: 2, animations: {
                        self.view.layoutSubviews()
                        self.playButtonBackgroundView.alpha = 1
                        self.playButton.alpha = 1
                    })
                }
            }
        }
    }
    
    func setupView() {
        guard let sceneView = scnView else {
            return
        }
        
        axisPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGesture(gestureRecognizer:)))
        landingPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(landingPanGesture(gesture:)))
        zoomPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchGesture(gestureRecognizer:)))
        resetTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGesture(gestureRecognizer:)))
        resetTapGestureRecognizer.numberOfTapsRequired = 2

        scnView = sceneView
        scnView.showsStatistics = false
        scnView.allowsCameraControl = false
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
        view.removeGestureRecognizer(self.landingPanGestureRecognizer)
        view.isUserInteractionEnabled = true
        
        // TODO MOVE THIS
        UIView.animate(withDuration: 1) {
            self.settingsButtonBackgroundView.alpha = 1
            self.settingsButtonBorderView.alpha = 1
        }
        settingsButton.isUserInteractionEnabled = true
        
        scnView.pointOfView?.runAction(SCNAction.move(to: SCNVector3(x: -UserDefaultsInteractor.getLevelSelectPosition().x, y: -UserDefaultsInteractor.getLevelSelectPosition().y, z: UserDefaultsInteractor.getZoomFactor()), duration: 0))
        activeLevel = Levels.createLevel(index: 0)
        
        createObjects()
        setupGrid()
        GraphAnimation.emergeGraph(vertexNodes: vertexNodes)
        GraphAnimation.emergeGraph(edgeNodes: edgeNodes)
        GraphAnimation.emergeGraph(edgeNodes: gridLines)
        
        GraphAnimation.delayWithSeconds(1.5) {
            GraphAnimation.swellGraphObject(vertexNodes: self.vertexNodes, edgeNodes: self.edgeNodes)
        }
        
        // TODO: move this??
        GraphAnimation.delayWithSeconds(1.5) {
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
            GraphAnimation.rotateNodeX(node: self.landingEmitter.childNodes[0], delta: 20)
            self.skView.isPaused = false
            self.setupInteractions()
        }
    }
    
    func setupLanding() {
        landingEmitter = SCNNode()
        landingTitle = SCNNode()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        Shape.spawnShape(type: .Emitter,
                         position: SCNVector3(x: 0, y: -0.35, z: 0),
                         color: UIColor.cyan,
                         id: -1,
                         node: landingEmitter)
        
        Shape.spawnShape(type: .Title,
                         position: SCNVector3(x: 0, y: 3.75, z: 0),
                         color: UIColor.white,
                         id: -2,
                         node: landingTitle)
        
        scnScene.rootNode.addChildNode(landingEmitter)
        scnScene.rootNode.addChildNode(landingTitle)
        
        var rotateAction: SCNAction = SCNAction.rotateTo(x: -CGFloat(Double.pi/2), y: 0, z: 0, duration: 0)
        self.landingTitle.runAction(rotateAction)
        self.landingTitle.scale = SCNVector3(x: 0, y: 0, z: 0)
        
        GraphAnimation.explodeEmitter(emitter: landingEmitter)
        GraphAnimation.rotateNodeX(node: self.landingEmitter.childNodes[0], delta: 20)
        
        let seedColor1: UIColor = RandomFlatColorWithShade(.light)
        let seedColor2: UIColor = RandomFlatColorWithShade(.light)
        
        self.runNodeColorAnimations(node: self.landingEmitter, oldColor: seedColor1, material: self.landingEmitter.childNodes[0].geometry?.firstMaterial, id: "color_change_1", duration: 2)
        self.runNodeColorAnimations(node: self.landingEmitter, oldColor: seedColor2, material: self.landingEmitter.childNodes[0].geometry?.materials[1], id: "color_change_2", duration: 2)

        GraphAnimation.delayWithSeconds(0.5) {
            self.landingTitle.scale = SCNVector3(x: 2, y: 2, z: 2)
            rotateAction = SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 0.75)
            rotateAction.timingMode = .easeInEaseOut
            self.landingTitle.runAction(rotateAction)
            
            GraphAnimation.swellNodeCustom(node: self.landingEmitter, from: 4.0, scaleAmount: 4.2, delta: 1)
            GraphAnimation.swellNodeCustom(node: self.landingTitle, from: 2, scaleAmount: 2.2, delta: 2)
            
            if let firstEmitter = ParticleGeneration.createEmitter(color: seedColor1, geometry: self.landingEmitter.childNodes[0].geometry!) {
                if let secondEmitter = ParticleGeneration.createEmitter(color: seedColor2, geometry: self.landingEmitter.childNodes[0].geometry!) {
                    self.landingEmitter.removeAllParticleSystems()
                    
                    self.emitter1 = firstEmitter
                    self.emitter2 = secondEmitter
                    
                    self.landingEmitter.childNodes[0].addParticleSystem(self.emitter1!)
                    self.landingEmitter.childNodes[0].addParticleSystem(self.emitter2!)
                }
            }
            
            GraphAnimation.delayWithSeconds(0.75, completion: {
                let rotateAction: SCNAction = SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 0.2)
                rotateAction.timingMode = .easeInEaseOut
                self.landingTitle.runAction(rotateAction)
            })
            
        }
        
        scnView.addGestureRecognizer(landingPanGestureRecognizer)
    }
    
    func runNodeColorAnimations(node: SCNNode, oldColor: UIColor, material: SCNMaterial?, id: String, duration: TimeInterval) {
        let newColor: UIColor = RandomFlatColorWithShade(.light)
        
        emitter1?.particleColor = oldColor
        emitter2?.particleColor = newColor
        
        let changeColor = SCNAction.customAction(duration: duration) { (node, elapsedTime) -> () in
            let percentage = elapsedTime / CGFloat(duration)
            material?.diffuse.contents = UIColor.aniColor(from: oldColor, to: newColor, percentage: percentage)
        }
        
        node.runAction(changeColor, forKey: id) {
            self.runNodeColorAnimations(node: node, oldColor: newColor, material: material, id: id, duration: duration)
        }
    }
    
    func runFinalColorAnimation(node: SCNNode, oldColor: UIColor, newColor: UIColor, material: SCNMaterial?, duration: TimeInterval) {
        let changeColor = SCNAction.customAction(duration: duration) { (node, elapsedTime) -> () in
            let percentage = elapsedTime / CGFloat(duration)
            material?.diffuse.contents = UIColor.aniColor(from: oldColor, to: newColor, percentage: percentage)
        }
        
        node.runAction(changeColor)
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
            
            if shapeType == .Emitter && self.currentlyAtLanding {
                continue
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
    
    func setupGrid() {
        gridLines = SCNNode()
        
        for y in -25...25 {
            let node = SCNNode()
            gridLines.addChildNode(node.buildLineInTwoPointsWithRotation(from: SCNVector3(x: -25, y: Float(y), z: 0), to: SCNVector3(x: 25, y: Float(y), z: 0), radius: 0.01, color: .black))
        }
        
        for x in -25...25 {
            let node = SCNNode()
            gridLines.addChildNode(node.buildLineInTwoPointsWithRotation(from: SCNVector3(x: Float(x), y: -25, z: 0), to: SCNVector3(x: Float(x), y: 25, z: 0), radius: 0.01, color: .black))
        }
        
        for x in -25...25 {
            for y in -25...25 {
                let node = Shape.getSphereNode()
                node.position = SCNVector3(x: Float(x), y: Float(y), z: 0)
                gridLines.addChildNode(node)
                
            }
        }
        
        scnScene.rootNode.addChildNode(gridLines)
        gridLines.opacity = 0.05
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
        
        if currentlyAtLanding {
            if geoName == "\(-1)" {
                if let explode = ParticleGeneration.createExplosion(color: UIColor.glowColor(), geometry: node.geometry!) {
                    node.addParticleSystem(explode)
                }
            }
        } else if geoName != "edge" && geoName != "\(-1)" {
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
                
                moveToNode(node: node, zoom: true)
                view.isUserInteractionEnabled = false
                
                GraphAnimation.delayWithSeconds(0.4) {
                    UserDefaultsInteractor.setLevelSelectPosition(pos: [-node.position.x, -node.position.y])
                    self.selectedLevel = Int(geoName)!
                    GraphAnimation.dissolveGraph(vertexNodes: self.vertexNodes, lingerNode: node, clean: self.cleanSceneAndSegue)
                    GraphAnimation.dissolveGraph(edgeNodes: self.edgeNodes)
                    GraphAnimation.dissolveGraph(edgeNodes: self.gridLines)
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
            self.showingModalView = true
        }
    }
    
    @objc func cleanScene() {
        vertexNodes.removeFromParentNode()
        edgeNodes.removeFromParentNode()
        gridLines.removeFromParentNode()
        simPath.removeAll()
        
        UIView.animate(withDuration: 0.2) {
            self.settingsButtonBackgroundView.alpha = 0
            self.settingsButtonBorderView.alpha = 0
        }
        
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
            gridLines.removeAllActions()
            cameraNode.removeAllActions()
        } else if gestureRecognizer.state == .changed {
            var newX: Float = cameraNode.position.x - Float(translation.x / GameConstants.kPanTranslationScaleFactor)
            var newY: Float = cameraNode.position.y + Float(translation.y / GameConstants.kPanTranslationScaleFactor)
            
            if newX > 25 {
                newX = 25
            } else if newY > 25 {
                newY = 25
            } else if newX < -25 {
                newX = -25
            } else if newY < -25 {
                newY = -25
            }
            
            cameraNode.position = SCNVector3(x: newX,
                                              y: newY,
                                              z: cameraNode.position.z)
            
            UserDefaultsInteractor.setLevelSelectPosition(pos: [0, 0])
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
            gridLines.runAction(rotateAction)
        } else if gestureRecognizer.state == .ended {
            if abs(velocity.x) > 200 || abs(velocity.y) > 200 {
                var newX: Float = cameraNode.position.x - (Float(velocity.x*0.4)) / Float(GameConstants.kPanVelocityFactor)
                var newY: Float = cameraNode.position.y + (Float(velocity.y*0.4)) / Float(GameConstants.kPanVelocityFactor)
                
                if newX > 25 {
                    newX = 25
                } else if newX < -25 {
                    newX = -25
                } else if newY > 25 {
                    newY = 25
                } else if newY < -25 {
                    newY = -25
                }
                
                let newPosition: SCNVector3 = SCNVector3(x: newX, y: newY, z: cameraNode.position.z)
                let moveAction = SCNAction.move(to: newPosition, duration: 0.4)
                moveAction.timingMode = .easeOut
                
                cameraNode.runAction(moveAction)
                UserDefaultsInteractor.setLevelSelectPosition(pos: [newX, newY])
            }
            
            let rotateAction: SCNAction = SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 0.4)
            vertexNodes.runAction(rotateAction)
            edgeNodes.runAction(rotateAction)
            gridLines.runAction(rotateAction)
            previousDirection = ""
        }
    }
    
    @objc func landingPanGesture(gesture: UIPanGestureRecognizer) {
        guard let recognizerView = gesture.view else {
            return
        }
        let velocity = gesture.velocity(in: recognizerView)
        
        if gesture.state == .began {
            landingTitle.removeAllActions()
        } else if gesture.state == .changed {
            gesture.setTranslation(CGPoint.zero, in: recognizerView)
            
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
            
            let rotateAction: SCNAction = SCNAction.rotateTo(x: directionY * CGFloat.pi / 10, y: directionX * CGFloat.pi / 10, z: 0, duration: 0.2)
            landingTitle.runAction(rotateAction)
        } else if gesture.state == .ended {
            let rotateAction: SCNAction = SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 0.4)
            landingTitle.runAction(rotateAction)
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
        moveToNode(node: emitterNodes.first, zoom: false)
    }
    
    func moveToNode(node: SCNNode?, zoom: Bool) {
        guard let node = node else {
            return
        }
        
        var cameraZ = GameConstants.kCameraZ
        
        if zoom {
            cameraZ -= 10
            vertexNodes.removeAllAnimations()
        }
        
        vertexNodes.removeAllActions()
        edgeNodes.removeAllActions()
        gridLines.removeAllActions()
        
        let moveAction: SCNAction = SCNAction.move(to: SCNVector3(x: node.position.x + (node.parent?.position.x)!,
                                                                  y: node.position.y + (node.parent?.position.y)!, z: cameraZ), duration: 0.4)
        cameraNode.runAction(moveAction)
        UserDefaultsInteractor.setLevelSelectPosition(pos: [node.position.x, node.position.y])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gameSegue" {
            let viewController: GameViewController = segue.destination as! GameViewController
            viewController.currentLevel = selectedLevel
        }
    }
    
    @IBAction func playButtonPressed() {
        skView.isPaused = true
        GraphAnimation.addExplode(to: playButton)
        GraphAnimation.addExplode(to: playButtonBackgroundView)
        landingTitle.removeAllActions()
       
        landingEmitter.removeAction(forKey: "color_change_1")
        landingEmitter.removeAction(forKey: "color_change_2")
        self.runFinalColorAnimation(node: self.landingEmitter, oldColor: self.landingEmitter.childNodes[0].geometry?.materials[0].diffuse.contents as! UIColor, newColor: UIColor.white, material: self.landingEmitter.childNodes[0].geometry?.materials[0], duration: 1)
        self.runFinalColorAnimation(node: self.landingEmitter, oldColor: self.landingEmitter.childNodes[0].geometry?.materials[1].diffuse.contents as! UIColor, newColor: UIColor.black, material: self.landingEmitter.childNodes[0].geometry?.materials[1], duration: 1)

        if let explode = ParticleGeneration.createExplosion(color: UIColor.glowColor(), geometry: landingEmitter.childNodes[0].geometry!) {
            self.landingEmitter.childNodes[0].removeAllParticleSystems()
            self.landingEmitter.childNodes[0].addParticleSystem(explode)
            self.landingEmitter.childNodes[0].removeAnimation(forKey: "spin around")
        }
        
        GraphAnimation.delayWithSeconds(0.25) {
            self.playButtonBackgroundViewTopLayoutConstraint.constant = 400
            UIView.animate(withDuration: 0.5, animations: {
                self.playButton.alpha = 0
                self.playButtonBackgroundView.alpha = 0
                self.view.layoutSubviews()
            })
            let moveAction: SCNAction = SCNAction.move(to: SCNVector3(x: 0, y: 7, z: 0), duration: 0.5)
            let fadeAction: SCNAction = SCNAction.fadeOut(duration: 0.5)
            moveAction.timingMode = .easeInEaseOut
            fadeAction.timingMode = .easeInEaseOut
            self.landingTitle.runAction(moveAction)
            self.landingTitle.runAction(fadeAction)
            
            self.landingEmitter.scale = SCNVector3(x: 4, y: 4, z: 4)
            self.landingEmitter.removeAllAnimations()
            let scaleEmitterAction: SCNAction = SCNAction.scale(to: 1, duration: 1)
            scaleEmitterAction.timingMode = .easeInEaseOut
            self.landingEmitter.runAction(scaleEmitterAction)
            
            GraphAnimation.delayWithSeconds(1, completion: {
                self.setupLevelSelect()
                self.vertexNodes.addChildNode(self.landingEmitter)
                self.emitterNodes.append(self.landingEmitter.childNodes[0])
                self.currentlyAtLanding = false
            })
        }
    }
    
    @IBAction func settingsButtonPressed() {
        UIView.animate(withDuration: 0.2, animations: {
            self.settingsButtonBackgroundView.transform = CGAffineTransform(rotationAngle: 0.999*CGFloat.pi)
            self.settingsButtonBorderView.transform = CGAffineTransform(rotationAngle: 0.999*CGFloat.pi)
        }, completion: { (finished) in
            self.settingsButtonBackgroundView.transform = CGAffineTransform.identity
            self.settingsButtonBorderView.transform = CGAffineTransform.identity
        })
    }
    
    @IBAction func unwindToLevelSelect(segue: UIStoryboardSegue) {
        showingModalView = false
        GraphAnimation.delayWithSeconds(GameConstants.kShortTimeDelay) {
            self.setupLevelSelect()
            self.setupInteractions()
        }
    }
}

// Draw Loop
extension LevelSelectViewController: SCNSceneRendererDelegate {
//    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
//
//    }
}
