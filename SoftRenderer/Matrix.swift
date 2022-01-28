//
//  Matrix.swift
//  SoftRenderer
//
//  Created by Richard Pickup on 19/01/2022.
//

import Foundation

struct Matrix {
    let m11: Float
    var m12: Float
    let m13: Float
    let m14: Float
    let m21: Float
    let m22: Float
    let m23: Float
    let m24: Float
    let m31: Float
    let m32: Float
    let m33: Float
    let m34: Float
    let m41: Float
    let m42: Float
    let m43: Float
    let m44: Float
    
    init(_ m11: Float, _ m12: Float, _ m13: Float, _ m14: Float,
         _ m21: Float, _ m22: Float, _ m23: Float, _ m24: Float,
         _ m31: Float, _ m32: Float, _ m33: Float, _ m34: Float,
         _ m41: Float, _ m42: Float, _ m43: Float, _ m44: Float) {
        self.m11 = m11
        self.m12 = m12
        self.m13 = m13
        self.m14 = m14
        self.m21 = m21
        self.m22 = m22
        self.m23 = m23
        self.m24 = m24
        self.m31 = m31
        self.m32 = m32
        self.m33 = m33
        self.m34 = m34
        self.m41 = m41
        self.m42 = m42
        self.m43 = m43
        self.m44 = m44
    }
    
    static func identity() -> Matrix {
        return Matrix(1, 0, 0, 0,
                      0, 1, 0, 0,
                      0, 0, 1, 0,
                      0, 0, 0, 1)
    }
    
    static func ==(matA: Matrix, matB: Matrix) -> Bool {
        guard matA.m11 == matB.m11,
              matA.m12 == matB.m12,
              matA.m13 == matB.m13,
              matA.m14 == matB.m14,
              matA.m21 == matB.m21,
              matA.m22 == matB.m22,
              matA.m23 == matB.m23,
              matA.m24 == matB.m24,
              matA.m31 == matB.m31,
              matA.m32 == matB.m32,
              matA.m33 == matB.m33,
              matA.m34 == matB.m34,
              matA.m41 == matB.m41,
              matA.m42 == matB.m42,
              matA.m43 == matB.m43,
              matA.m44 == matB.m44 else {
                  return false
              }
        return true
    }
    
    static func +(lhs: Matrix, rhs: Matrix) -> Matrix {
        return Matrix(lhs.m11 + rhs.m11, lhs.m12 + rhs.m12, lhs.m13 + rhs.m13, lhs.m14 + rhs.m14,
                      lhs.m21 + rhs.m21, lhs.m22 + rhs.m22, lhs.m23 + rhs.m23, lhs.m24 + rhs.m24,
                      lhs.m31 + rhs.m31, lhs.m32 + rhs.m32, lhs.m33 + rhs.m33, lhs.m34 + rhs.m34,
                      lhs.m41 + rhs.m41, lhs.m42 + rhs.m42, lhs.m43 + rhs.m43, lhs.m44 + rhs.m44)
    }
    
    static func -(lhs: Matrix, rhs: Matrix) -> Matrix {
        return Matrix(lhs.m11 - rhs.m11, lhs.m12 - rhs.m12, lhs.m13 - rhs.m13, lhs.m14 - rhs.m14,
                      lhs.m21 - rhs.m21, lhs.m22 - rhs.m22, lhs.m23 - rhs.m23, lhs.m24 - rhs.m24,
                      lhs.m31 - rhs.m31, lhs.m32 - rhs.m32, lhs.m33 - rhs.m33, lhs.m34 - rhs.m34,
                      lhs.m41 - rhs.m41, lhs.m42 - rhs.m42, lhs.m43 - rhs.m43, lhs.m44 - rhs.m44)
    }
    
    static func *(lhs: Matrix, scaler: Float) -> Matrix {
        return Matrix(lhs.m11 * scaler, lhs.m12 * scaler, lhs.m13 * scaler, lhs.m14 * scaler,
                      lhs.m21 * scaler, lhs.m22 * scaler, lhs.m23 * scaler, lhs.m24 * scaler,
                      lhs.m31 * scaler, lhs.m32 * scaler, lhs.m33 * scaler, lhs.m34 * scaler,
                      lhs.m41 * scaler, lhs.m42 * scaler, lhs.m43 * scaler, lhs.m44 * scaler)
    }
    
    static func *(lhs: Matrix, rhs: Matrix) -> Matrix {
        return Matrix((lhs.m11 * rhs.m11) + (lhs.m12 * rhs.m21) + (lhs.m13 * rhs.m31) + (lhs.m14 * rhs.m41),
                      (lhs.m11 * rhs.m12) + (lhs.m12 * rhs.m22) + (lhs.m13 * rhs.m32) + (lhs.m14 * rhs.m42),
                      (lhs.m11 * rhs.m13) + (lhs.m12 * rhs.m23) + (lhs.m13 * rhs.m33) + (lhs.m14 * rhs.m43),
                      (lhs.m11 * rhs.m14) + (lhs.m12 * rhs.m24) + (lhs.m13 * rhs.m34) + (lhs.m14 * rhs.m44),
                      
                      (lhs.m21 * rhs.m11) + (lhs.m22 * rhs.m21) + (lhs.m23 * rhs.m31) + (lhs.m24 * rhs.m41),
                      (lhs.m21 * rhs.m12) + (lhs.m22 * rhs.m22) + (lhs.m23 * rhs.m32) + (lhs.m24 * rhs.m42),
                      (lhs.m21 * rhs.m13) + (lhs.m22 * rhs.m23) + (lhs.m23 * rhs.m33) + (lhs.m24 * rhs.m43),
                      (lhs.m21 * rhs.m14) + (lhs.m22 * rhs.m24) + (lhs.m23 * rhs.m34) + (lhs.m24 * rhs.m44),
                      
                      (lhs.m31 * rhs.m11) + (lhs.m32 * rhs.m21) + (lhs.m33 * rhs.m31) + (lhs.m34 * rhs.m41),
                      (lhs.m31 * rhs.m12) + (lhs.m32 * rhs.m22) + (lhs.m33 * rhs.m32) + (lhs.m34 * rhs.m42),
                      (lhs.m31 * rhs.m13) + (lhs.m32 * rhs.m23) + (lhs.m33 * rhs.m33) + (lhs.m34 * rhs.m43),
                      (lhs.m31 * rhs.m14) + (lhs.m32 * rhs.m24) + (lhs.m33 * rhs.m34) + (lhs.m34 * rhs.m44),
                      
                      (lhs.m41 * rhs.m11) + (lhs.m42 * rhs.m21) + (lhs.m43 * rhs.m31) + (lhs.m44 * rhs.m41),
                      (lhs.m41 * rhs.m12) + (lhs.m42 * rhs.m22) + (lhs.m43 * rhs.m32) + (lhs.m44 * rhs.m42),
                      (lhs.m41 * rhs.m13) + (lhs.m42 * rhs.m23) + (lhs.m43 * rhs.m33) + (lhs.m44 * rhs.m43),
                      (lhs.m41 * rhs.m14) + (lhs.m42 * rhs.m24) + (lhs.m43 * rhs.m34) + (lhs.m44 * rhs.m44))
    }
    
    func transform(vec: Vector) -> Vector {
        
        return Vector((m11 * vec.x) + (m12 * vec.y) + (m13 * vec.z) + (m14 * vec.w),
                      (m21 * vec.x) + (m22 * vec.y) + (m23 * vec.z) + (m24 * vec.w),
                      (m31 * vec.x) + (m32 * vec.y) + (m33 * vec.z) + (m34 * vec.w),
                      (m41 * vec.x) + (m42 * vec.y) + (m43 * vec.z) + (m44 * vec.w))
    }
    
    static func translation(transX: Float, transy: Float, transZ: Float) -> Matrix {
        return Matrix(1, 0, 0, transX,
                      0, 1, 0, transy,
                      0, 0, 1, transZ,
                      0, 0, 0, 1)
    }
    
    static func rotation(rotX: Float, rotY: Float, rotZ: Float) -> Matrix {
        
        let cosX = cosf(-rotX);
        let cosY = cosf(-rotY);
        let cosZ = cosf(-rotZ);
        let sinX = sinf(-rotX);
        let sinY = sinf(-rotY);
        let sinZ = sinf(-rotZ);
        
        
        let rotateX = Matrix(1,     0,     0,      0,
                             0,     cosX, -sinX,   0,
                             0,     sinX,  cosX,   0,
                             0,     0,     0,      1)
        
        let rotateY = Matrix(cosY,  0,  sinY,      0,
                             0,     1,     0,      0,
                             -sinY, 0,  cosY,      0,
                             0,     0,     0,      1)
        
        let rotateZ = Matrix(cosZ, -sinZ,  0,      0,
                             sinZ,  cosZ,  0,      0,
                             0,     0,     1,      0,
                             0,     0,     0,      1)
        let rotZY = rotateZ * rotateY
        return rotZY * rotateX
    }
    
    
    static func scale(scaleX: Float, scaley: Float, scaleZ: Float) -> Matrix {
        return Matrix(scaleX, 0,      0,      0,
                      0,      scaley, 0,      0,
                      0,      0,      scaleZ, 0,
                      0,      0,      0,      1)
        
    }
         
    
}
