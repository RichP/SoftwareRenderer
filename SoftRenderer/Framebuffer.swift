//
//  Framebuffer.swift
//  SoftRenderer
//
//  Created by Richard Pickup on 16/01/2022.
//

import Foundation
import UIKit

struct Color {
    let r, g, b, a: UInt8
    
    init(r: UInt8, g: UInt8, b: UInt8, a: UInt8 = 255) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
    
    static func +=( lhs: inout Color, rhs: Color) {
        let red = min(Int(lhs.r) + Int(rhs.r), 255)
        let green = min(Int(lhs.g) + Int(rhs.g), 255)
        let blue = min(Int(lhs.b) + Int(rhs.b), 255)
        lhs = Color(r: UInt8(red), g: UInt8(green), b: UInt8(blue), a: 255)
    }
}

extension Color {
    static let red = Color(r: 255, g: 0, b: 0)
    static let green = Color(r: 0, g: 255, b: 0)
    static let blue = Color(r: 0, g: 0, b: 255)
    static let magenta = Color(r: 255, g: 0, b: 255)
    static let cyan = Color(r: 0, g: 255, b: 255)
    static let white = Color(r: 255, g: 255, b: 255)
    static let black = Color(r: 0, g: 0, b: 0)
}

class FrameBuffer {
    private(set) var pixels: [Color]
    let width: Int
    
    init(width: Int, pixels: [Color]) {
        self.width = width
        self.pixels = pixels
    }
}

extension FrameBuffer {
    var height: Int {
        return pixels.count / width
    }
    
    subscript(x: Int, y: Int) -> Color {
        get { return pixels[y * width + x] }
        set { pixels[y * width + x] = newValue}
    }
    
    convenience init(width: Int, height: Int, color: Color) {
        let pixels = Array(repeating: color, count: width * height)
        self.init(width: width, pixels: pixels)
    }
    
    func clear(_ color: Color = Color(r: 0,g: 0,b: 0,a: 255)) {
        pixels = pixels.map { _ in color }
    }
    
    func fill(rect: CGRect, color: Color) {
        for y in Int(rect.minY) ..< Int(rect.maxY) {
            for x in Int(rect.minX) ..< Int(rect.maxX) {
                self[x, y] = color
            }
        }
    }
    
    func setPixel(_ x: Int, _ y: Int, _ color: Color) {
        self[x, y] = color
    }
}

extension UIImage {
    convenience init?(frameBuffer: FrameBuffer) {
        let alphaInfo = CGImageAlphaInfo.premultipliedLast
        let bytesPerPixel = MemoryLayout<Color>.size
        let bytesPerRow = frameBuffer.width * bytesPerPixel
        
        guard let providerREf = CGDataProvider(data: Data(
            bytes: frameBuffer.pixels, count: frameBuffer.height * bytesPerRow
        ) as CFData) else {
            return nil
        }
        
        guard let cgImage = CGImage(
            width: frameBuffer.width,
            height: frameBuffer.height,
            bitsPerComponent: 8,
            bitsPerPixel: bytesPerPixel * 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: alphaInfo.rawValue),
            provider: providerREf,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent) else {
                return nil
            }
        self.init(cgImage: cgImage)
    }
}
