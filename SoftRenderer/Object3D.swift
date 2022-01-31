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
    let numUVs: Int
    let numVerts: Int
    let numPolys: Int
    let texWidth: Int
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
    
    
    mutating func calculateLighting(lights: [Light]) {
        for i in 0..<numPolys {
            if polygons[i].backfacing {
                continue
            }
            var color1 = Color.black
            var color2 = Color.black
            var color3 = Color.black
            
            lights.forEach {
                if let ambient = $0 as? AmbientLight {
                    let color = ambient.calculateIntensity(poly: polygons[i])
                    
                    color1 += color
                    color2 += color
                    color3 += color
                    
                } else if let directional = $0 as? DirectionalLight {
                    let light1 = directional.calculateIntensity(poly: polygons[i], vert: transformedVerts[polygons[i].indices.0])
                    let light2 = directional.calculateIntensity(poly: polygons[i], vert: transformedVerts[polygons[i].indices.1])
                    let light3 = directional.calculateIntensity(poly: polygons[i], vert: transformedVerts[polygons[i].indices.2])
                    
                    color1 += light1
                    color2 += light2
                    color3 += light3
                    
                    
                } else if let point = $0 as? PointLight {
                    let light1 = point.calculateIntensity(poly: polygons[i], vert: transformedVerts[polygons[i].indices.0])
                    let light2 = point.calculateIntensity(poly: polygons[i], vert: transformedVerts[polygons[i].indices.1])
                    let light3 = point.calculateIntensity(poly: polygons[i], vert: transformedVerts[polygons[i].indices.2])
                    color1 += light1
                    color2 += light2
                    color3 += light3
                }
            }
            transformedVerts[polygons[i].indices.0].color = color1
            transformedVerts[polygons[i].indices.1].color = color2
            transformedVerts[polygons[i].indices.2].color = color3
            
        }
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
