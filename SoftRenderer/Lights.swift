//
//  Lights.swift
//  SoftRenderer
//
//  Created by Richard Pickup on 23/01/2022.
//

import Foundation

protocol Light {
    var red: UInt8 { get set }
    var green: UInt8 { get set }
    var blue: UInt8 { get set }
    
    func calculateIntensity(poly: Polygon) -> Color
}

struct AmbientLight: Light {
    var red: UInt8
    
    var green: UInt8
    
    var blue: UInt8
    
    func calculateIntensity(poly: Polygon) -> Color {
        var tempR: Float = 0.0
        var tempG: Float = 0.0
        var tempB: Float = 0.0
        
        tempR = Float(poly.materialColor.r) * Float(red)
        tempG = Float(poly.materialColor.g) * Float(green)
        tempB = Float(poly.materialColor.b) * Float(blue)
        let r = UInt8(tempR / 256);
        let g = UInt8(tempG / 256);
        let b = UInt8(tempB / 256);
        
        return Color(r: r,g: g,b: b);
    }
}

struct DirectionalLight: Light {
    var red: UInt8
    
    var green: UInt8
    
    var blue: UInt8
    
    let direction: Vector
    
    func calculateIntensity(poly: Polygon) -> Color {
        var tempR: Float = 0.0
        var tempG: Float = 0.0
        var tempB: Float = 0.0
        
        var lightNormal = direction
        lightNormal.normalize()
        
        let dp = lightNormal.dotProduct(poly.normal)
        var r: UInt8 = 0
        var g: UInt8 = 0
        var b: UInt8 = 0
        if dp > 0 {
            tempR = Float(poly.materialColor.r) * Float(red) * dp
            tempG = Float(poly.materialColor.g) * Float(green) * dp
            tempB = Float(poly.materialColor.b) * Float(blue) * dp
            r = UInt8(tempR / 256);
            g = UInt8(tempG / 256);
            b = UInt8(tempB / 256);
        }
        
        return Color(r: r,g: g,b: b);
    }
    
    func calculateIntensity(poly: Polygon, vertNorm: Vector) -> Color {
        var tempR: Float = 0.0
        var tempG: Float = 0.0
        var tempB: Float = 0.0
        
        var lightNormal = direction
        lightNormal.normalize()
        
        let dp = lightNormal.dotProduct(vertNorm)
        var r: UInt8 = 0
        var g: UInt8 = 0
        var b: UInt8 = 0
        if dp > 0 {
            tempR = Float(poly.materialColor.r) * Float(red) * dp
            tempG = Float(poly.materialColor.g) * Float(green) * dp
            tempB = Float(poly.materialColor.b) * Float(blue) * dp
            
            tempR /= 256.0
            tempG /= 256.0
            tempB /= 256.0
            
            r = UInt8(floorf(tempR))
            g = UInt8(floorf(tempG))
            b = UInt8(floorf(tempB))
        }
        
        return Color(r: r,g: g,b: b);
    }
}
