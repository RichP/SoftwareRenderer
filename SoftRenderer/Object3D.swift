//
//  Object3D.swift
//  SoftRenderer
//
//  Created by Richard Pickup on 19/01/2022.
//

import Foundation

enum TransformType {
    case local
    case localToTranslated
    case translated
}

struct TextureUV {
    let u: Float
    let v: Float
}

let maxVerts = 2048
struct Object3D {
    var numUVs: Int
    var numVerts: Int
    var numPolys: Int
    var texWidth: Int
    var position: Vector
    var polygons: [Polygon]
    var palette: [Color]
    var texture: [UInt8]
    var verts = [Vertex](repeating: Vertex(x: 0, y: 0, z: 1), count: maxVerts)
    var transformedVerts = [Vertex](repeating: Vertex(x: 0, y: 0, z: 1), count: maxVerts)
    var texUVs: [TextureUV]
    
    
    mutating func transform(transMatrix: Matrix, type: TransformType) {
        switch type {
        case .local:
            for i in 0..<numVerts {
                
                verts[i].position = transMatrix.transform(vec: verts[i].position)
            }
        case .localToTranslated:
            for i in 0..<numVerts {
                transformedVerts[i].position = transMatrix.transform(vec: verts[i].position)
            }
        case .translated:
            for i in 0..<numVerts {
                transformedVerts[i].position = transMatrix.transform(vec: transformedVerts[i].position)
            }
        }
    }
    
    mutating func dehomogenise() {
        for i in 0..<numVerts {
            transformedVerts[i].position = transformedVerts[i].position / transformedVerts[i].position.w
        }
    }
    
    mutating func calculateBackFacing(cam: Camera) {
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
    
    
    mutating func calculateAmbientLighting(lights: [AmbientLight]) {
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
    
    mutating func calculateDirectionalLighting(lights: [DirectionalLight]) {
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
    
    mutating func directionalLightFor(normal: Vector, polygon: Polygon, lights: [DirectionalLight]) -> Color {
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
    
    mutating func calculateVertexNormals() {
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
    
    mutating func sort() {
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
