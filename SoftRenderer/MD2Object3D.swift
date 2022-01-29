//
//  MD2Object3D.swift
//  SoftRenderer
//
//  Created by Richard Pickup on 26/01/2022.
//

import Foundation

enum MD2Animation {
    case stand
    case run
    case attack
    case painA
    case painB
    case painC
    case jump
    case flip
    case salute
    case fallback
    case wave
    case point
    case crouchStand
    case crouchWalk
    case crouchAttack
    case crouchPain
    case crouchDeath
    case deathFallBack
    case deathFallForward
    case deathFallBackSlow
    case boom
    
    var frames: (start: Int, end: Int, fps: Double) {
        switch self {
        case .stand:
            return (0, 39, 9)
        case .run:
            return (  40,  45, 10 )
        case .attack:
            return (46,  53, 10)
        case .painA:
            return (54,  57,  7)
        case .painB:
            return (58,  61,  7)
        case .painC:
            return (62,  65,  7)
        case .jump:
            return (66,  71,  7)
        case .flip:
            return (72,  83,  7)
        case .salute:
            return (84,  94,  7)
        case .fallback:
            return (95, 111, 10)
        case .wave:
            return (112, 122,  7)
        case .point:
            return (123, 134,  6)
        case .crouchStand:
            return (135, 153, 10)
        case .crouchWalk:
            return (154, 159,  7)
        case .crouchAttack:
            return (160, 168, 10)
        case .crouchPain:
            return (196, 172,  7)
        case .crouchDeath:
            return (173, 177,  5)
        case .deathFallBack:
            return (178, 183,  7)
        case .deathFallForward:
            return (184, 189,  7)
        case .deathFallBackSlow:
            return (190, 197,  7)
        case .boom:
            return (198, 198,  5)
        }
    }
}

class MD2Object3D {
    let verts: [[Vertex]]
    var renderModel: Object3D
    var currentFrame: Int = 0
    var nextFrame: Int = 0
    
    var currentTime: CFTimeInterval = 0
    var oldTime: CFTimeInterval = 0
    
    init(numUVs: Int,
         numVerts: Int,
         numPolys: Int,
         texWidth: Int,
         position: Vector,
         polygons: [Polygon],
         palette: [Color],
         texture: [UInt8],
         verts: [[Vertex]],
         texUVs: [TextureUV]) {
        self.verts = verts
        
        self.renderModel = Object3D(numUVs: numUVs,
                                    numVerts: numVerts,
                                    numPolys: numPolys,
                                    texWidth: texWidth,
                                    position: position,
                                    polygons: polygons,
                                    palette: palette,
                                    texture: texture,
                                    texUVs: texUVs)
    }
    
    func interpolate(a: Float,b: Float,t: Float) -> Float { return a + (b - a) * t}
    
    func renderAnimation(animation: MD2Animation, interval: CFTimeInterval) {
        
        if self.currentFrame < animation.frames.start
        {
            self.currentFrame = animation.frames.start;
            self.nextFrame = self.currentFrame + 1;
        }
        
        currentTime += interval
        
        if currentTime - oldTime > (1.0 / animation.frames.fps) {
            oldTime = currentTime
            self.currentFrame += 1
            if self.currentFrame >= animation.frames.end {//loop animation
                
                self.currentFrame = animation.frames.start;
            }
            self.nextFrame = self.currentFrame + 1;
            if self.nextFrame >= animation.frames.end {
                self.nextFrame = animation.frames.start;
            }
        }
        
        let interpolation = Float(animation.frames.fps * (currentTime - oldTime))
        
        let isNoInterpolation = interpolation.truncatingRemainder(dividingBy: 1) == 0
        
        var index = 0
        if isNoInterpolation {
            // Shortcut.  just render currentframe with no interpolation if frame is keyframe boundary
            for i in 0..<renderModel.numPolys {
                index = renderModel.polygons[i].indices.0
                renderModel.verts[index] = verts[self.currentFrame][renderModel.polygons[i].indices.0]
                index = renderModel.polygons[i].indices.1
                renderModel.verts[index] = verts[self.currentFrame][renderModel.polygons[i].indices.1]
                index = renderModel.polygons[i].indices.2
                renderModel.verts[index] = verts[self.currentFrame][renderModel.polygons[i].indices.2]
            }
            return
        }
        
        var x1,y1,z1: Float
        var normalCurrent: Vector
        var x2,y2,z2: Float
        var normalNext: Vector
        for i in 0..<renderModel.numPolys {
            index = renderModel.polygons[i].indices.0
            x1 = verts[self.currentFrame][index].position.x
            y1 = verts[self.currentFrame][index].position.y
            z1 = verts[self.currentFrame][index].position.z
            x2 = verts[self.nextFrame][index].position.x
            y2 = verts[self.nextFrame][index].position.y
            z2 = verts[self.nextFrame][index].position.z
            
            normalCurrent = verts[self.currentFrame][index].normal
            normalNext = verts[self.nextFrame][index].normal
            
            var vertA = Vertex(x: interpolate(a: x1, b: x2, t: interpolation),
                               y: interpolate(a: y1, b: y2, t: interpolation),
                               z: interpolate(a: z1, b: z2, t: interpolation))
            
            
            vertA.normal = normalCurrent.interpolated(with: normalNext, by: interpolation)
            vertA.uvIndex = renderModel.polygons[i].uvIndices.0
            vertA.color = Color.white
            renderModel.verts[index] = vertA
            
            index = renderModel.polygons[i].indices.1
            
            x1 = verts[self.currentFrame][index].position.x
            y1 = verts[self.currentFrame][index].position.y
            z1 = verts[self.currentFrame][index].position.z
            x2 = verts[self.nextFrame][index].position.x
            y2 = verts[self.nextFrame][index].position.y
            z2 = verts[self.nextFrame][index].position.z
            
            normalCurrent = verts[self.currentFrame][index].normal
            normalNext = verts[self.nextFrame][index].normal
            
            var vertB = Vertex(x: interpolate(a: x1, b: x2, t: interpolation),
                               y: interpolate(a: y1, b: y2, t: interpolation),
                               z: interpolate(a: z1, b: z2, t: interpolation))
            
            vertB.normal = normalCurrent.interpolated(with: normalNext, by: interpolation)
            vertB.uvIndex = renderModel.polygons[i].uvIndices.1
            vertB.color = Color.white
            
            renderModel.verts[index] = vertB
            
            index = renderModel.polygons[i].indices.2
            
            x1 = verts[self.currentFrame][index].position.x
            y1 = verts[self.currentFrame][index].position.y
            z1 = verts[self.currentFrame][index].position.z
            x2 = verts[self.nextFrame][index].position.x
            y2 = verts[self.nextFrame][index].position.y
            z2 = verts[self.nextFrame][index].position.z
            
            normalCurrent = verts[self.currentFrame][index].normal
            normalNext = verts[self.nextFrame][index].normal
            
            var vertC = Vertex(x: interpolate(a: x1, b: x2, t: interpolation),
                               y: interpolate(a: y1, b: y2, t: interpolation),
                               z: interpolate(a: z1, b: z2, t: interpolation))
            
            vertC.normal = normalCurrent.interpolated(with: normalNext, by: interpolation)
            vertC.uvIndex = renderModel.polygons[i].uvIndices.2
            vertC.color = Color.white
            
            renderModel.verts[index] = vertC
        }
    }
}
