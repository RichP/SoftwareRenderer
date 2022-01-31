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
    private var md2 = MD2Loader()
    private var md2Object: MD2Object3D?
    private var camera: Camera?
    private var camTrans: Matrix?
    private var persp: Matrix?
    private var screen: Matrix?
    
    private var deg: Float = 0
    private var rasterizer: Rasterizer?
    private var framebuffer: FrameBuffer?
    
    
    private let ambientLight = AmbientLight(red: 32, green: 32, blue: 32)
    private let directionalLight = DirectionalLight(red:  255, green: 0, blue: 0, direction: Vector(0,  -1, -1, 0))
    
    private var pointLight = PointLight(red: 255, green: 0, blue: 255,
                                        position: Point(0, -80, 0, 1),
                                        attenuation: PointLight.Attenuation(constant: 0, linear: 1, exponant: 0))
    
    
    
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
    
    func update(interval: CFTimeInterval) {
        self.deg += 1
        if self.deg > 359 {
            self.deg = 0
        }
        let rad = self.deg * 0.0174533
        
        self.md2Object?.renderAnimation(animation: .flip, interval: interval)
        
        let rot = Matrix.rotation(rotX: 0, rotY: Float(rad), rotZ: 0)
        
        self.md2Object?.renderModel.transform(transMatrix: rot, type: .localToTranslated)
        
        self.md2Object?.renderModel.calculateBackFacing(cam: self.camera!)
        self.md2Object?.renderModel.calculateVertexNormals()
        
        self.md2Object?.renderModel.calculateLighting(lights: [ambientLight,directionalLight,pointLight])
        
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
