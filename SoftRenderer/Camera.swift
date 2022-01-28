//
//  Camera.swift
//  SoftRenderer
//
//  Created by Richard Pickup on 20/01/2022.
//

import Foundation

let PI: Double = 3.1415926535897932384626433832795;
struct Camera {
    let direction: Vector
    let position: Point
    let nearZ: Float
    let farZ: Float
    let viewDistance: Float
    let fieldOfView: Float
    let aspectRatio: Float
    let viewportWidth: Float
    let viewportHeight: Float
    
    init(position: Point,
         direction: Vector,
         nearDistance: Float,
         farDistance: Float,
         fov: Float,
         width: Float,
         height: Float) {
        self.position = position
        self.direction = direction
        self.nearZ = nearDistance
        self.farZ = farDistance
        self.fieldOfView = Float(Double(fov) * PI / 180)
        self.viewportWidth = width
        self.viewportHeight = height
        self.aspectRatio = width / height
        let viewPlaneWidth: Float = 2.0
        self.viewDistance = tanf((self.fieldOfView / 2.0) * (viewPlaneWidth * 0.5))
    }
    
    func buildCameraTransform() -> Matrix {
        let translate = Matrix.translation(transX: -position.x,
                                           transy: -position.y,
                                           transZ: -position.z)
        
        let rotate = Matrix.rotation(rotX: -direction.x,
                                     rotY: -direction.y,
                                     rotZ: -direction.z)
        return translate * rotate
            
    }
    
    func buildPerspective() -> Matrix {
        let transform = Matrix(viewDistance, 0, 0, 0,
                               0, viewDistance * aspectRatio, 0, 0,
                               0, 0, 1, 0,
                               0, 0, -1, 0)
        
        return transform
    }
    
    func buildScreen() -> Matrix {
        let scaleWidth = (viewportWidth * 0.5) - 0.5
        let scaleHeight = (viewportHeight * 0.5) - 0.5
        
        let transform = Matrix(scaleWidth, 0,            0, scaleWidth,
                               0,          -scaleHeight, 0, scaleHeight,
                               0,          0,            1, 0,
                               0,          0,            0, 1)
        
        return transform
        
    }
    
}
