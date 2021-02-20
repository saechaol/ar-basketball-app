//
//  ViewController.swift
//  hoops
//
//  Created by 세차오 루카스 on 2/19/21.
//

import UIKit
import RealityKit
import ARKit
import SceneKit

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create anchor entity
        // this object will provide a central 'tether' to keep everything in AR worldspace
        let anchor = AnchorEntity(plane: .horizontal, minimumBounds: [0.1, 0.1]);
        arView.scene.addAnchor(anchor);
        
        let worldObjects: [Entity] = loadBasketballMesh();
        
        for model in worldObjects {
            anchor.addChild(model);
        }
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(executePan))
        view.addGestureRecognizer(pan)
        
        arView.debugOptions.insert(.showSceneUnderstanding)
        
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
        
        worldObjects[0].position = [0, 0, -200];
        worldObjects[1].position = [0, 1, 0];
        
        return worldObjects;
    }
    
    @objc func executePan(gesture: UIPanGestureRecognizer){
        
        //print("Panning");
        if(gesture.state == .began){
            let start = gesture.location(in: view)
            print("Beginning at:",start.x,start.y)
            
            //let hitResult = view.hitTest(start, options:[:])
        }
        else if(gesture.state == .cancelled){
            print("Cancelled")
        }
        else if(gesture.state == .ended){
            let velocity = gesture.velocity(in: view);
            let x = Double(velocity.x);
            let y = Double(velocity.y);
            let end = gesture.location(in: view)
            var angle = atan2(y,x) * 180.0/Double.pi;
            
            if(angle < 0) {
                angle += 360.0;
            }
            print("Angle:",angle)
            print("Velocity:",velocity)
            print("Ending at:",end.x,end.y)
        }
        
        
        
    }

}

enum BasketballError: Error {
    case runtimeError(String)
}
