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
import Pastel
import M13Checkbox

class GameViewController: UIViewController {

    // SCENE VARS
    @IBOutlet var scnView: SCNView!
    var scnScene: SCNScene!
    var edgeNodes: SCNNode!
    var edgeArray: [Edge<Node>]!
    var vertexNodes: SCNNode!
    var lightNodes: SCNNode!
    var colorSelectNodes: SCNNode!

    // GLOBAL VARS
    var paintColor: UIColor = .customRed()
    var activeLevel: Level?
    var currentLevel: Int = 0
    var walkColor: UIColor = .goldColor()
    var selectedColorIndex: Int = 0
    var pathArray: [Int] = []
    var simArray: [Int] = []
    var currentStep: String = ""
    var firstStep: String = ""
    let axisArray: [String] = ["X", "Y", "Z"]
    var solved = false
    var simPlayerNodeCount: Int = 0
    var lightLayer: CALayer!
    var straylightView: UIView!
    var simPlayerColor: UIColor = .red
    
    // DEBUG
    var debug = false
    @IBOutlet var xAxisButton: UIButton!
    @IBOutlet var yAxisButton: UIButton!
    @IBOutlet var zAxisButton: UIButton!
    @IBOutlet var spawnButton: UIButton!
    var axisPanGestureRecognizer: UIPanGestureRecognizer!
    var debugNodes: SCNNode!
    var selectedAxis = axis.none
    var selectedNode: SCNNode!
    
    // UI
    @IBOutlet var skView: SKView!
    @IBOutlet var paintColorCollectionView: UICollectionView!
    @IBOutlet var collectionViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var levelTitle: UILabel!
    @IBOutlet var completedView: UIView!
    @IBOutlet var completedText: UILabel!
    @IBOutlet var completedCheckmark: M13Checkbox!
    @IBOutlet var completedViewBottomConstraint: NSLayoutConstraint!
    var colorSelectionButton: UIButton!
    
    // CAMERA VARS
    var cameraOrbit: SCNNode!
    var cameraNode: SCNNode!
    let camera = SCNCamera()
    
    struct GameConstants {
        static let kCameraZ: Float = 25
        static let kScaleShrink: CGFloat = 0.8
        static let kScaleGrow: CGFloat = 1.25
        static let kPanTranslationScaleFactor: CGFloat = 100
        
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
    
    enum axis: Int {
        case x = 0
        case y
        case z
        case none
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
        
        if debug {
            setupDebug()
        } else {
            setupLevel()
        }
        setupInteractions()
    }
    
    func setupView() {
        guard let sceneView = scnView else {
            return
        }
        
        scnView = sceneView
        scnView.showsStatistics = debug ? true : false
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = true
        scnView.antialiasingMode = .multisampling4X
        scnView.delegate = self
        scnView.isPlaying = true
        
        axisPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGesturePlanarMove(gestureRecognize:)))
        scnView.addGestureRecognizer(axisPanGestureRecognizer)
        axisPanGestureRecognizer?.isEnabled = false
    }
    
    func setupScene() {
        scnScene = SCNScene()
        scnView.scene = scnScene
        scnView.backgroundColor = UIColor.clear
        scnScene.background.contents = UIColor.clear
        
        lightLayer = CALayer()
        lightLayer.frame = skView.frame
        straylightView = UIView()
        straylightView.frame = skView.frame
        straylightView.backgroundColor = .clear
        straylightView.layer.addSublayer(lightLayer)
        straylightView.addParallaxToView()
        skView.addSubview(straylightView)
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
        
        setupStraylights()
        createObjects()
        GraphAnimation.explodeGraph(vertexNodes: vertexNodes, edgeNodes: edgeNodes)

        GraphAnimation.delayWithSeconds(GameConstants.kMediumTimeDelay) {
            GraphAnimation.rotateGraphObject(vertexNodes: self.vertexNodes, edgeNodes: self.edgeNodes)
            guard let graphType = self.activeLevel?.graphType else {
                return
            }

            if graphType != .planar {
                GraphAnimation.swellGraphObject(vertexNodes: self.vertexNodes, edgeNodes: self.edgeNodes)
            }
        }

        GraphAnimation.delayWithSeconds(GameConstants.kLongTimeDelay) {
            GraphAnimation.scaleGraphObject(vertexNodes: self.vertexNodes, edgeNodes: self.edgeNodes, duration: 0.5, toScale: SCNVector4(x: 2, y: 2, z: 2, w: 0))
            GraphAnimation.animateInCollectionView(view: self.view, collectionViewBottomConstraint: self.collectionViewBottomConstraint)
        }

        GraphAnimation.delayWithSeconds(GameConstants.kLongTimeDelay + 0.6) {
            guard let graphType: GraphType = self.activeLevel?.graphType else {
                return
            }

            if graphType == .planar {
                self.activeLevel?.adjacencyList?.updateCorrectEdges(level: self.activeLevel, pathArray: self.pathArray, edgeArray: self.edgeArray, edgeNodes: self.edgeNodes)
            }
        }
    }
    
    func setupDebug() {
        debugNodes = SCNNode()
        debugNodes.name = "debug"
        
        scnView.removeGestureRecognizer(axisPanGestureRecognizer)
        axisPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGesture(gestureRecognize:)))
        scnView.addGestureRecognizer(axisPanGestureRecognizer)
        axisPanGestureRecognizer?.isEnabled = false

        xAxisButton.isHidden = false
        yAxisButton.isHidden = false
        zAxisButton.isHidden = false
        spawnButton.isHidden = false
        
        selectedNode = SCNNode()
        Shapes.spawnShape(type: .Custom, position: SCNVector3(x: 0, y: 0, z: 0), color: UIColor.white, id: 0, node: selectedNode)
        debugNodes.addChildNode(selectedNode)
        scnScene.rootNode.addChildNode(debugNodes)
    }
    
    func setupInteractions() {
        paintColorCollectionView.register(UINib(nibName: "ColorButtonCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: GameConstants.kPaintCellReuseIdentifier)
        paintColorCollectionView.delegate = self
        paintColorCollectionView.dataSource = self
        paintColorCollectionView.collectionViewLayout = UICollectionViewFlowLayout()
        paintColorCollectionView.backgroundColor = UIColor.clear
        paintColorCollectionView.layer.masksToBounds = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        UIColor.setupBackgrounds(view: view, skView: skView)
    }
    
    func setupStraylights() {
        UIView.animate(withDuration: 0.5, animations: {
            self.straylightView.alpha = 0
        }) { (finished) in
            self.lightLayer.sublayers = nil
            GraphAnimation.delayWithSeconds(0.2) {
                self.straylightView.alpha = 1
            }
            
            let numberOfLines = Int.random(min: 3, max: 4)
            let slope = Float.random(min: 1.35, max: 3)
            
            for _ in 0...numberOfLines {
                let randomYStart = Int.random(min: 100, max: 400)
                let randomYEnd = Float(randomYStart) * slope
                let randomWidth = Int.random(min: 8, max: 16)
                self.lightLayer.drawLine(fromPoint: CGPoint(x: Int(self.view.frame.size.width)+50, y: randomYStart), toPoint: CGPoint(x: -50, y: Int(randomYEnd)), width: CGFloat(randomWidth))
            }
            
            for layer in self.lightLayer.sublayers! {
                GraphAnimation.delayWithSeconds(Double.random(min: 0.5, max: 2)) {
                    let animation : CABasicAnimation = CABasicAnimation(keyPath: "opacity")
                    animation.fromValue = 0
                    animation.toValue = Float.random(min: 0.05, max: 0.15)
                    animation.duration = Double.random(min: 1, max: 1.5)
                    animation.isRemovedOnCompletion = false
                    animation.fillMode = kCAFillModeForwards
                    layer.add(animation, forKey: nil)
                    GraphAnimation.delayWithSeconds(Double.random(min: 3, max: 6)) {
                        GraphAnimation.addOpacityPulse(to: layer)
                    }
                }
            }
        }
    }
    
    // OBJECT CREATION AND HANDLING
    func createObjects() {
        edgeNodes = SCNNode()
        vertexNodes = SCNNode()
        
        levelTitle.text = activeLevel?.name

        guard let adjacencyDict = activeLevel?.adjacencyList?.adjacencyDict else {
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
                    edgeNodes.addChildNode(node.buildLineInTwoPointsWithRotation(from: edge.source.data.position, to: edge.destination.data.position, radius: Shapes.ShapeConstants.cylinderRadius, color: .defaultVertexColor()))
                    
                    edgeArray.append(edge)
                }
            }
        }
        
        scnScene.rootNode.addChildNode(vertexNodes)
        scnScene.rootNode.addChildNode(edgeNodes)
        
        guard let graphType: GraphType = activeLevel?.graphType else {
            return
        }
        
        if graphType == .planar {
            activeLevel?.adjacencyList?.updateCorrectEdges(level: activeLevel, pathArray: pathArray, edgeArray: edgeArray, edgeNodes: edgeNodes)
        }
    }
    
    func handleTouchFor(node: SCNNode) {
        
        guard let geometry = node.geometry else {
            return
        }
        
        guard let geoName = geometry.name else {
            return
        }
        
        guard let graphType: GraphType = activeLevel?.graphType else {
            return
        }
        
        if geometry.name != "edge" {
            var activeColor = (graphType == .hamiltonian) ? walkColor : paintColor

            switch graphType {
            case .hamiltonian:
                guard let neighbours = activeLevel?.adjacencyList?.getNeighbours(for: currentStep) else {
                    return
                }
                
                if geometry.name == firstStep {
                    guard let isLastStep = activeLevel?.adjacencyList?.isLastStep() else {
                        return
                    }
                    
                    if !isLastStep {
                        return
                    }
                } else if (geometry.firstMaterial?.diffuse.contents as? UIColor == walkColor) {
                    return
                }
                
                if pathArray.count > 0 && !neighbours.contains(geoName) {
                    return
                }
            case .planar:
                activeColor = UIColor.red
                for node in vertexNodes.childNodes {
                    node.geometry?.materials.first?.diffuse.contents = UIColor.defaultVertexColor()
                    node.removeAllParticleSystems()
                }
                
                if selectedNode == node {
                    selectedNode = nil
                    axisPanGestureRecognizer?.isEnabled = false
                } else {
                    scnView.pointOfView?.runAction(SCNAction.move(to: SCNVector3(x: 0, y: 0, z: GameConstants.kCameraZ), duration: 0.5))
                    scnView.pointOfView?.runAction(SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 0.5))
                    
                    selectedNode = node
                    
                    guard let neighbours = activeLevel?.adjacencyList?.getNeighbours(for: selectedNode.geometry?.name) else {
                        return
                    }
                    activeLevel?.adjacencyList?.updateNeighbourColors(level: activeLevel, neighbours: neighbours, vertexNodes: vertexNodes)
                    
                    axisPanGestureRecognizer?.isEnabled = true
                    geometry.materials.first?.diffuse.contents = activeColor
                    selectNode(node: node, graphType: graphType, activeColor: activeColor)
                }
                
                activeLevel?.adjacencyList?.updateCorrectEdges(level: activeLevel, pathArray: pathArray, edgeArray: edgeArray, edgeNodes: edgeNodes)
                checkIfSolved()
                return
            case .kColor:
                break
            case .sim:
                if selectedNode == node {
                    return
                }
                
                simPlayerNodeCount += 1
                selectedColorIndex += 1
                selectedNode = node
                paintColorCollectionView.reloadData()
            }
            
            if debug {
                selectedNode = node
            }
            
            if !solved {
                selectNode(node: node, graphType: graphType, activeColor: activeColor)
            }
            
            if let _ = activeLevel?.adjacencyList {
                activeLevel?.adjacencyList = activeLevel?.adjacencyList!.updateGraphState(id: geometry.name, color: activeColor)
            }
            
            if let nameToInt = Int(geoName) {
                pathArray.append(nameToInt)
            }
            
            if currentStep == "" {
                firstStep = geoName
            }
            currentStep = geoName
        }
        
        if graphType == .sim {
            // Is player done making SIM move?
            if simPlayerNodeCount == 2 { // Yes
                scnView.isUserInteractionEnabled = false

                GraphAnimation.delayWithSeconds(GameConstants.kLongTimeDelay) {
                    self.scnView.isUserInteractionEnabled = true
                    for node in self.vertexNodes.childNodes {
                        node.removeAllParticleSystems()

                        node.geometry?.materials.first?.diffuse.contents = UIColor.defaultVertexColor()
                        node.geometry?.materials.first?.emission.contents = UIColor.defaultVertexColor()
                    }
                }

                if pathArray.count > 1 {
                    if let isLegalMove = activeLevel?.adjacencyList?.isLegalMove(simArray: simArray, uid1: pathArray[0], uid2: pathArray[1]) {
                        if !isLegalMove {
                            simPlayerNodeCount = 0
                            selectedNode = nil
                            selectedColorIndex = 0
                            pathArray.removeAll()
                            paintColorCollectionView.reloadData()
                            GraphAnimation.addShake(to: paintColorCollectionView)
                            return
                        } else {
                            GraphAnimation.addExplode(to: paintColorCollectionView)
                        }
                    }
                }

                activeLevel?.adjacencyList?.updateCorrectEdges(level: activeLevel, pathArray: pathArray, edgeArray: edgeArray, edgeNodes: edgeNodes)

                for item in pathArray {
                    simArray.append(item)
                }
                
                checkIfSolved()
                if solved {
                    completedText.text = "YOU LOST"
                    return
                } else {
                    completedText.text = "YOU WON"
                }
                
                GraphAnimation.delayWithSeconds(GameConstants.kLongTimeDelay, completion: {
                    self.simPlayerNodeCount = 0
                    self.selectedNode = nil

                    self.activeLevel?.adjacencyList?.makeSimMove(edgeArray: self.edgeArray, edgeNodes: self.edgeNodes, simArray: self.simArray)
                    self.pathArray.removeAll()
                    self.selectedColorIndex = 0
                    self.paintColorCollectionView.reloadData()
                    self.scnView.isUserInteractionEnabled = true
                    self.checkIfSolved()
                    return
                })
            }
        } else {
            activeLevel?.adjacencyList?.updateCorrectEdges(level: self.activeLevel, pathArray: self.pathArray, edgeArray: self.edgeArray, edgeNodes: self.edgeNodes)
        }
        
        checkIfSolved()
    }
    
    func checkIfSolved() {
        guard let graphType: GraphType = activeLevel?.graphType else {
            return
        }
        
        if let list = activeLevel?.adjacencyList {
            if list.checkIfSolved(forType: graphType, edgeArray: edgeArray, edgeNodes: edgeNodes) {
                if ((graphType == .hamiltonian) && firstStep == currentStep) || !(graphType == .hamiltonian) {
                    
                    solved = true
                    
                    for node in vertexNodes.childNodes {
                        if let explosion = ParticleGeneration.createExplosion(color: UIColor.glowColor(), geometry: node.geometry!) {
                            node.removeAllParticleSystems()
                            node.addParticleSystem(explosion)
                        }
                    }
                    
                    for node in edgeNodes.childNodes {
                        if let explosion = ParticleGeneration.createExplosion(color: UIColor.glowColor(), geometry: node.geometry!) {
                            node.removeAllParticleSystems()
                            node.addParticleSystem(explosion)
                        }
                    }
                    
                    completedCheckmark.setCheckState(.checked, animated: true)
                    scnView.pointOfView?.runAction(SCNAction.move(to: SCNVector3(x: 0, y: 0, z: GameConstants.kCameraZ), duration: 0.5))
                    scnView.pointOfView?.runAction(SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 0.5))
                    
                    GraphAnimation.delayWithSeconds(0.5, completion: {
                        self.scnView.isUserInteractionEnabled = false
                        GraphAnimation.rotateGraphObject(vertexNodes: self.vertexNodes, edgeNodes: self.edgeNodes)
                        GraphAnimation.delayWithSeconds(0.5, completion: {
                            GraphAnimation.scaleGraphObject(vertexNodes: self.vertexNodes, edgeNodes: self.edgeNodes, duration: 0.5, toScale: SCNVector4(x: 2.5, y: 2.5, z: 2.5, w: 0))
                            self.collectionViewBottomConstraint.constant = GameConstants.kCollectionViewBottomOffsetShowing
                            self.completedViewBottomConstraint.constant = GameConstants.kCollectionViewBottomOffsetHidden
                            
                            if graphType != .sim {
                                self.activeLevel?.adjacencyList?.updateCorrectEdges(level: self.activeLevel, pathArray: self.pathArray, edgeArray: self.edgeArray, edgeNodes: self.edgeNodes)
                            }
                            
                            UIView.animate(withDuration: GameConstants.kShortTimeDelay, delay: 0.5, options: .curveEaseInOut, animations: {
                                self.view.layoutIfNeeded()
                            })
                        })
                    })
                }
            }
        }
    }
    
    func selectNode(node: SCNNode, graphType: GraphType, activeColor: UIColor) {
        let scaleUpAction = SCNAction.scale(by: GameConstants.kScaleGrow, duration: GameConstants.kVeryShortTimeDelay)
        scaleUpAction.timingMode = .easeInEaseOut
        let scaleDownAction = SCNAction.scale(by: GameConstants.kScaleShrink, duration: GameConstants.kVeryShortTimeDelay)
        scaleDownAction.timingMode = .easeInEaseOut
        
        node.runAction(scaleUpAction) {
            node.runAction(scaleDownAction) {}
        }
        
        guard let geometry = node.geometry else {
            return
        }
        
        geometry.materials.first?.diffuse.contents = activeColor
        geometry.materials.first?.emission.contents = UIColor.defaultVertexColor()
        
        if graphType == .hamiltonian && currentStep == "" {
            geometry.materials[1].diffuse.contents = activeColor
            geometry.materials[0].diffuse.contents = UIColor.defaultVertexColor()
        }
        
        if let explosion = ParticleGeneration.createExplosion(color: UIColor.glowColor(), geometry: geometry) {
            node.removeAllParticleSystems()
            node.addParticleSystem(explosion)
        }
        
        GraphAnimation.delayWithSeconds(GameConstants.kShortTimeDelay) {
            if let trailEmitter = ParticleGeneration.createTrail(color: activeColor, geometry: geometry) {
                node.removeAllParticleSystems()
                node.addParticleSystem(trailEmitter)
            }
        }
    }
    
    @objc func refreshColorsInCollectionView() {
        collectionViewBottomConstraint.constant = GameConstants.kCollectionViewBottomOffsetShowing
        UIView.animate(withDuration: GameConstants.kShortTimeDelay, delay: 1.35, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }) { (finished) in
            self.paintColorCollectionView.reloadData()
            self.selectedColorIndex = 0
            self.paintColor = kColors[0]
            self.collectionViewBottomConstraint.constant = GameConstants.kCollectionViewBottomOffsetHidden
            
            UIView.animate(withDuration: GameConstants.kShortTimeDelay, delay: 0.2, options: .curveEaseInOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
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
    
    @objc func panGesturePlanarMove(gestureRecognize: UIPanGestureRecognizer) {
        if gestureRecognize.state == .changed {
            guard let recognizerView = gestureRecognize.view else {
                return
            }
            
            let translation = gestureRecognize.translation(in: recognizerView)
            
            let position = SCNVector3(x:selectedNode.position.x + Float(translation.x / 75), y:selectedNode.position.y - Float(translation.y / 75), z:selectedNode.position.z)
            selectedNode.position = position
            
            gestureRecognize.setTranslation(CGPoint.zero, in: recognizerView)
            
            activeLevel?.adjacencyList?.updateNodePosition(id: selectedNode.geometry?.name, newPosition: position)
            
            guard let adjacencyDict = activeLevel?.adjacencyList?.adjacencyDict else {
                return
            }
            
            edgeNodes.removeFromParentNode()
            edgeNodes = SCNNode()
            edgeArray.removeAll()
            
            for (_, value) in adjacencyDict {
                
                // Create edges
                for edge in value {
                    if edgeArray.filter({ el in (el.destination.data.position.equal(b: edge.source.data.position) && el.source.data.position.equal(b: edge.destination.data.position)) }).count == 0 {
                        let node = SCNNode()
                        edgeNodes.addChildNode(node.buildLineInTwoPointsWithRotation(from: edge.source.data.position, to: edge.destination.data.position, radius: Shapes.ShapeConstants.cylinderRadius, color: .defaultVertexColor()))
                        
                        edgeArray.append(edge)
                    }
                }
            }
            
            scnScene.rootNode.addChildNode(edgeNodes)

        } else if gestureRecognize.state == .ended {
            activeLevel?.adjacencyList?.updateCorrectEdges(level: activeLevel, pathArray: pathArray, edgeArray: edgeArray, edgeNodes: edgeNodes)
            checkIfSolved()
        }
    }
    
    @objc func cleanScene() {
        axisPanGestureRecognizer?.isEnabled = false
        vertexNodes.removeFromParentNode()
        edgeNodes.removeFromParentNode()
        pathArray.removeAll()
        simArray.removeAll()
        currentStep = ""
        firstStep = ""
        solved = false
        completedText.text = "ZONE CLEAR"
        
        currentLevel += 1
        refreshColorsInCollectionView()
        axisPanGestureRecognizer?.isEnabled = false
        setupLevel()
    }
    
    // DEBUG MODE CODE
    @IBAction func debugXPress() {
        if selectedAxis == .x {
            selectedAxis = .none
            xAxisButton.backgroundColor = .white
            editModeDeactivate()
        } else {
            selectedAxis = .x
            xAxisButton.backgroundColor = .customBlue()
            editModeActivate()
        }
        yAxisButton.backgroundColor = .white
        zAxisButton.backgroundColor = .white
    }
    
    @IBAction func debugYPress() {
        if selectedAxis == .y {
            selectedAxis = .none
            yAxisButton.backgroundColor = .white
            editModeDeactivate()
        } else {
            selectedAxis = .y
            yAxisButton.backgroundColor = .customBlue()
            editModeActivate()
        }
        xAxisButton.backgroundColor = .white
        zAxisButton.backgroundColor = .white
    }
    
    @IBAction func debugZPress() {
        if selectedAxis == .z {
            selectedAxis = .none
            zAxisButton.backgroundColor = .white
            editModeDeactivate()
        } else {
            selectedAxis = .z
            zAxisButton.backgroundColor = .customBlue()
            editModeActivate()
        }
        xAxisButton.backgroundColor = .white
        yAxisButton.backgroundColor = .white
    }
    
    @IBAction func spawnDebugNode() {
        selectedNode = SCNNode()
        Shapes.spawnShape(type: .Custom, position: SCNVector3(x: 0, y: 0, z: 0), color: UIColor.white, id: 0, node: selectedNode)
        debugNodes.addChildNode(selectedNode)
    }
    
    @IBAction func nextLevel() {
        GraphAnimation.implodeGraph(vertexNodes: vertexNodes, edgeNodes: edgeNodes, clean: cleanScene)
        self.completedViewBottomConstraint.constant = GameConstants.kCollectionViewBottomOffsetShowing
        UIView.animate(withDuration: GameConstants.kShortTimeDelay, delay: 0.5, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func editModeActivate() {
        scnView.allowsCameraControl = false
        axisPanGestureRecognizer?.isEnabled = true
    }
    
    func editModeDeactivate() {
        scnView.allowsCameraControl = true
        axisPanGestureRecognizer?.isEnabled = false
    }
    
    @objc func panGesture(gestureRecognize: UIPanGestureRecognizer){
        if gestureRecognize.state == .changed {
            guard let recognizerView = gestureRecognize.view else {
                return
            }
            
            let translation = gestureRecognize.translation(in: recognizerView)
            
            switch selectedAxis {
            case .x:
                selectedNode.position = SCNVector3(x:selectedNode.position.x + Float(translation.x / GameConstants.kPanTranslationScaleFactor), y:selectedNode.position.y, z:selectedNode.position.z)
            case .y:
                selectedNode.position = SCNVector3(x:selectedNode.position.x, y:selectedNode.position.y - Float(translation.y / GameConstants.kPanTranslationScaleFactor), z:selectedNode.position.z)
            case .z:
                selectedNode.position = SCNVector3(x:selectedNode.position.x, y:selectedNode.position.y, z:selectedNode.position.z - Float(translation.x / GameConstants.kPanTranslationScaleFactor))
            default:
                break
            }
            
            gestureRecognize.setTranslation(CGPoint.zero, in: recognizerView)
        } else if gestureRecognize.state == .ended {
            // Print & record final location
            print(selectedNode.position)
        }
    }
}

// Draw Loop
extension GameViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {

    }
}

// UICollectionView / UI Elements
extension GameViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let colorCount = activeLevel?.numberOfColorsProvided  {
            return colorCount
        }
        return GameConstants.kDefaultCellsInSection
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: GameConstants.kPaintCellWidthHeight, height: GameConstants.kPaintCellWidthHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GameConstants.kPaintCellReuseIdentifier, for: indexPath as IndexPath) as! ColorButtonCollectionViewCell
        
        guard let graphType = activeLevel?.graphType else {
            return cell
        }
        
        cell.checkbox.isHidden = (graphType == .hamiltonian || graphType == .planar || graphType == .sim) ? true : false
        cell.palletImage.isHidden = (graphType == .hamiltonian || graphType == .planar || graphType == .sim) ? false : true
        
        if graphType == .sim {
            if simPlayerNodeCount > indexPath.row {
                cell.backgroundColor = simPlayerColor
            } else {
                cell.backgroundColor = .black
            }
        } else if graphType == .hamiltonian {
            cell.backgroundColor = walkColor
        } else {
            cell.backgroundColor = kColors[indexPath.row]
        }
        
        cell.layer.cornerRadius = cell.frame.size.width / 2
        cell.layer.borderWidth = 2
        cell.checkbox.stateChangeAnimation = .expand(.fill)
        
        if graphType == .planar {
            cell.palletImage.image = UIImage(named: "move")
        } else if graphType == .hamiltonian {
            cell.palletImage.image = UIImage(named: "undo")
        } else if graphType == .sim {
            cell.palletImage.image = UIImage(named: "node")
        }
        
        cell.palletImage.image = cell.palletImage.image?.withRenderingMode(.alwaysTemplate)
        cell.palletImage.tintColor = .white
        
        if selectedColorIndex == indexPath.row {
            cell.checkbox.setCheckState(.checked, animated: true)
            cell.layer.borderColor = UIColor.customWhite().cgColor
            GraphAnimation.delayWithSeconds(GameConstants.kShortTimeDelay) {
                GraphAnimation.addPulse(to: cell)
            }
        } else {
            cell.checkbox.setCheckState(.unchecked, animated: true)
            cell.layer.borderColor = graphType == .sim ? UIColor.customWhite().darker()?.cgColor : kColors[indexPath.row].darker()?.cgColor
            cell.layer.removeAllAnimations()
        }
        cell.checkbox.hideBox = true
        
        return cell
    }
}

extension GameViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let totalCellWidth = GameConstants.kPaintCellWidthHeight * collectionView.numberOfItems(inSection: 0)
        let totalSpacingWidth = GameConstants.kPaintCellPadding * (collectionView.numberOfItems(inSection: 0) - 1)
        
        let leftInset = (collectionView.layer.frame.size.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset
        
        return UIEdgeInsetsMake(0, leftInset, 0, rightInset)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell: ColorButtonCollectionViewCell = collectionView.cellForItem(at: indexPath) as! ColorButtonCollectionViewCell
        
        guard let graphType = activeLevel?.graphType else {
            return
        }
        
        if (graphType == .hamiltonian) && pathArray.count > 0 {
            for node in vertexNodes.childNodes {
                guard let geoName = node.geometry?.name else {
                    return
                }
                
                guard let lastItem = pathArray.last else {
                    return
                }
                
                if geoName == "\(String(describing: lastItem))" {
                    node.geometry?.materials.first?.diffuse.contents = UIColor.defaultVertexColor()
                    node.geometry?.materials[1].diffuse.contents = UIColor.white
                    node.removeAllParticleSystems()
                    
                    if let _ = activeLevel?.adjacencyList {
                        activeLevel?.adjacencyList = activeLevel?.adjacencyList!.updateGraphState(id: node.geometry?.name, color: UIColor.defaultVertexColor())
                    }
                    
                    _ = pathArray.removeLast()
                    if let newStep = pathArray.last {
                        currentStep = "\(newStep)"
                    }
                    
                    if pathArray.count > 1 {
                        activeLevel?.adjacencyList?.updateCorrectEdges(level: activeLevel, pathArray: pathArray,  edgeArray: edgeArray, edgeNodes: edgeNodes)
                    } else {
                        var pos = 0
                        for _ in edgeArray {
                            edgeNodes.childNodes[pos].geometry?.firstMaterial?.diffuse.contents = UIColor.defaultVertexColor()
                            edgeNodes.childNodes[pos].geometry?.firstMaterial?.emission.contents = UIColor.defaultVertexColor()
                            edgeNodes.childNodes[pos].removeAllParticleSystems()
                            pos += 1
                        }
                        if pathArray.count == 0 {
                            firstStep = ""
                            currentStep = ""
                        }
                    }
                    break
                }
            }
        } else if graphType == .planar || graphType == .sim {
            return
        } else {
            if let color = cell.backgroundColor {
                paintColor = color
            }
            
            selectedColorIndex = indexPath.row
            paintColorCollectionView.reloadData()
        }
    }
}
