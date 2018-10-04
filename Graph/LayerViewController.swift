//
//  LayerViewController.swift
//  Graph
//
//  Created by Fraser King on 2018-08-28.
//  Copyright © 2018 Fraser King. All rights reserved.
//

import UIKit

private let reuseIdentifier = "LayerCell"

class LayerViewController: UIViewController {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var prevButton: UIButton!
    @IBOutlet var backButtonBackgroundView: UIView!
    @IBOutlet var backButtonBorderView: UIView!
    @IBOutlet var backButtonBorderBackgroundView: UIView!
    @IBOutlet var nextButtonBackgroundView: UIView!
    @IBOutlet var nextButtonBorderView: UIView!
    @IBOutlet var nextButtonBorderBackgroundView: UIView!
    var parentController: LevelSelectViewController!
    var firstLoad: Bool = true
    let disabledAlpha: CGFloat = 0.35
    var selectedLayer: Int = UserDefaultsInteractor.getCurrentLayer()
    
    // Hotload Info:
    var currentPosition = UserDefaultsInteractor.getCurrentLayer()
    var layers: [Layer]! = Layers.getGameLayers()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(UINib(nibName: "LevelLayerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.clear
        collectionView.layer.masksToBounds = false
        collectionView.alpha = 0
        collectionView.isScrollEnabled = false
        collectionView.scrollToItem(at:IndexPath(item: currentPosition, section: 0), at: .centeredHorizontally, animated: false)
        
        nextButton.alpha = 0
        prevButton.alpha = 0
        backButtonBackgroundView.alpha = 0
        backButtonBorderBackgroundView.alpha = 0
        backButtonBorderView.alpha = 0
        nextButtonBorderView.alpha = 0
        nextButtonBackgroundView.alpha = 0
        nextButtonBorderBackgroundView.alpha = 0
        
        GraphAnimation.delayWithSeconds(0.2) {
            UIView.animate(withDuration: 1) {
                self.collectionView.alpha = 1
                self.nextButton.alpha = 1
                self.prevButton.alpha = 1
                self.backButtonBackgroundView.alpha = self.currentPosition == 0 ? self.disabledAlpha : 1
                self.backButtonBorderBackgroundView.alpha = self.currentPosition == 0 ? self.disabledAlpha : 1
                self.backButtonBorderView.alpha = self.currentPosition == 0 ? self.disabledAlpha : 1
                self.nextButtonBorderView.alpha = self.currentPosition == 4 ? self.disabledAlpha : 1
                self.nextButtonBackgroundView.alpha = self.currentPosition == 4 ? self.disabledAlpha : 1
                self.nextButtonBorderBackgroundView.alpha = self.currentPosition == 4 ? self.disabledAlpha : 1
            }
        }
        
        backButtonBackgroundView.addCustomMaskToViews(border: backButtonBorderView, borderMaskName: "left_front", backMaskName: "left_back")
        nextButtonBackgroundView.addCustomMaskToViews(border: nextButtonBorderView, borderMaskName: "right_front", backMaskName: "right_back")
        
        GraphAnimation.delayWithSeconds(0.5) {
            UIColor.insertModalButtonGradient(for: self.backButtonBorderBackgroundView)
            UIColor.insertModalButtonGradientReverse(for: self.nextButtonBorderBackgroundView)
        }
        
    }
    
    func updatePosition() {
        if let cell = collectionView.cellForItem(at: IndexPath(item: currentPosition, section: 0)) as? LevelLayerCollectionViewCell {
            cell.setIdleAnimation(gifName: getGifName(for: currentPosition))
        }
        collectionView.scrollToItem(at: IndexPath(item: currentPosition, section: 0), at: .centeredHorizontally, animated: true)
        nextButton.isUserInteractionEnabled = false
        prevButton.isUserInteractionEnabled = false
        GraphAnimation.delayWithSeconds(0.2) {
            self.nextButton.isUserInteractionEnabled = true
            self.prevButton.isUserInteractionEnabled = true
        }
    }
    
    func enableButton(button: UIButton, direction: String) {
        button.isEnabled = true
        
        if direction == "next" {
            self.backButtonBackgroundView.alpha = 1
            self.backButtonBorderBackgroundView.alpha = 1
            self.backButtonBorderView.alpha = 1
        } else {
            self.nextButtonBackgroundView.alpha = 1
            self.nextButtonBorderBackgroundView.alpha = 1
            self.nextButtonBorderView.alpha = 1
        }
    }
    
    func disableButton(button: UIButton, direction: String) {
        button.isEnabled = false
        
        if direction == "back" {
            self.backButtonBackgroundView.alpha = disabledAlpha
            self.backButtonBorderBackgroundView.alpha = disabledAlpha
            self.backButtonBorderView.alpha = disabledAlpha
        } else {
            self.nextButtonBackgroundView.alpha = disabledAlpha
            self.nextButtonBorderBackgroundView.alpha = disabledAlpha
            self.nextButtonBorderView.alpha = disabledAlpha
        }
    }
    
    func getGifName(for layer: Int) -> String {
        if UserDefaultsInteractor.checkIfLayerIsLocked(for: layer) {
            return "locked"
        }
        
        return "aleph_Idle"
    }

    @IBAction func nextPressed() {
        if currentPosition < 4 {
            GraphAnimation.addExplode(to: self.nextButtonBackgroundView)
            GraphAnimation.addExplode(to: self.nextButtonBorderView)
            currentPosition += 1
            updatePosition()
            enableButton(button: prevButton, direction: "back")
            
            if currentPosition == 4 {
                self.disableButton(button: nextButton, direction: "next")
            } else {
                self.enableButton(button: nextButton, direction: "next")
            }
        }
    }
    
    @IBAction func prevPressed() {
        if currentPosition > 0 {
            GraphAnimation.addExplode(to: self.backButtonBackgroundView)
            GraphAnimation.addExplode(to: self.backButtonBorderView)
            currentPosition -= 1
            updatePosition()
            enableButton(button: nextButton, direction: "next")
            
            if currentPosition == 0 {
                self.disableButton(button: prevButton, direction: "back")
            } else {
                self.enableButton(button: prevButton, direction: "back")
            }
        }
    }
    
    @IBAction func settingsPressed() {
        print("settingsPressed")
    }
    
    @IBAction func layerPressed() {
        parentController.layerButtonBackgroundView.layer.removeAllAnimations()
        parentController.layerButtonBorderView.layer.removeAllAnimations()
        GraphAnimation.delayWithSeconds(0.01) {
            GraphAnimation.addExplode(to: self.parentController.layerButtonBackgroundView)
            GraphAnimation.addExplode(to: self.parentController.layerButtonBorderView)
        }
        
        unwind()
    }

    func unwind() {
        UIView.animate(withDuration: 0.5, animations: {
            self.collectionView.alpha = 0
            self.prevButton.alpha = 0
            self.nextButton.alpha = 0
            self.backButtonBackgroundView.alpha = 0
            self.backButtonBorderBackgroundView.alpha = 0
            self.backButtonBorderView.alpha = 0
            self.nextButtonBorderView.alpha = 0
            self.nextButtonBackgroundView.alpha = 0
            self.nextButtonBorderBackgroundView.alpha = 0
        }) { (finished) in
            self.performSegue(withIdentifier: "unwindToLevelSelect", sender: self)
        }
    }
}

extension LayerViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 240, height: 275)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! LevelLayerCollectionViewCell
        cell.backgroundColor = .white
        
        if selectedLayer == indexPath.row {
            cell.containerBackgroundView.addBorderHighlight()
            GraphAnimation.delayWithSeconds(0.5) {
                GraphAnimation.addCustomPulse(to: cell, size: 1.03, duration: 1)
            }
        } else {
            cell.layer.removeAllAnimations()
            cell.containerBackgroundView.addBorder()
        }
        
        UIColor.insertGradient(for: cell.containerView, color1: layers[indexPath.row].colors[0], color2: layers[indexPath.row].colors[1])
        UIColor.setupBackgrounds(view: cell.containerView, skView: cell.skView)
        cell.title.text = layers[indexPath.row].name
        cell.setPercentComplete(percentage: UserDefaultsInteractor.getCompletionPercentFromLevelStates(for: indexPath.row), locked: UserDefaultsInteractor.checkIfLayerIsLocked(for: indexPath.row))
        cell.layoutIfNeeded()
        if firstLoad && self.currentPosition == indexPath.row {
            cell.setAppearAnimation()
            firstLoad = false
        } else {
            cell.setIdleAnimation(gifName: getGifName(for: indexPath.row))
        }
    
        cell.addDropShadow()
            
        return cell
    }
}

extension LayerViewController: UICollectionViewDelegate {

    // MARK: UICollectionViewDelegate

    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }
     
     */

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !UserDefaultsInteractor.checkIfLayerIsLocked(for: indexPath.row) {
            if let cell = collectionView.cellForItem(at: indexPath) {
                GraphAnimation.addExplode(to: cell)
                GraphAnimation.delayWithSeconds(0.2) {
                    UserDefaultsInteractor.setCurrentLayer(pos: indexPath.row)
                    self.unwind()
                }
            }
        } else {
            if let cell = collectionView.cellForItem(at: indexPath) {
                GraphAnimation.addShake(to: cell)
            }
        }
    }
}
