//
//  RendererScene.swift
//  SoftRenderer
//
//  Created by Richard Pickup on 23/01/2022.
//

import Foundation
import SwiftUI

class RendererScene: NSObject, ObservableObject {
    @Published var uiImage: UIImage?
    var md2 = MD2Loader()
    private var md2Object: MD2Object3D?
    var camera: Camera?
    var camTrans: Matrix?
    var persp: Matrix?
    var screen: Matrix?
    
    var deg: Float = 0
    var rasterizer: Rasterizer?
    var framebuffer: FrameBuffer?
    
    
    let ambientLight = AmbientLight(red: 25, green: 25, blue: 25)
    let directionalLight = DirectionalLight(red:  255, green: 255, blue: 255, direction: Vector(0,  -1, -1, 0))
    let directionalLight2 = DirectionalLight(red: 255, green: 0, blue: 0, direction: Vector(0, 1, 0, 0))
    
    func setup(width: Float, height: Float) {
        camera = Camera(position: Point(0, 0, 80, 1),
                        direction: Vector(0,0,0,0),
                        nearDistance: -10,
                        farDistance: -500,
                        fov: 90,
                        width: width,
                        height: height)
        
        camTrans = camera?.buildCameraTransform()
        persp = camera?.buildPerspective()
        screen = camera?.buildScreen()
        
        md2Object = md2.loadModel(filename: "tris", textureName: "dragon_blue")
        
        framebuffer = FrameBuffer(width: Int(width), height: Int(height), color: Color(r: 0, g: 0, b: 0, a: 255))
        
        if let framebuffer = framebuffer {
            rasterizer = Rasterizer(numLines: framebuffer.height,
                                    frameBuffer: framebuffer)
        }
    }
    
    func update() {
        
        //    DispatchQueue.global().async {
        self.deg += 1
        if self.deg > 359 {
            self.deg = 0
        }
        let rad = self.deg * 0.0174533
        
        self.md2Object?.renderAnimation(startFrame: 0, endFrame: 39, interpolation: 0.5)
        
        let rot = Matrix.rotation(rotX: 0, rotY: Float(rad), rotZ: 0)
        
        self.md2Object?.renderModel.transform(transMatrix: rot, type: .localToTranslated)
        
        self.md2Object?.renderModel.calculateBackFacing(cam: self.camera!)
        self.md2Object?.renderModel.calculateVertexNormals()
        
        self.md2Object?.renderModel.calculateAmbientLighting(lights: [self.ambientLight])
        self.md2Object?.renderModel.calculateDirectionalLighting(lights: [self.directionalLight, self.directionalLight2])
        
        self.md2Object?.renderModel.transform(transMatrix: self.camTrans!, type: .translated)
        
        self.md2Object?.renderModel.sort()
        
        self.md2Object?.renderModel.transform(transMatrix: self.persp!, type: .translated)
        
        self.md2Object?.renderModel.dehomogenise()
        
        self.md2Object?.renderModel.transform(transMatrix: self.screen!, type: .translated)
        
        if let object = self.md2Object?.renderModel,
           let framebuffer = self.framebuffer {
            framebuffer.clear(Color(r: 100, g: 149, b: 237))
            self.rasterizer?.drawsolid(drawObject: object)
            self.uiImage = UIImage(frameBuffer: framebuffer)
        }
        
    }
}
