//
//  Polygon.swift
//  SoftRenderer
//
//  Created by Richard Pickup on 19/01/2022.
//

import Foundation

struct Polygon {
    var indices: (Int, Int, Int)
    var uvIndices: (Int, Int, Int)
    var backfacing: Bool
    var averageZ: Float
    var normal: Vector
    var litColor: Color
    var materialColor: Color
}
