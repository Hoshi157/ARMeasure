//
//  Extensions.swift
//  ARMeasure
//
//  Created by 福山帆士 on 2020/08/04.
//  Copyright © 2020 福山帆士. All rights reserved.
//

import ARKit

extension matrix_float4x4 {
    func position() -> SCNVector3{
        let mat = SCNMatrix4(self)
        return SCNVector3(mat.m41, mat.m42, mat.m43)
    }
}

extension SCNNode {
    class func sphereNode(color: UIColor) -> SCNNode {
        let geometry = SCNSphere(radius: 0.01)
        geometry.materials.first?.diffuse.contents = color
        return SCNNode(geometry: geometry)
    }
    
    class func lineNode(length: CGFloat, color: UIColor) -> SCNNode {
        let geometry = SCNCapsule(capRadius: 0.004, height: length)
        geometry.materials.first?.diffuse.contents = color
        let line = SCNNode(geometry: geometry)
        
        let node = SCNNode()
        node.eulerAngles = SCNVector3Make(Float.pi/2, 0, 0)
        node.addChildNode(line)
        
        return node
    }
}

extension SCNVector3 {
    func length() -> Float {
        return sqrt(x * x + y * y + z * z)
    }
}

func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x - right.x, left.y - right.y, left.z - right.z)
}

extension ARPlaneAnchor {

@discardableResult
func addPlaneNode(on node: SCNNode, geometry: SCNGeometry, contents: Any) -> SCNNode {
    guard let material = geometry.materials.first else { fatalError() }
    
    if let program = contents as? SCNProgram {
        material.program = program
    } else {
        material.diffuse.contents = contents
    }
    
    let planeNode = SCNNode(geometry: geometry)
    
    DispatchQueue.main.async(execute: {
        node.addChildNode(planeNode)
    })
    
    return planeNode
}

func addPlaneNode(on node: SCNNode, contents: Any) {
    let geometry = SCNPlane(width: CGFloat(extent.x), height: CGFloat(extent.z))
    let planeNode = addPlaneNode(on: node, geometry: geometry, contents: contents)
    planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1, 0, 0)
}
    
    @available(iOS 11.3, *)
        func updatePlaneGeometryNode(on node: SCNNode) {
            DispatchQueue.main.async(execute: {
                guard let planeGeometry = self.findPlaneGeometryNode(on: node)?.geometry as? ARSCNPlaneGeometry else { return }
                planeGeometry.update(from: self.geometry)
            })
        }

        func updatePlaneNode(on node: SCNNode) {
            DispatchQueue.main.async(execute: {
                guard let plane = self.findPlaneNode(on: node)?.geometry as? SCNPlane else { return }
                guard !PlaneSizeEqualToExtent(plane: plane, extent: self.extent) else { return }
                
                plane.width = CGFloat(self.extent.x)
                plane.height = CGFloat(self.extent.z)
            })
        }
    
    func findPlaneNode(on node: SCNNode) -> SCNNode? {
        for childNode in node.childNodes {
            if childNode.geometry as? SCNPlane != nil {
                return childNode
            }
        }
        return nil
    }

    func findShapedPlaneNode(on node: SCNNode) -> SCNNode? {
        for childNode in node.childNodes {
            if childNode.geometry as? ARSCNPlaneGeometry != nil {
                return childNode
            }
        }
        return nil
    }

    @available(iOS 11.3, *)
    func findPlaneGeometryNode(on node: SCNNode) -> SCNNode? {
        for childNode in node.childNodes {
            if childNode.geometry as? ARSCNPlaneGeometry != nil {
                return childNode
            }
        }
        return nil
    }
}

fileprivate func PlaneSizeEqualToExtent(plane: SCNPlane, extent: vector_float3) -> Bool {
    if plane.width != CGFloat(extent.x) || plane.height != CGFloat(extent.z) {
        return false
    } else {
        return true
    }
}
