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
    var worldObjects: [ModelEntity] = []
    
    // renders to the ios display
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // create anchor entity
        // this object will provide a central 'tether' to keep everything in AR worldspace
        let anchor = AnchorEntity(plane: .horizontal, minimumBounds: [0.1, 0.1]); // 1 meters squared
        arView.scene.addAnchor(anchor);
        arView.environment.sceneUnderstanding.options.insert(.physics);
     //   arView.environment.sceneUnderstanding.options.insert(.occlusion);
     //   arView.debugOptions.insert(.showSceneUnderstanding);
        // Loads the meshes and add it to an array
        worldObjects = loadBasketballMesh();
        
        // renders models to the app
        for model in worldObjects {
            anchor.addChild(model);
        }
        let pan = UIPanGestureRecognizer(target: self, action: #selector(executePan))
        view.addGestureRecognizer(pan)
        
    }
    
    
    private func loadBasketballMesh() -> [ModelEntity] {
        var worldObjects: [ModelEntity] = [];
        
        // generate sphere mesh and mesh material
        let basketballMesh = MeshResource.generateSphere(radius: 0.242);
        let basketballMaterial = SimpleMaterial(color: .orange, isMetallic: false);
        
        // assign mesh to ModelEntity object
        let basketballModel = ModelEntity(mesh: basketballMesh, materials: [basketballMaterial]);
        do {
            let hoopModel: ModelEntity;
            try hoopModel = ModelEntity.loadModel(named: "basketball_hoop.usdz");
            let sizeScalar = SIMD3<Float>(0.05, 0.05, 0.05)
            hoopModel.setScale(sizeScalar, relativeTo: nil);
            hoopModel.generateCollisionShapes(recursive: true);
            hoopModel.physicsBody = .init();
            hoopModel.physicsBody?.mode = .static;
            worldObjects.append(hoopModel);
        } catch BasketballError.runtimeError("File Not Found") {
            print("Basketball hoop model not found");
        } catch {
            print("Unexpected errors");
        }
        
        // generate collision and physics object of ball
        basketballModel.generateCollisionShapes(recursive: true)
        basketballModel.physicsBody = .init();
        basketballModel.physicsBody?.mode = .static;
        
        let groundPlane = generateGroundPlane()
        
        worldObjects.append(basketballModel);
        worldObjects.append(groundPlane);
        
                                 // X   Y   Z
        worldObjects[0].position = [0, 1, -10]; // hoop
        worldObjects[1].position = [0, 0, -0.1]; // basketball
        worldObjects[2].position = [0, -2, -5]; // plane
        
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
            shootBall(velocity: velocity)
        }
        
    }
    func shootBall(velocity: CGPoint) {
        let force = SIMD3<Float>.init(Float(velocity.x/1000),Float(sqrt(pow(velocity.x,2)+pow(velocity.y,2))/500),Float(velocity.y/1000));
        if(worldObjects[1].physicsBody?.mode == .static){
            worldObjects[1].physicsBody?.mode = .dynamic;
        }
        worldObjects[1].applyLinearImpulse(force, relativeTo: nil);
    }
    
    private func generateGroundPlane() -> ModelEntity {
        let groundMesh = MeshResource.generatePlane(width: 10, depth: 20);
        let groundMat = SimpleMaterial(color: .lightGray, isMetallic: true);
        let groundPlaneModel = ModelEntity(mesh: groundMesh, materials: [groundMat]);
        
        groundPlaneModel.generateCollisionShapes(recursive: true)
        groundPlaneModel.physicsBody = .init();
        groundPlaneModel.physicsBody?.mode = .static;
        
        
        return groundPlaneModel;
    }
}

enum BasketballError: Error {
    case runtimeError(String)
}
