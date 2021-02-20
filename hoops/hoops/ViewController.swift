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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create anchor entity
        // this object will provide a central 'tether' to keep everything in AR worldspace
        let anchor = AnchorEntity(plane: .horizontal, minimumBounds: [1.0, 1.0]);
        arView.scene.addAnchor(anchor);
        
        let worldObjects: [Entity] = loadBasketballMesh();
        
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
            worldObjects.append(hoopModel);
        } catch BasketballError.runtimeError("File Not Found") {
            print("Basketball hoop model not found");
        } catch {
            print("Unexpected errors");
        }
        
        
        worldObjects.append(basketballModel);
        
        worldObjects[0].position = [0, 0, 0];
        worldObjects[1].position = [5, 0, 5];
        
        return worldObjects;
    }
    
    
}

enum BasketballError: Error {
    case runtimeError(String)
}
