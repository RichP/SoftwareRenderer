//
//  MD2Object3D.swift
//  SoftRenderer
//
//  Created by Richard Pickup on 26/01/2022.
//

import Foundation

class MD2Object3D {
    
    let numUVs: Int
    let numVerts: Int
    let numPolys: Int
    let texWidth: Int
    let position: Vector
    var polygons: [Polygon]
    let palette: [Color]
    let texture: [UInt8]
    let verts: [[Vertex]]
    var interpolatedVerts = [Vertex](repeating: Vertex(x: 0, y: 0, z: 1), count: maxVerts)
    var transformedVerts = [Vertex](repeating: Vertex(x: 0, y: 0, z: 1), count: maxVerts)
    let texUVs: [TextureUV]
    
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
        self.numUVs = numUVs
        self.numVerts = numVerts
        self.numPolys = numPolys
        self.texWidth = texWidth
        
        self.position = position
        self.polygons = polygons
        self.palette = palette
        self.texture = texture
        self.verts = verts
        self.texUVs = texUVs
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
            for i in 0..<numPolys {
                index = polygons[i].indices.0
                interpolatedVerts[index] = verts[self.currentFrame][polygons[i].indices.0]
                index = polygons[i].indices.1
                interpolatedVerts[index] = verts[self.currentFrame][polygons[i].indices.1]
                index = polygons[i].indices.2
                interpolatedVerts[index] = verts[self.currentFrame][polygons[i].indices.2]
            }
            self.interpolation += interpolation
            return
        }
        
        var x1,y1,z1: Float
        var normalCurrent: Vector
        var x2,y2,z2: Float
        var normalNext: Vector
        for i in 0..<numPolys {
            index = polygons[i].indices.0
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
            vertA.uvIndex = polygons[i].uvIndices.0
            vertA.color = Color.white
            interpolatedVerts[index] = vertA
            
            index = polygons[i].indices.1
            
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
            vertB.uvIndex = polygons[i].uvIndices.1
            vertB.color = Color.white
            
            interpolatedVerts[index] = vertB
            
            index = polygons[i].indices.2
            
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
            vertC.uvIndex = polygons[i].uvIndices.2
            vertC.color = Color.white
            
            interpolatedVerts[index] = vertC
            
        }
        self.interpolation += interpolation
    }
    
    func transform(transMatrix: Matrix, type: TransformType) {
        switch type {
        case .local:
            for i in 0..<numVerts {
                interpolatedVerts[i].position = transMatrix.transform(vec: interpolatedVerts[i].position)
            }
            //verts = verts.map { transMatrix.transform(vec: $0) }
        case .localToTranslated:
            for i in 0..<numVerts {
                transformedVerts[i].position = transMatrix.transform(vec: interpolatedVerts[i].position)
                //transformedVerts[i].normal = verts[i].normal
            }
        case .translated:
            for i in 0..<numVerts {
                transformedVerts[i].position = transMatrix.transform(vec: transformedVerts[i].position)
            }
        }
    }
    
    func dehomogenise() {
        for i in 0..<numVerts {
            transformedVerts[i].position = transformedVerts[i].position / transformedVerts[i].position.w
        }
    }
    
    func calculateBackFacing(cam: Camera) {
        var pointA: Point = Point(0, 0, 0, 1)
        var pointB: Point = Point(0, 0, 0, 1)
        var pointC: Point = Point(0, 0, 0, 1)
        
        for i in 0..<numPolys {
            pointA = transformedVerts[polygons[i].indices.0].position
            pointB = transformedVerts[polygons[i].indices.1].position
            pointC = transformedVerts[polygons[i].indices.2].position
            
            let vecA = pointA - pointB
            let vecB = pointA - pointC
            var normal = vecB.crossProduct(vecA)
            normal.normalize()
            polygons[i].normal = normal
            
            let eye = transformedVerts[polygons[i].indices.0].position - cam.position
            polygons[i].backfacing = (eye.dotProduct(normal) < 0) ? true : false
        }
    }
    
    func calculateAmbientLighting(lights: [AmbientLight]) {
        for i in 0..<numPolys {
            var red: UInt8 = 0
            var green: UInt8 = 0
            var blue: UInt8 = 0
            
            lights.forEach {
                let tempColor = Color(r: $0.red, g: $0.green, b: $0.blue)
                
                //$0.calculateIntensity(poly: polygons[i])
                
                red += tempColor.r
                green += tempColor.g
                blue += tempColor.b
            }
            
            if red > 255 {
                red = 255
            }
            if green > 255 {
                green = 255
            }
            if blue > 255{
                blue = 255
            }
            polygons[i].litColor = Color.init(r: red, g: green, b: blue)
        }
    }
    
    func calculateDirectionalLighting(lights: [DirectionalLight]) {
        for i in 0..<numPolys {
            if polygons[i].backfacing {
                continue
            }
            
            var norm = transformedVerts[polygons[i].indices.0].normal
            let col1 = directionalLightFor(normal: norm, polygon: polygons[i], lights: lights)
            transformedVerts[polygons[i].indices.0].color = col1
            
            
            norm = transformedVerts[polygons[i].indices.1].normal
            let col2 = directionalLightFor(normal: norm, polygon: polygons[i], lights: lights)
            transformedVerts[polygons[i].indices.1].color = col2
            
            norm = transformedVerts[polygons[i].indices.2].normal
            let col3 = directionalLightFor(normal: norm, polygon: polygons[i], lights: lights)
            transformedVerts[polygons[i].indices.2].color = col3
            
            //polygons[i].litColor = col3
        }
    }
    
    func directionalLightFor(normal: Vector, polygon: Polygon, lights: [DirectionalLight]) -> Color {
        var red = Int(polygon.litColor.r)
        var green = Int(polygon.litColor.g)
        var blue = Int(polygon.litColor.b)
        
        
        lights.forEach {
            let tempColor = $0.calculateIntensity(poly: polygon, vertNorm: normal)
            
            red += Int(tempColor.r)
            green += Int(tempColor.g)
            blue += Int(tempColor.b)
        }
        
        if red > 255 {
            red = 255
        }
        if green > 255 {
            green = 255
        }
        if blue > 255{
            blue = 255
        }
        return Color.init(r: UInt8(red), g: UInt8(green), b: UInt8(blue))
    }
    
    func calculateVertexNormals() {
        var normalsPerVert = [Int](repeating: 0, count: maxVerts)
        
        for i in 0..<numPolys {
            normalsPerVert[polygons[i].indices.0] += 1;
            transformedVerts[polygons[i].indices.0].normal += polygons[i].normal
            
            normalsPerVert[polygons[i].indices.1] += 1
            transformedVerts[polygons[i].indices.1].normal += polygons[i].normal
            
            normalsPerVert[polygons[i].indices.2] += 1
            transformedVerts[polygons[i].indices.2].normal += polygons[i].normal
        }
        
        for i in 0..<numVerts {
            transformedVerts[i].normal = transformedVerts[i].normal / Float(normalsPerVert[i])
            transformedVerts[i].normal.normalize()
        }
    }
    
    func sort() {
        var aZ: Float = 0.0
        var bZ: Float = 0.0
        var cZ: Float = 0.0
        for i in 0..<numPolys {
            aZ = transformedVerts[polygons[i].indices.0].position.z
            bZ = transformedVerts[polygons[i].indices.1].position.z
            cZ = transformedVerts[polygons[i].indices.2].position.z
            polygons[i].averageZ = (aZ + bZ + cZ) / 3
        }
        polygons.sort(by: {$0.averageZ < $1.averageZ} )
    } 
}
