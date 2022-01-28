//
//  Rasterizer.swift
//  SoftRenderer
//
//  Created by Richard Pickup on 17/01/2022.
//

import Foundation



struct Vertex {
    var position: Vector
    var normal: Vector
    var color: Color
    var lit: Color
    var u: Float
    var v: Float
    var uvIndex: Int
    
    init(x: Float, y: Float, z: Float) {
        self.position = Vector(x, y, z, 1)
        self.color = Color(r: 255, g: 255, b: 255, a: 255)
        self.normal = Vector(0, 0, 0, 0)
        self.u = 0
        self.v = 0
        self.uvIndex = 0
        self.lit = Color.white
    }
    
    init(x: Float, y: Float, z: Float, color: Color) {
        self.position = Vector(x, y, z, 1)
        self.color = color
        self.normal = Vector(0, 0, 0, 0)
        self.u = 0
        self.v = 0
        self.uvIndex = 0
        self.lit = Color.white
    }
}

struct Scanline {
    var startX: Vertex
    var endX: Vertex
}

struct Rasterizer {
    var scanlines: [Scanline]
    let frameBuffer: FrameBuffer
    var backfaceCulling: Bool
    
    init(numLines: Int, frameBuffer: FrameBuffer, backfaceCulling: Bool = true) {
        self.frameBuffer = frameBuffer
        self.backfaceCulling = backfaceCulling
        scanlines = [Scanline](repeating:
                                Scanline(startX: Vertex(x: 0, y: 0, z: 0),
                                         endX:  Vertex(x: 0, y: 0, z: 0)),
                               count: numLines)
    }
    
    mutating func drawsolid(drawObject: MD2Object3D){
        //backfaceculling
        
        var objPoints = [Vertex](repeating: Vertex(x: 0, y: 0, z: 0), count: 3)
        
        for i in 0..<drawObject.numPolys {
            if backfaceCulling {
                if !drawObject.polygons[i].backfacing {
                    objPoints[0].position.x = drawObject.transformedVerts[drawObject.polygons[i].indices.0].position.x
                    objPoints[0].position.y = drawObject.transformedVerts[drawObject.polygons[i].indices.0].position.y
                    
                    objPoints[0].uvIndex = drawObject.polygons[i].uvIndices.0
                    objPoints[0].color = drawObject.transformedVerts[drawObject.polygons[i].indices.0].color
                    
                    objPoints[1].position.x = drawObject.transformedVerts[drawObject.polygons[i].indices.1].position.x
                    objPoints[1].position.y = drawObject.transformedVerts[drawObject.polygons[i].indices.1].position.y
                    
                    
                    objPoints[1].uvIndex = drawObject.polygons[i].uvIndices.1
                    objPoints[1].color = drawObject.transformedVerts[drawObject.polygons[i].indices.1].color
                    
                    objPoints[2].position.x = drawObject.transformedVerts[drawObject.polygons[i].indices.2].position.x
                    objPoints[2].position.y = drawObject.transformedVerts[drawObject.polygons[i].indices.2].position.y
                    
                    objPoints[2].uvIndex = drawObject.polygons[i].uvIndices.2
                    objPoints[2].color = drawObject.transformedVerts[drawObject.polygons[i].indices.2].color
                    
                    fillPolygon(pointA: objPoints[0], pointB: objPoints[1], pointC: objPoints[2], drawObject: drawObject)
                }
            }
        }
    }
    
    mutating func fillPolygon(pointA: Vertex, pointB: Vertex, pointC: Vertex, drawObject: MD2Object3D) {
        let verts: [Vertex] = [pointA, pointB, pointC]
        
        var ymin = Int(verts[0].position.y)
        var ymax = Int(verts[2].position.y)
        
        for vert in verts {
            if Int(vert.position.y) < ymin {
                ymin = Int(vert.position.y)
            }
            
            if Int(vert.position.y) > ymax {
                ymax = Int(vert.position.y)
            }
        }
        
        for i in ymin..<ymax {
            guard i > 0, i < scanlines.count else {
                continue
            }
            scanlines[i].startX.position.x = Float(Int.max)
            scanlines[i].endX.position.x = Float(Int.min)
        }
        
        scanEdgeTextured(vertA: verts[0], vertB: verts[1], drawObject: drawObject)
        scanEdgeTextured(vertA: verts[1], vertB: verts[2], drawObject: drawObject)
        scanEdgeTextured(vertA: verts[2], vertB: verts[0], drawObject: drawObject)
        
        drawlinesTextured(top: ymin, bottom: ymax, drawObject: drawObject)
        
        //        scanEdge(vertA: verts[0], vertB: verts[1])
        //        scanEdge(vertA: verts[1], vertB: verts[2])
        //        scanEdge(vertA: verts[2], vertB: verts[0])
        //
        //        drawLines(top: ymin, bottom: ymax)
    }
    
    mutating func scanEdge(vertA: Vertex, vertB: Vertex) {
        
        guard vertA.position.y != vertB.position.y else {
            return
        }
        
        var tempA = vertA
        var tempB = vertB
        if tempA.position.y > tempB.position.y {
            let tempSwap = tempA
            tempA = tempB
            tempB = tempSwap
        }
        
        let top = Int(tempA.position.y)
        let bottom = Int(tempB.position.y)
        let dy: Float = tempB.position.y - tempA.position.y
        
        guard dy > 0 else {
            return
        }
        
        let dx: Float = tempB.position.x - tempA.position.x
        let dr: Float = Float(tempB.color.r) - Float(tempA.color.r)
        let dg: Float = Float(tempB.color.g) - Float(tempA.color.g)
        let db: Float = Float(tempB.color.b) - Float(tempA.color.b)
        
        let dx_dy: Double = Double(dx) / Double(dy)
        let dr_dy: Double = Double(dr) / Double(dy)
        let dg_dy: Double = Double(dg) / Double(dy)
        let db_dy: Double = Double(db) / Double(dy)
        
        var x = Double(tempA.position.x)
        var r = Double(tempA.color.r)
        var g = Double(tempA.color.g)
        var b = Double(tempA.color.b)
        
        
        for i in top ..< bottom {
            guard i > 0, i < scanlines.count else {
                continue
            }
            let sx = Float(x)
            let sr = UInt8(r)
            let sg = UInt8(g)
            let sb = UInt8(b)
            
            if sx < scanlines[i].startX.position.x {
                scanlines[i].startX.position.x = sx
                scanlines[i].startX.color = Color(r: sr, g: sg, b: sb)
            }
            if sx > scanlines[i].endX.position.x {
                scanlines[i].endX.position.x = sx
                scanlines[i].endX.color = Color(r: sr, g: sg, b: sb)
            }
            x += dx_dy
            r += dr_dy
            g += dg_dy
            b += db_dy
        }
    }
    
    mutating func scanEdgeTextured(vertA: Vertex, vertB: Vertex, drawObject: MD2Object3D) {
        
        guard vertA.position.y != vertB.position.y else {
            return
        }
        
        var tempA = vertA
        var tempB = vertB
        if tempA.position.y > tempB.position.y {
            let tempSwap = tempA
            tempA = tempB
            tempB = tempSwap
        }
        
        let dy: Float = tempB.position.y - tempA.position.y
        guard dy > 0 else {
            return
        }
        
        // deltas
        let dx: Float = tempB.position.x - tempA.position.x
        let dr: Float = Float(tempB.color.r) - Float(tempA.color.r)
        let dg: Float = Float(tempB.color.g) - Float(tempA.color.g)
        let db: Float = Float(tempB.color.b) - Float(tempA.color.b)
        let du = drawObject.texUVs[tempB.uvIndex].u - drawObject.texUVs[tempA.uvIndex].u
        let dv = drawObject.texUVs[tempB.uvIndex].v - drawObject.texUVs[tempA.uvIndex].v
        
        // increments
        let dx_dy: Double = Double(dx / dy)
        let dr_dy: Double = Double(dr) / Double(dy)
        let dg_dy: Double = Double(dg) / Double(dy)
        let db_dy: Double = Double(db) / Double(dy)
        let du_dy: Double = Double(du / dy)
        let dv_dy: Double = Double(dv / dy)
        
        // initial values
        var x = Double(tempA.position.x)
        var r = Double(tempA.color.r)
        var g = Double(tempA.color.g)
        var b = Double(tempA.color.b)
        var u = Double(drawObject.texUVs[tempA.uvIndex].u)
        var v = Double(drawObject.texUVs[tempA.uvIndex].v)
        
        let top = Int(tempA.position.y)
        let bottom = Int(tempB.position.y)
        
        for i in top ..< bottom {
            guard i > 0, i < scanlines.count else {
                continue
            }
            let sx = Float(x)
            
            let sr = UInt8(r)
            let sg = UInt8(g)
            let sb = UInt8(b)
            let su = Float(u)
            let sv = Float(v)
            
            if sx < scanlines[i].startX.position.x {
                scanlines[i].startX.position.x = sx
                
                scanlines[i].startX.color = Color(r: sr, g: sg, b: sb)
                
                scanlines[i].startX.u = su
                scanlines[i].startX.v = sv
            }
            if sx > scanlines[i].endX.position.x {
                scanlines[i].endX.position.x = sx
                
                scanlines[i].endX.color = Color(r: sr, g: sg, b: sb)
                
                scanlines[i].endX.u = su
                scanlines[i].endX.v = sv
            }
            x += dx_dy
            r += dr_dy
            g += dg_dy
            b += db_dy
            u += du_dy
            v += dv_dy
        }
    }
    
    func drawLines(top: Int, bottom: Int) {
        for y in top ..< bottom {
            guard y > 0, y < scanlines.count else {
                continue
            }
            let dr = Int(scanlines[y].endX.color.r) - Int(scanlines[y].startX.color.r)
            let dg = Int(scanlines[y].endX.color.g) - Int(scanlines[y].startX.color.g)
            let db = Int(scanlines[y].endX.color.b) - Int(scanlines[y].startX.color.b)
            
            let dx = Int(scanlines[y].endX.position.x) - Int(scanlines[y].startX.position.x)
            if dx == 0 {
                continue
            }
            
            var r = Double(scanlines[y].startX.color.r)
            var g = Double(scanlines[y].startX.color.g)
            var b = Double(scanlines[y].startX.color.b)
            
            let dr_dx = Double(dr) / Double(dx)
            let dg_dx = Double(dg) / Double(dx)
            let db_dx = Double(db) / Double(dx)
            
            for x in Int(scanlines[y].startX.position.x) ..< Int(scanlines[y].endX.position.x) {
                
                let sr = UInt8(r)
                let sg = UInt8(g)
                let sb = UInt8(b)
                
                let color = Color(r: sr,
                                  g: sg,
                                  b: sb)
                
                frameBuffer.setPixel( x, y, color)
                
                r += dr_dx
                g += dg_dx
                b += db_dx
            }
        }
    }
    
    mutating func drawlinesTextured(top: Int, bottom: Int, drawObject: MD2Object3D) {
        for y in top ..< bottom {
            guard y > 0, y < scanlines.count else {
                continue
            }
            let dx = Int(scanlines[y].endX.position.x) - Int(scanlines[y].startX.position.x)
            
            if dx == 0 {
                continue
            }
            
            let dr = Int(scanlines[y].endX.color.r) - Int(scanlines[y].startX.color.r)
            let dg = Int(scanlines[y].endX.color.g) - Int(scanlines[y].startX.color.g)
            let db = Int(scanlines[y].endX.color.b) - Int(scanlines[y].startX.color.b)
            
            let du = scanlines[y].endX.u - scanlines[y].startX.u
            let dv = scanlines[y].endX.v - scanlines[y].startX.v
            
            var tempDU = scanlines[y].startX.u
            var tempDV = scanlines[y].startX.v
            
            var r = Double(scanlines[y].startX.color.r)
            var g = Double(scanlines[y].startX.color.g)
            var b = Double(scanlines[y].startX.color.b)
            
            let du_dx = du / Float(dx)
            let dv_dx = dv / Float(dx)
            
            let dr_dx = Double(dr) / Double(dx)
            let dg_dx = Double(dg) / Double(dx)
            let db_dx = Double(db) / Double(dx)
            
            for x in Int(scanlines[y].startX.position.x) ..< Int(scanlines[y].endX.position.x) {
                if x <= 0 || x >= frameBuffer.width {
                    continue
                }
                let sr = r
                let sg = g
                let sb = b
                
                let texIndex = Int(tempDU) + Int(tempDV)  * drawObject.texWidth
                
                let calR = Double(drawObject.palette[Int(drawObject.texture[texIndex])].r)
                
                var mixR = Int(255 * (sr / 255.0 * calR / 255.0))
                if mixR > 255 { mixR = 255 }
                
                let calG = Double(drawObject.palette[Int(drawObject.texture[texIndex])].g)
                var mixG = Int(255 * (sg / 255.0 * calG / 255.0))
                if mixG > 255 { mixG = 255 }
                
                let calB = Double(drawObject.palette[Int(drawObject.texture[texIndex])].b)
                var mixB = Int(255 * (sb / 255.0 * calB / 255.0))
                if mixB > 255 { mixB = 255 }
                
                //let newColor = Color(r: UInt8(mixR), g: UInt8(mixG), b: UInt8(mixB))
                let newColor = Color(r: UInt8(mixR), g: UInt8(mixG), b: UInt8(mixB))
                frameBuffer.setPixel( x, y, newColor)
                tempDU += du_dx
                tempDV += dv_dx
                r += dr_dx
                g += dg_dx
                b += db_dx
            }
        }
    }
}

