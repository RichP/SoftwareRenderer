//
//  Vector.swift
//  SoftRenderer
//
//  Created by Richard Pickup on 19/01/2022.
//

import Foundation
typealias Point = Vector
struct Vector {
    var x: Float
    var y: Float
    var z: Float
    var w: Float
    
    init(_ x: Float, _ y: Float, _ z: Float, _ w: Float) {
        self.x = x
        self.y = y
        self.z = z
        self.w = w
    }
    static func zero() -> Vector{
        return Vector(0, 0, 0, 0)
    }
    
    func length() -> Float {
        return sqrtf(x * x + y * y + z * z + w * w)
    }
    
    mutating func normalize() {
        let length = length()
        x = x / length
        y = y / length
        z = z / length
        w = w / length
    }
    
    func dotProduct(_ vec: Vector) -> Float {
        return x * vec.x + y * vec.y + z * vec.z + w * vec.w
    }
    
    func crossProduct(_ vec: Vector) -> Vector {
        return Vector(y * vec.z - z * vec.y,
                      z * vec.x - x * vec.z,
                      x * vec.y - y * vec.x,
                      0.0)
    }
    
    func interpolated(with v: Vector, by t: Float) -> Vector {
            return self + (v - self) * t
    }
    
    static func +=( lhs: inout Vector, rhs: Vector) {
        lhs = Vector(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z, lhs.w + rhs.w)
    }
    
    static func +(lhs: Vector, rhs: Vector) -> Vector {
        return Vector(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z, lhs.w + rhs.w)
    }
    
    static func -(lhs: Vector, rhs: Vector) -> Vector {
        return Vector(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z, lhs.w - rhs.w)
    }
    
    static func *(lhs: Vector, scaler: Float) -> Vector {
        return Vector(lhs.x * scaler, lhs.y * scaler, lhs.z * scaler, lhs.w * scaler)
    }
    
    static func *(lhs: Vector, rhs: Vector) -> Vector {
            return Vector(lhs.x * rhs.x, lhs.y * rhs.y, lhs.z * rhs.z, lhs.w * rhs.w)
    }
    
    static func /(lhs: Vector, scaler: Float) -> Vector {
        return Vector(lhs.x / scaler, lhs.y / scaler, lhs.z / scaler, lhs.w / scaler)
    }
}
