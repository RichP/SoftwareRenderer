//
//  MD2Object3D.swift
//  SoftRenderer
//
//  Created by Richard Pickup on 26/01/2022.
//

import Foundation

class MD2Object3D {
    let verts: [[Vertex]]
    var renderModel: Object3D
    var interpolation: Float = 0.25
    var currentFrame: Int = 0
    var nextFrame: Int = 0
    
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
    
    func renderAnimation(startFrame: Int, endFrame: Int, interpolation: Float) {
        if self.currentFrame < startFrame
        {
            self.currentFrame = startFrame;
            self.nextFrame = self.currentFrame + 1;
        }
        
        if(self.interpolation >= 0.9)//move on to next frame
        {
            self.interpolation = 0.0
            self.currentFrame += 1
            if self.currentFrame >= endFrame {//loop animation
                
                self.currentFrame = startFrame;
            }
            self.nextFrame = self.currentFrame + 1;
            if self.nextFrame >= endFrame {
                self.nextFrame = startFrame;
            }
        }
        let isNoInterpolation = self.interpolation.truncatingRemainder(dividingBy: 1) == 0
        
        
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
            self.interpolation += interpolation
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
        self.interpolation += interpolation
    }
}
