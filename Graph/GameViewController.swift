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
    var colorSelectNodes: SCNNode!

    // GLOBAL VARS
    var paintColor: UIColor = UIColor.customRed()
    var activeLevel: Level?
    var animating: Bool = false
    var currentLevel: Int = 0
    var walkColor = UIColor.goldColor()
    var selectedColorIndex: Int = 0
    var pathArray: [Int] = []
    var currentStep: String = ""
    var firstStep: String = ""
    
    // DEBUG
    var debug = false
    @IBOutlet var xAxisButton: UIButton!
    @IBOutlet var yAxisButton: UIButton!
    @IBOutlet var zAxisButton: UIButton!
    @IBOutlet var spawnButton: UIButton!
    var axisPanGestureRecognizer: UIPanGestureRecognizer?
    var debugNodes: SCNNode!
    var selectedAxis = -1
    var selectedNode: SCNNode!
    
    // UI Elements
    @IBOutlet var skView: SKView!
    @IBOutlet var paintColorCollectionView: UICollectionView!
    @IBOutlet var collectionViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var levelTitle: UILabel!
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
        
        if debug {
            setupDebug()
        } else {
            setupLevel()
        }
        setupInteractions()
        
    }
    
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func setupView() {
        guard let sceneView = self.scnView else {
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
        scnView.addGestureRecognizer(axisPanGestureRecognizer!)
        axisPanGestureRecognizer?.isEnabled = false
    }
    
    func setupScene() {
        scnScene = SCNScene()
        scnView.scene = scnScene
        scnView.backgroundColor = UIColor.clear
        scnScene.background.contents = UIColor.clear
    }
    
    func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 20)
        scnScene.rootNode.addChildNode(cameraNode)
    }
    
    @objc func setupLevel() {
        activeLevel = Levels.createLevel(index: currentLevel)
        scnView.pointOfView?.position = SCNVector3(x: 0, y: 0, z: 20)
        scnView.pointOfView?.rotation = SCNVector4(x: 0, y: 0, z: 0, w: 0)
                
        createObjects()
        GraphAnimation.explodeGraph(vertexNodes: vertexNodes, edgeNodes: edgeNodes)
        
        GraphAnimation.delayWithSeconds(0.5) {
            GraphAnimation.rotateGraphObject(vertexNodes: self.vertexNodes, edgeNodes: self.edgeNodes)
            GraphAnimation.swellGraphObject(vertexNodes: self.vertexNodes, edgeNodes: self.edgeNodes)
        }
        
        GraphAnimation.delayWithSeconds(1.0) {
            GraphAnimation.scaleGraphObject(vertexNodes: self.vertexNodes, edgeNodes: self.edgeNodes)
            GraphAnimation.animateInCollectionView(view: self.view, collectionViewBottomConstraint: self.collectionViewBottomConstraint)
        }
    }
    
    func setupDebug() {
        debugNodes = SCNNode()
        debugNodes.name = "debug"

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
        
        paintColorCollectionView.register(UINib(nibName: "ColorButtonCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        paintColorCollectionView.delegate = self
        paintColorCollectionView.dataSource = self
        paintColorCollectionView.collectionViewLayout = UICollectionViewFlowLayout()
        paintColorCollectionView.backgroundColor = UIColor.clear
        paintColorCollectionView.layer.masksToBounds = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
    
        let pastelView = PastelView(frame: view.bounds)
        
        // Custom Direction
        pastelView.startPastelPoint = .bottom
        pastelView.endPastelPoint = .top
        
        // Custom Duration
        pastelView.animationDuration = 10.0
        
        // Custom Color        
        pastelView.setColors([ UIColor(red: 247/255, green: 109/255, blue: 130/255, alpha: 1.0),
                                UIColor(red: 217/255, green: 68/255, blue: 82/255, alpha: 1.0),
                                UIColor(red: 98/255, green: 221/255, blue: 189/255, alpha: 1.0),
                                UIColor(red: 53/255, green: 187/255, blue: 155/255, alpha: 1.0),
                                UIColor(red: 115/255, green: 177/255, blue: 244/255, alpha: 1.0),
                                UIColor(red: 75/255, green: 137/255, blue: 218/255, alpha: 1.0)])
        
        pastelView.startAnimation()
        
        view.insertSubview(pastelView, at: 0)

        // Add background particles
        let skScene = SKScene(size: CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height))
        skScene.backgroundColor = UIColor.clear
        let path = Bundle.main.path(forResource: "Background", ofType: "sks")
        let backgroundParticle = NSKeyedUnarchiver.unarchiveObject(withFile: path!) as! SKEmitterNode
        backgroundParticle.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height/2)
        backgroundParticle.targetNode = skScene.scene
        backgroundParticle.particlePositionRange = CGVector(dx: self.view.frame.size.width, dy: self.view.frame.size.height)
        skScene.scene?.addChild(backgroundParticle)
        skView.presentScene(skScene)
        skView.backgroundColor = UIColor.clear
    }
    
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
                    edgeNodes.addChildNode(node.buildLineInTwoPointsWithRotation(from: edge.source.data.position, to: edge.destination.data.position, radius: 0.1, color: .black))
                    
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
        
        guard let hamiltonian: Bool = activeLevel?.hamiltonian else {
            return
        }
        
        if geometry.name != "edge" {
            let activeColor = hamiltonian ? walkColor : paintColor

            if hamiltonian {
                let neighbours = activeLevel?.adjacencyList?.getNeighbours(for: currentStep)
                
                if geometry.name == firstStep {
                    if !(activeLevel?.adjacencyList?.isLastStep())! {
                        return
                    }
                } else if (geometry.firstMaterial?.diffuse.contents as! UIColor == walkColor) {
                    return
                }
                
                if pathArray.count > 0 && !neighbours!.contains(geometry.name!) {
                    return
                }
            }
            
            if (activeLevel?.planar)! {
                if selectedNode == node {
                    selectedNode = nil
                    axisPanGestureRecognizer?.isEnabled = false
                    geometry.materials.first?.diffuse.contents = UIColor.black
                } else {
                    selectedNode = node
                    axisPanGestureRecognizer?.isEnabled = true
                    geometry.materials.first?.diffuse.contents = activeColor
                }
                return
            }
            
            if debug {
                selectedNode = node
            }
            
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
            
            geometry.materials.first?.diffuse.contents = activeColor
            geometry.materials.first?.emission.contents = UIColor.black
            
            if let trailEmitter = ParticleGeneration.createTrail(color: activeColor, geometry: geometry) {
                node.removeAllParticleSystems()
                node.addParticleSystem(trailEmitter)
            }
            
            if let _ = activeLevel?.adjacencyList {
                activeLevel?.adjacencyList = activeLevel?.adjacencyList!.updateGraphState(id: geometry.name, color: activeColor)
            }
            
            //game.playSound(node: scnScene.rootNode, name: "SpawnGood")
            
            pathArray.append(Int(geometry.name!)!)
            if currentStep == "" {
                firstStep = geometry.name!
            }
            currentStep = geometry.name!
        }

        activeLevel?.adjacencyList?.updateCorrectEdges(level: activeLevel, pathArray: pathArray, edgeArray: edgeArray, edgeNodes: edgeNodes)
        
        if let _ = activeLevel?.adjacencyList, let hamiltonian: Bool = activeLevel?.hamiltonian {
            if (activeLevel?.adjacencyList!.checkIfSolved(forType: (hamiltonian ? GraphType.hamiltonian : GraphType.kColor)))! {
                if hamiltonian && firstStep == currentStep {
                    GraphAnimation.implodeGraph(vertexNodes: vertexNodes, edgeNodes: edgeNodes, clean: cleanScene)
                } else if !hamiltonian {
                    GraphAnimation.implodeGraph(vertexNodes: vertexNodes, edgeNodes: edgeNodes, clean: cleanScene)
                }
            }
        }
    }
    
    @objc func refreshColorsInCollectionView() {
        collectionViewBottomConstraint.constant = -115
        UIView.animate(withDuration: 0.3, delay: 1.35, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }) { (finished) in
            self.paintColorCollectionView.reloadData()
            self.selectedColorIndex = 0
            self.paintColor = kColors[0]
            self.collectionViewBottomConstraint.constant = 16
            
            UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveEaseInOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
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
    
    @IBAction func debugXPress() {
        if selectedAxis == 0 {
            selectedAxis = -1
            xAxisButton.backgroundColor = UIColor.white
            editModeDeactivate()
        } else {
            selectedAxis = 0
            xAxisButton.backgroundColor = UIColor.customBlue()
            editModeActivate()
        }
        yAxisButton.backgroundColor = UIColor.white
        zAxisButton.backgroundColor = UIColor.white
    }
    
    @IBAction func debugYPress() {
        if selectedAxis == 1 {
            selectedAxis = -1
            yAxisButton.backgroundColor = UIColor.white
            editModeDeactivate()
        } else {
            selectedAxis = 1
            yAxisButton.backgroundColor = UIColor.customBlue()
            editModeActivate()
        }
        xAxisButton.backgroundColor = UIColor.white
        zAxisButton.backgroundColor = UIColor.white
    }
    
    @IBAction func debugZPress() {
        if selectedAxis == 2 {
            selectedAxis = -1
            zAxisButton.backgroundColor = UIColor.white
            editModeDeactivate()
        } else {
            selectedAxis = 2
            zAxisButton.backgroundColor = UIColor.customBlue()
            editModeActivate()
        }
        xAxisButton.backgroundColor = UIColor.white
        yAxisButton.backgroundColor = UIColor.white
    }
    
    @IBAction func spawnDebugNode() {
        selectedNode = SCNNode()
        Shapes.spawnShape(type: .Custom, position: SCNVector3(x: 0, y: 0, z: 0), color: UIColor.white, id: 0, node: selectedNode)
        debugNodes.addChildNode(selectedNode)
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
            let translation = gestureRecognize.translation(in: gestureRecognize.view!)
            
            switch selectedAxis {
            case 0:
                selectedNode.position = SCNVector3(x:selectedNode.position.x + Float(translation.x / 100), y:selectedNode.position.y, z:selectedNode.position.z)
            case 1:
                selectedNode.position = SCNVector3(x:selectedNode.position.x, y:selectedNode.position.y - Float(translation.y / 100), z:selectedNode.position.z)
            default:
                selectedNode.position = SCNVector3(x:selectedNode.position.x, y:selectedNode.position.y, z:selectedNode.position.z - Float(translation.x / 100))
            }
            
            gestureRecognize.setTranslation(CGPoint.zero, in: gestureRecognize.view!)
        } else if gestureRecognize.state == .ended {
            print(selectedNode.position)
        }
    }
    
    @objc func panGesturePlanarMove(gestureRecognize: UIPanGestureRecognizer) {
        if gestureRecognize.state == .changed {
            let translation = gestureRecognize.translation(in: gestureRecognize.view!)
         
            let position = SCNVector3(x:selectedNode.position.x + Float(translation.x / 75), y:selectedNode.position.y - Float(translation.y / 75), z:selectedNode.position.z)
            selectedNode.position = position
            
            gestureRecognize.setTranslation(CGPoint.zero, in: gestureRecognize.view!)
            
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
                        edgeNodes.addChildNode(node.buildLineInTwoPointsWithRotation(from: edge.source.data.position, to: edge.destination.data.position, radius: 0.1, color: .black))

                        edgeArray.append(edge)
                    }
                }
            }

            scnScene.rootNode.addChildNode(edgeNodes)
            vertexNodes.removeAllAnimations()
            edgeNodes.removeAllAnimations()
        }
    }
    
    @objc func cleanScene() {
        vertexNodes.removeFromParentNode()
        edgeNodes.removeFromParentNode()
        pathArray.removeAll()
        currentStep = ""
        firstStep = ""
        
        currentLevel += 1
        refreshColorsInCollectionView()
        Timer.scheduledTimer(timeInterval: TimeInterval(1.5), target: self, selector: #selector(setupLevel), userInfo: nil, repeats: false)
    }
}

extension GameViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        //spawnShape()
        //game.updateHUD()
    }
}

extension GameViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let colorCount = activeLevel?.numberOfColorsProvided  {
            return colorCount
        }
        return 3
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 60, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! ColorButtonCollectionViewCell
        
        guard let hamiltonian = activeLevel?.hamiltonian else {
            return cell
        }
        
        cell.checkbox.isHidden = hamiltonian ? true : false
        cell.undoImage.isHidden = hamiltonian ? false : true
        cell.backgroundColor = hamiltonian ? walkColor : kColors[indexPath.row]
        cell.layer.cornerRadius = cell.frame.size.width / 2
        cell.layer.borderWidth = 2
        cell.checkbox.stateChangeAnimation = .expand(.fill)

        if selectedColorIndex == indexPath.row {
            cell.checkbox.setCheckState(.checked, animated: true)
            cell.layer.borderColor = UIColor.customWhite().cgColor
            GraphAnimation.addPulse(to: cell)
        } else {
            cell.checkbox.setCheckState(.unchecked, animated: true)
            cell.layer.borderColor = kColors[indexPath.row].darker()?.cgColor
            cell.layer.removeAllAnimations()
        }
        cell.checkbox.hideBox = true
        
        return cell
    }
}

extension GameViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let totalCellWidth = 60 * collectionView.numberOfItems(inSection: 0)
        let totalSpacingWidth = 10 * (collectionView.numberOfItems(inSection: 0) - 1)
        
        let leftInset = (collectionView.layer.frame.size.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset
        
        return UIEdgeInsetsMake(0, leftInset, 0, rightInset)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell: ColorButtonCollectionViewCell = collectionView.cellForItem(at: indexPath) as! ColorButtonCollectionViewCell
        
        guard let hamiltonian = activeLevel?.hamiltonian else {
            return
        }
        
        if hamiltonian && pathArray.count > 0 {
            for node in vertexNodes.childNodes {
                if node.geometry?.name! == "\(String(describing: pathArray.last!))" {
                    node.geometry?.materials.first?.diffuse.contents = UIColor.black
                    node.removeAllParticleSystems()
                    
                    if let _ = activeLevel?.adjacencyList {
                        activeLevel?.adjacencyList = activeLevel?.adjacencyList!.updateGraphState(id: node.geometry?.name, color: UIColor.black)
                    }
                    
                    _ = pathArray.removeLast()
                    if let newStep = pathArray.last {
                        currentStep = "\(newStep)"
                    }
                    
                    if pathArray.count > 1 {
                        activeLevel?.adjacencyList?.updateCorrectEdges(level: activeLevel, pathArray: pathArray, edgeArray: edgeArray, edgeNodes: edgeNodes)
                    } else {
                        var pos = 0
                        for _ in edgeArray {
                            edgeNodes.childNodes[pos].geometry?.firstMaterial?.diffuse.contents = UIColor.black
                            edgeNodes.childNodes[pos].geometry?.firstMaterial?.emission.contents = UIColor.black
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
        } else {
            selectedColorIndex = indexPath.row
            paintColor = cell.backgroundColor!
            paintColorCollectionView.reloadData()
        }
    }
}
