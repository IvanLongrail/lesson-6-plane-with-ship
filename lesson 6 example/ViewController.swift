//
//  ViewController.swift
//  lesson 6 example
//
//  Created by Иван longrail on 25/03/2019.
//  Copyright © 2019 Иван longrail. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.debugOptions = [.showWorldOrigin, .showFeaturePoints]
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
}

// MARK: - ...ARSCNViewDelegate
extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let anchor = anchor as? ARPlaneAnchor else { return }
        node.addChildNode(createFloor(planeAnchor: anchor))
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor ) {
        guard let anchor = anchor as? ARPlaneAnchor else { return }
        guard node.childNodes.first != nil else { return }
        guard let planeNode = node.childNodes.first?.childNodes.first else { return }
        guard let _ = planeNode.geometry as? SCNPlane else { return }
        guard planeNode.name == "Plane" else { return }
        
        updatePlaneNode(with: planeNode, for: anchor)
    }
}


// MARK: - ...Custom methods
extension ViewController {
    func createFloor(planeAnchor: ARPlaneAnchor) -> SCNNode {
        let extent = planeAnchor.extent
        
        let node = SCNNode()
        
        let planeNode = SCNNode()
        planeNode.name = "Plane"
        let plane = SCNPlane(width: CGFloat(extent.x), height: CGFloat(extent.z))
        plane.firstMaterial?.diffuse.contents = UIColor.blue
        planeNode.geometry = plane
        
        planeNode.eulerAngles.x = -.pi / 2
        planeNode.opacity = 0.25
        node.addChildNode(planeNode)

        let shipScene = SCNScene(named: "art.scnassets/ship.scn")
        let shipNode = shipScene?.rootNode.childNodes.first
        shipNode?.scale = SCNVector3(0.1, 0.1, 0.1)
        node.addChildNode(shipNode!)
        
        return node
    }
    
    func updatePlaneNode(with planeNode: SCNNode, for anchor: ARPlaneAnchor ) {
        planeNode.position = SCNVector3(anchor.center.x, 0, anchor.center.z)
        let extent = anchor.extent
        let plane = planeNode.geometry as! SCNPlane
        plane.width = CGFloat(extent.x)
        plane.height = CGFloat(extent.z)
    }
}
