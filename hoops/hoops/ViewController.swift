//
//  ViewController.swift
//  hoops
//
//  Created by Lucas Saechao
//  Created by Ryan Kwong
//  Created by Patrik Martin
//
//  on 2/19/21.
//

import UIKit
import RealityKit

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    var worldObjects: [ModelEntity] = []
    var ballCount = 0;
    // renders to the ios display
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // create anchor entity
        // this object will provide a central 'tether' to keep everything in AR worldspace
        let anchor = AnchorEntity(plane: .horizontal, minimumBounds: [0.1, 0.1]); // 1 meters squared
        anchor.name = "RootAnchor"
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
        
        let button = drawBallButton();
        view.addSubview(button);
        
    }
    
    
    private func loadBasketballMesh() -> [ModelEntity] {
        var worldObjects: [ModelEntity] = [];
        
        let basketballModel = generateBall();
        do {
            let hoopModel: ModelEntity;
            let loopModel: ModelEntity;
            try hoopModel = ModelEntity.loadModel(named: "basketball_hoop.usdz");
            try loopModel = ModelEntity.loadModel(named: "loop.usdz")
            //let sizeScalar = SIMD3<Float>(0.05, 0.05, 0.05)
            hoopModel.name = "Hoop";
            //hoopModel.setScale(sizeScalar, relativeTo: nil);
            hoopModel.generateCollisionShapes(recursive: true);
            hoopModel.physicsBody = .init();
            hoopModel.physicsBody?.mode = .static;
            
            loopModel.name = "Loop";
            //loopModel.setScale(sizeScalar, relativeTo: nil);
            loopModel.generateCollisionShapes(recursive: true);
            loopModel.physicsBody = .init();
            loopModel.physicsBody?.mode = .static;
            //hoopModel.addChild(loopModel);
            worldObjects.append(hoopModel);
            worldObjects.append(loopModel);
            
        } catch BasketballError.runtimeError("File Not Found") {
            print("Basketball hoop model not found");
        } catch {
            print("Unexpected errors");
        }
        
        let groundPlane = generateGroundPlane()
        
        worldObjects.append(groundPlane);
        
        worldObjects.append(basketballModel);
        
                                 // X   Y   Z
        worldObjects[0].position = [0, 0, -15]; // hoop
        worldObjects[1].position = [0, 5,-15]; // loop
        worldObjects[2].position = [0, -2, -5]; // plane
        worldObjects[3].position = [0, 1.5, -0.5]; // basketball
        
        
        return worldObjects;
    }
    
    private func generateBall() -> ModelEntity {
        // generate sphere mesh and mesh material
        let basketballMesh = MeshResource.generateSphere(radius: 0.242);
        let basketballMaterial = SimpleMaterial(color: .orange, isMetallic: false);
        
        // assign mesh to ModelEntity object
        let basketballModel = ModelEntity(mesh: basketballMesh, materials: [basketballMaterial]);
        
        // generate collision and physics object of ball
        basketballModel.generateCollisionShapes(recursive: true)
        basketballModel.physicsBody = .init();
        basketballModel.physicsBody?.mode = .static;
        
        basketballModel.name = "Ball" + String(ballCount);
        ballCount += 1;
        
        return basketballModel;
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
        let force = SIMD3<Float>.init(
            Float(velocity.x/1000),
            Float(sqrt(pow(velocity.x,2) + pow(velocity.y,2))/500),
            Float(velocity.y/1000)
        );
        
        if(worldObjects[3].physicsBody?.mode == .static){
            worldObjects[3].physicsBody?.mode = .dynamic;
        }
        
        worldObjects[3].applyLinearImpulse(force, relativeTo: nil);
    }
    
    private func generateGroundPlane() -> ModelEntity {
        let groundMesh = MeshResource.generatePlane(width: 10, depth: 20);
        let groundMat = SimpleMaterial(color: .lightGray, isMetallic: true);
        let groundPlaneModel = ModelEntity(mesh: groundMesh, materials: [groundMat]);
        
        groundPlaneModel.generateCollisionShapes(recursive: true)
        groundPlaneModel.physicsBody = .init();
        groundPlaneModel.physicsBody?.mode = .static;
        
        groundPlaneModel.name = "GroundPlane";
        
        return groundPlaneModel;
    }
    
    /*
     * Returns a button labeled "Reset ball position"
     */
    func drawBallButton() -> UIButton {
        let ballButton = UIButton();
        let screenWidth = UIScreen.main.bounds.width;
        let screenHeight = UIScreen.main.bounds.height;
        ballButton.setTitle("Reset Ball Position", for: .normal);
        ballButton.setTitleColor(UIColor.blue, for: .normal)
        ballButton.frame = CGRect(x: 15, y: -50, width: 300, height: 500)
        ballButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        ballButton.center = CGPoint(x: screenWidth / 2.0, y: screenHeight - 100);
        
        return ballButton;
    }
    
    /*
     * Generate a new ball and pass control to it.
     * Remove the last ball from the scenegraph
     */
    @objc func buttonPressed(sender: UIButton!) {
        print("Reset ball pressed")
        
        let ballName = "Ball" + String(ballCount - 1);
        let ball = generateBall();
        ball.position = [0, 1.5, -0.5]; // basketball
        worldObjects[3] = ball; // set control to current ball
        // print(arView.scene.anchors);
        
        let anchor = arView.scene.findEntity(named: "RootAnchor")
        
        anchor?.removeChild((anchor?.findEntity(named: ballName))!);
        anchor?.addChild(ball);
    }
    
}

enum BasketballError: Error {
    case runtimeError(String)
}
