//
//  ViewController.swift
//  ARFaceTrackDemo
//
//  Created by Mohammed Azeem Azeez on 4/23/20.
//  Copyright © 2020 Blue Mango Global. All rights reserved.
//

import UIKit
import ARKit



class ViewController: UIViewController {
    
    private let planeWidth: CGFloat = 0.13
    private let planeHeight: CGFloat = 0.06
    private let nodeYPosition: CGFloat = 0.022
    private let minPositionDistance: CGFloat = 0.0025
    private let minScalling: CGFloat = 0.025
    private let cellIdentifier: String = "GlassesCollectionViewCell"
    private let glassesCount = 4
    private let animationDuration: TimeInterval = 0.25
    private let cornurRadius: CGFloat = 10
    
  
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var glassesView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var calibrationView: UIView!
    @IBOutlet weak var calibrationTransparentView: UIView!
    @IBOutlet weak var collectionBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var calibrationBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionButton: UIButton!
    @IBOutlet weak var calibrationButton: UIButton!
    @IBOutlet weak var alertLabel: UILabel!
    
    private let glaccessPlane = SCNPlane(width: 0.13, height: 0.06)
    private let glaccessNode = SCNNode()
    private var scalling:CGFloat = 1
    
    private var isCollectionOpened = false{
        didSet{
            updateCollectionPosition()
        }
    }
    private var isCalibrationOpened = false{
        didSet{
            updateCalibrationPosition()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard ARFaceTrackingConfiguration.isSupported else {
        alertLabel.text = "Face tracking is not supported on this device"
        return
        }
        sceneView.delegate = self
      
        setupCollectionView()
        setupCalibrationView()
    }
    override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
         
         let configuration = ARFaceTrackingConfiguration()
         sceneView.session.run(configuration)
     }
     
     override func viewWillDisappear(_ animated: Bool) {
         super.viewWillDisappear(animated)
         
         sceneView.session.pause()
     }
     
    private func setupCollectionView(){
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionBottomConstraint.constant = -glassesView.bounds.size.height
    }
    
    private func setupCalibrationView(){
        calibrationTransparentView.layer.cornerRadius = cornurRadius
        calibrationBottomConstraint.constant = -calibrationView.bounds.size.height
    }
    
    private func updateGlasses(with index:Int){
        let imageName  = "glasses\(index)"
        glaccessPlane.firstMaterial?.diffuse.contents = UIImage(named: imageName)
    }
    
    private func updateCollectionPosition(){
        collectionBottomConstraint.constant = isCollectionOpened ? 0 : -calibrationView.bounds.size.height
        UIView.animate(withDuration: animationDuration) {
            self.collectionButton.alpha = self.isCollectionOpened ? 0 : 1
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateCalibrationPosition(){
        calibrationBottomConstraint.constant = isCalibrationOpened ? 0 : -glassesView.bounds.size.height
        UIView.animate(withDuration: animationDuration) {
            self.collectionButton.alpha = self.isCalibrationOpened ? 0 : 1
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateSize(){
        glaccessPlane.width = scalling * planeWidth
        glaccessPlane.height = scalling * planeHeight
    }
    
    
    @IBAction func collectionTap(_ sender: UIButton) {
        isCollectionOpened = !isCollectionOpened
    }
    
    @IBAction func CalibrationTap(_ sender: UIButton) {
        isCalibrationOpened = !isCalibrationOpened
    }
    
    @IBAction func sceneARTapped(_ sender: UITapGestureRecognizer) {
        isCalibrationOpened = false
        isCollectionOpened = false
    }
    
    @IBAction func topTap(_ sender: UIButton) {
        glaccessNode.position.y += Float(minPositionDistance)
    }
    
    @IBAction func downTap(_ sender: UIButton) {
        glaccessNode.position.y -= Float(minPositionDistance)
    }
    
    @IBAction func rightTap(_ sender: UIButton) {
        glaccessNode.position.x += Float(minPositionDistance)
    }
    
    @IBAction func leftTap(_ sender: UIButton) {
        glaccessNode.position.x -= Float(minPositionDistance)
    }
    
    @IBAction func farTap(_ sender: UIButton) {
        glaccessNode.position.z += Float(minPositionDistance)
    }
    
    @IBAction func closerTap(_ sender: UIButton) {
        glaccessNode.position.z -= Float(minPositionDistance)
    }
    
    @IBAction func biggerTap(_ sender: UIButton) {
        scalling += minScalling
        updateSize()
    }
    
    @IBAction func smallerTap(_ sender: UIButton) {
        scalling -= minScalling
        updateSize()
    }
    
    
}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let device = sceneView.device else {
            return nil
        }
        
        let faceGeometry = ARSCNFaceGeometry(device: device)
        let faceNode = SCNNode(geometry: faceGeometry)
        faceNode.geometry?.firstMaterial?.transparency = 0
        glaccessPlane.firstMaterial?.isDoubleSided = true
        updateGlasses(with: 0)
        glaccessNode.position.x = faceNode.boundingBox.max.z * 3 / 4
        glaccessNode.position.y = Float(nodeYPosition)
        glaccessNode.geometry = glaccessPlane
        faceNode.addChildNode(glaccessNode)
        
        return faceNode
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor, let faceGeometry = node.geometry as? ARSCNFaceGeometry else {
            return
        }
        
        faceGeometry.update(from: faceAnchor.geometry)
    }
}



extension ViewController :UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return glassesCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! GlassesCollectionViewCell
        let imageName = "glasses\(indexPath.row)"
        cell.setup(with: imageName)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        updateGlasses(with: indexPath.row)
    }
    
}
