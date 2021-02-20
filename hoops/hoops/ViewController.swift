//
//  ViewController.swift
//  hoops
//
//  Created by 세차오 루카스 on 2/19/21.
//

import UIKit
import RealityKit

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    var worldObjects: [Entity]
    
    // renders to the ios display
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // create anchor entity
        // this object will provide a central 'tether' to keep everything in AR worldspace
        let anchor = AnchorEntity(plane: .horizontal, minimumBounds: [0.1, 0.1]); // 1 meters squared
        arView.scene.addAnchor(anchor);
        arView.environment.sceneUnderstanding.options.insert(.physics);
        //arView.environment.sceneUnderstanding.options.insert(.occlusion);
        arView.debugOptions.insert(.showSceneUnderstanding);
        // Loads the meshes and add it to an array
        worldObjects = loadBasketballMesh();
        
        // renders models to the app
        for model in worldObjects {
            anchor.addChild(model);
        }
        
    }
    
    
    private func loadBasketballMesh() -> [Entity] {
        var worldObjects: [Entity] = [];
        
        // generate sphere mesh and mesh material
        let basketballMesh = MeshResource.generateSphere(radius: 0.242);
        let basketballMaterial = SimpleMaterial(color: .orange, isMetallic: false);
        
        // assign mesh to ModelEntity object
        let basketballModel = ModelEntity(mesh: basketballMesh, materials: [basketballMaterial]);
        do {
            let hoopModel: Entity;
            try hoopModel = ModelEntity.load(named: "basketball_hoop.usdz");
            hoopModel.generateCollisionShapes(recursive: true)
            worldObjects.append(hoopModel);
        } catch BasketballError.runtimeError("File Not Found") {
            print("Basketball hoop model not found");
        } catch {
            print("Unexpected errors");
        }
        
        // generate collision and physics object of ball
        basketballModel.generateCollisionShapes(recursive: true)
        basketballModel.physicsBody = .init();
        basketballModel.physicsBody?.mode = .dynamic;
        
        worldObjects.append(basketballModel);
        
                                 // X   Y   Z
        worldObjects[0].position = [0, -1, -200]; // hoop
        worldObjects[1].position = [0, 1.5, 0]; // basketball
        
        return worldObjects;
    }
    
    func shootBall() {
        //arView.scene.
        let force = CGVector.init()
        worldObjects[1]?.physicsBody?.applyForce()
        
    }
}

enum BasketballError: Error {
    case runtimeError(String)
}
