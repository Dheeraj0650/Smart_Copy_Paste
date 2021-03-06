//
//  ViewController.swift
//  Smart_Copy_Paste
//
//  Created by KOTTE V S S DHEERAJ on 08/06/20.
//  Copyright © 2020 KOTTE V S S DHEERAJ. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Alamofire

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var image:UIImage?
    var text:String = ""
    var flag = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        if !flag{
           text_AR_view(text)
        }
        else{
           image_AR_view()
        }
    }
   
    func image_AR_view(){
        let height = image!.size.height
        let width = image!.size.width
        let pasteboard = UIPasteboard.general
        pasteboard.image = image!
        print(width/1000,height/1000)
        let planeGeometry = SCNPlane(width:width/1000,height: height/1000)
        let material = SCNMaterial()
        material.diffuse.contents = image!
        planeGeometry.materials = [material]
        let node = SCNNode()
        node.position = SCNVector3(x:0.05, y:0.05, z:-0.7)
        node.geometry = planeGeometry
        sceneView.scene.rootNode.addChildNode(node)
        sceneView.autoenablesDefaultLighting = true
        
    }

    
    func text_AR_view(_ text:String){
        
        let pasteboard = UIPasteboard.general
        pasteboard.string = text
        let text = SCNText(string: text, extrusionDepth: 2)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.systemBlue
        text.materials = [material]
        let node = SCNNode()
        node.position = SCNVector3(x:0.0155, y:0.0, z:-0.2)
        node.scale = SCNVector3(x:0.001, y:0.001, z:0.001)
        node.geometry = text
        sceneView.scene.rootNode.addChildNode(node)
        sceneView.autoenablesDefaultLighting = true
        
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
