//
//  ViewModel.swift
//  ARMeasure
//
//  Created by 福山帆士 on 2020/08/04.
//  Copyright © 2020 福山帆士. All rights reserved.
//

import Foundation
import CoreGraphics
import RxSwift
import RxCocoa
import ARKit

final class ViewModel {
    
    let resultPublish = PublishRelay<ARHitTestResult>()
    
    private var startNode: SCNNode?
    var endNode: SCNNode?
    var lineNode: SCNNode?

    func createNodeForTransform(result: ARHitTestResult, sceneView: SCNView) {
        let hitPos = result.worldTransform.position()
        
        if let startNode = startNode {
            endNode = putSphere(at: hitPos, color: UIColor.green, sceneView: sceneView)
            guard let endNode = endNode else { fatalError() }
            let distance = (endNode.position - startNode.position).length()
            lineNode = drawLine(from: startNode, to: endNode, length: distance)
        }else {
            startNode = putSphere(at: hitPos, color: UIColor.blue, sceneView: sceneView)
        }
    }
    
    private func putSphere(at pos: SCNVector3, color: UIColor, sceneView: SCNView) -> SCNNode {
        let node = SCNNode.sphereNode(color: color)
        sceneView.scene?.rootNode.addChildNode(node)
        node.position = pos
        return node
    }
    
    private func drawLine(from: SCNNode, to: SCNNode, length: Float) -> SCNNode {
           let lineNode = SCNNode.lineNode(length: CGFloat(length), color: UIColor.red)
           from.addChildNode(lineNode)
           lineNode.position = SCNVector3Make(0, 0, -length / 2)
           from.look(at: to.position)
           return lineNode
       }
}
