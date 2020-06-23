//
//  CameraViewController.swift
//  Wheels
//
//  Created by Alexandr Bukharin on 23.06.2020.
//  Copyright © 2020 ds. All rights reserved.
//

import UIKit
import ARKit

class CameraViewController: UIViewController {
	
	private var sceneView: ARSCNView!

    override func viewDidLoad() {
        super.viewDidLoad()

		navigationController?.isNavigationBarHidden = true
		addSceneView()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		let configuration = ARWorldTrackingConfiguration()
		configuration.planeDetection = .vertical
		sceneView.session.run(configuration)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
	
	private func addSceneView() {
		view.addSubview(sceneView)
		sceneView.snp.makeConstraints() {
			$0.edges.equalToSuperview()
		}
		sceneView.delegate = self
		// Show statistics such as fps and timing information
		// sceneView.showsStatistics = true
		sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
		sceneView.autoenablesDefaultLighting = true
		
		let scene = SCNScene()
		
		sceneView.scene = scene
		sceneView.scene.physicsWorld.contactDelegate = self
	}
}

extension CameraViewController: ARSCNViewDelegate {
	
}

extension CameraViewController: SCNPhysicsContactDelegate {
	
}
