//
//  ViewController.swift
//  ARMeasure
//
//  Created by 福山帆士 on 2020/08/04.
//  Copyright © 2020 福山帆士. All rights reserved.
//

import UIKit
import ARKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    
    private var viewModel = ViewModel()
    private let disposeBug = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.scene = SCNScene()
        
        subscribe()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let pos: CGPoint = touch.location(in: sceneView)
        if let endNode = viewModel.endNode {
            endNode.removeFromParentNode()
            
            let lineNode = viewModel.lineNode
            lineNode?.removeFromParentNode()
        }
        
        hitTest(pos: pos)
    }
    
    private func hitTest(pos: CGPoint) {
        let results = sceneView.hitTest(pos, types: [.existingPlane])
        guard let result = results.first else { return }
        
        increment(result: result)
    }
    
    func increment(result: ARHitTestResult) {
        viewModel.resultPublish.accept(result)
    }
    
    func subscribe() {
        viewModel.resultPublish.asObservable().subscribe(onNext: { [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.createNodeForTransform(result: result, sceneView: strongSelf.sceneView)
            }).disposed(by: disposeBug)
    }
}

extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        planeAnchor.addPlaneNode(on: node, contents: UIColor.blue.withAlphaComponent(0.1))
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        planeAnchor.updatePlaneNode(on: node)
    }
}
