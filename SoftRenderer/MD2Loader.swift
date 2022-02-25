//
//  MD2Loader.swift
//  SoftRenderer
//
//  Created by Richard Pickup on 18/01/2022.
//

import Foundation

struct MD2Header {
    var ident: Int32
    var version: Int32
    var skinWidth: Int32
    var skinHeight: Int32
    var frameSize: Int32
    var numSkins: Int32
    var numVertices: Int32
    var numTexCoords: Int32
    var numTriangles: Int32
    var numGlCommands: Int32
    var numFrames: Int32
    var offsetSkins: Int32
    var offsetTexCoords: Int32
    var offsetTriangles: Int32
    var offsetFrames: Int32
    var offsetGlCommands: Int32
    var offsetEnd: Int32
}

struct PcxHeader
{
    var ID: UInt8
    var Version: UInt8
    var Encoding: UInt8
    var BitsPerPixel: UInt8
    var XMin: UInt16
    var YMin: UInt16
    var XMax: UInt16
    var YMax: UInt16
    var HRes: UInt16
    var VRes: UInt16
    var ClrMap: [UInt8]; // 16 * 3
    var Reserved: UInt8
    var NumPlanes: UInt8
    var BytesPerLine: UInt16
    var Pal: UInt16
    var Filler: [UInt8];   //58
    
    //128 bytes
    
    init(bytes: Data) {
        var byteData = bytes
        let unit16Size = MemoryLayout<UInt16>.size
        let uint8Size = MemoryLayout<UInt8>.size
        
        self.ID = byteData[0]
        self.Version = byteData[1]
        self.Encoding = byteData[2]
        self.BitsPerPixel = byteData[3]
        
        var range = 0..<(uint8Size * 4)
        byteData.removeSubrange(range)
        
        var range16 = 0..<(unit16Size * 6)
        var bytes16 = byteData.subdata(in: range16)
        byteData.removeSubrange(range16)
        var shorts: [UInt16] = bytes16.elements()
        
        self.XMin = shorts[0]
        self.YMin = shorts[1]
        self.XMax = shorts[2]
        self.YMax = shorts[3]
        self.HRes = shorts[4]
        self.VRes = shorts[5]
        
        let clrMapRange = 0..<(uint8Size * (16 * 3))
        let clrMapBytes = byteData.subdata(in: clrMapRange)
        byteData.removeSubrange(clrMapRange)
        let ClrMap: [UInt8] = clrMapBytes.elements()
        self.ClrMap = ClrMap
        self.Reserved = byteData[0]
        self.NumPlanes = byteData[1]
        
        range = 0..<(uint8Size * 2)
        byteData.removeSubrange(range)
        
        range16 = 0..<(unit16Size * 2)
        bytes16 = byteData.subdata(in: range16)
        byteData.removeSubrange(range16)
        shorts = bytes16.elements()
        self.BytesPerLine = shorts[0]
        self.Pal = shorts[1]
        
        let fillerRange = 0..<(uint8Size * 58)
        let fillerBytes = byteData.subdata(in: fillerRange)
        self.Filler = fillerBytes.elements()
    }
}

struct MD2Vertex {
    var v: (UInt8, UInt8, UInt8)
    var lightnormalindex: UInt8
}

struct MD2Triangle {
    var vertexIndex: (UInt16, UInt16, UInt16)
    var uvIndex: (UInt16, UInt16, UInt16)
    
    
}

struct MD2TexCoord {
    var texCoord: (UInt16, UInt16)
}

struct MD2Frame {
    var scale: (Float, Float, Float)
    var translate: (Float, Float, Float)
    var name: String
    var verts: [MD2Vertex]
    
    init(bytes: Data, numVerts: Int) {
        var byteData = bytes
        let floatSize = MemoryLayout<Float>.size
        let scaleRange = 0..<(floatSize * 3)
        let scaleBytes = byteData.subdata(in: scaleRange)
        byteData.removeSubrange(scaleRange)
        let scale: [Float] = scaleBytes.elements()
        
        let transRange = 0..<(floatSize * 3)
        let transBytes = byteData.subdata(in: transRange)
        byteData.removeSubrange(transRange)
        let translate: [Float] = transBytes.elements()
        
        let charSize = MemoryLayout<CChar>.size
        let charRange = 0..<(charSize * 16)
        let charBytes = byteData.subdata(in: charRange)
        byteData.removeSubrange(charRange)
        let chars: [CChar] = charBytes.elements()
        
        let nameString = String(cString: chars)
        
        let verts: [MD2Vertex] = byteData.elements()
        
        self.scale = (scale[0], scale[1], scale[2])
        self.translate = (translate[0], translate[1], translate[2])
        self.name = nameString
        self.verts = verts
    }
}

class MD2Loader {
    
    let md2Indentifier = 844121161
    let md2Version = 8
    
    func loadModel(filename: String, textureName: String) -> MD2Object3D? {
        guard let filePath = Bundle.main.url(forResource: "tris", withExtension: "md2") else {
            return nil
        }
        
        let file = try? FileHandle(forReadingFrom: filePath)
        
        if file == nil {
            print("File open failed")
        } else {
            
            guard let headerData = try? file?.read(upToCount: MemoryLayout<MD2Header>.stride) else {
                file?.closeFile()
                return nil
            }
            let header = headerData.withUnsafeBytes {
                $0.load(as: MD2Header.self)
            }
            
            //Check valid MD2 File
            if header.ident != md2Indentifier || header.version != md2Version {
                file?.closeFile()
                return nil
            }
            
            
            try? file?.seek(toOffset: UInt64(header.offsetTriangles))
            let triSize = MemoryLayout<MD2Triangle>.size
            
            guard let trisDat = try? file?.read(upToCount: triSize * Int(header.numTriangles)) else {
                file?.closeFile()
                return nil
            }
            let tris: [MD2Triangle] = trisDat.elements()
            
            try? file?.seek(toOffset: UInt64(header.offsetTexCoords))
            let texSize = MemoryLayout<MD2TexCoord>.size
            guard let texDat = try? file?.read(upToCount: texSize * Int(header.numTexCoords)) else {
                file?.closeFile()
                return nil
            }
            let tex: [MD2TexCoord] = texDat.elements()
            
            let pcx = loadPCX(fileName: textureName)
            
            var frames: [MD2Frame] = []
            frames.reserveCapacity(Int(header.numFrames) )
            for i in 0..<header.numFrames {
                let offset = UInt64(header.offsetFrames + (i * header.frameSize))
                try? file?.seek(toOffset: offset)
                guard let frameDat = try? file?.read(upToCount: Int(header.frameSize)) else {
                    file?.closeFile()
                    return nil
                }
                let tempFrame = MD2Frame(bytes: frameDat, numVerts: Int(header.numVertices))
                
                frames.append(tempFrame)
            }
            let frame = frames[0]
            var polys: [Polygon] = []
            polys.reserveCapacity(Int(header.numTriangles))
            for i in 0..<header.numTriangles {
                let index = Int(i)
                let indices = (Int(tris[index].vertexIndex.0),
                               Int(tris[index].vertexIndex.1),
                               Int(tris[index].vertexIndex.2))
                
                let uvIndices = (Int(tris[index].uvIndex.0),
                                 Int(tris[index].uvIndex.1),
                                 Int(tris[index].uvIndex.2))
                
                let poly = Polygon(indices: indices,
                                   uvIndices: uvIndices,
                                   backfacing: false,
                                   averageZ: 1.0,
                                   normal: Vector(0, 0, 1, 0),
                                   litColor: Color.white,
                                   materialColor: Color(r: 255, g: 255, b: 255))
                
                polys.append(poly)
            }
            
            var frameVerts: [[Vertex]] = []
            for j in 0..<header.numFrames {
                var vertices: [Vertex] = []
                vertices.reserveCapacity(Int(header.numVertices))
                let iframe = frames[Int(j)]
                for i in 0..<header.numVertices {
                    let index = Int(i)
                    
                    
                    var vert = Vertex(x: Float(iframe.verts[index].v.0) * iframe.scale.0 + iframe.translate.0,
                                      y: Float(iframe.verts[index].v.2) * iframe.scale.2 + iframe.translate.2,
                                      z: Float(iframe.verts[index].v.1) * iframe.scale.1 + iframe.translate.1)
                    
                    let normal = MD2NORMALS[Int(frame.verts[index].lightnormalindex)]
                    vert.normal = Vector(normal[0], normal[2], normal[1], 0.0)
                    vertices.append(vert)
                }
                frameVerts.append(vertices)
            }
            
            
            var uvs: [TextureUV] = []
            
            for i in 0..<header.numTexCoords {
                let index = Int(i)
                let uv = TextureUV(u: Float(tex[index].texCoord.0),
                                   v: Float(tex[index].texCoord.1))
                uvs.append(uv)
            }
            
            
            let object = MD2Object3D(numUVs: Int(header.numTexCoords),
                                     numVerts: Int(header.numVertices),
                                     numPolys: Int(header.numTriangles),
                                     texWidth: Int(header.skinWidth),
                                     position: Vector(0, 0, 0, 0),
                                     polygons: polys,
                                     palette: pcx?.pal ?? [Color.magenta],
                                     texture: pcx?.tex ?? [],
                                     verts: frameVerts,
                                     texUVs: uvs)
            file?.closeFile()
            return object
            
        }
        return nil
    }
    
    func loadPCX(fileName: String) -> (tex: [UInt8], pal: [Color]?)? {
        guard let filePath = Bundle.main.url(forResource: fileName, withExtension: "pcx") else {
            return nil
        }
        
        let file = try? FileHandle(forReadingFrom: filePath)
        
        if file == nil {
            print("File open failed")
        } else {
            guard let headerData = try? file?.readToEnd() else {
                file?.closeFile()
                return nil
            }
            
            let header = PcxHeader(bytes: headerData)
            
            guard header.Version == 5,
                  header.BitsPerPixel == 8,
                  header.Encoding == 1,
                  header.NumPlanes == 1 else {
                      file?.closeFile()
                      return nil
                  }
            
            //also check pytesperline matches md2 skin width
            
            let xSize = header.XMax - header.XMin + 1
            let ySize = header.YMax - header.YMin + 1
            let size = Int(xSize) * Int(ySize)
            
            var offset = UInt64(128)
            try? file?.seek(toOffset: offset)
            var processByte: UInt8 = 0
            var colorByte: UInt8 = 0
            var count = 0
            
            //var texture = [UInt8](repeating: 0, count: Int(size))
            var texture: [UInt8] = [UInt8](repeating: 0, count: Int(size))
            while count < size {
                var buffer = try? file?.read(upToCount: 1)
                offset += 1
                try? file?.seek(toOffset: offset)
                
                processByte = buffer?.withUnsafeBytes {
                    $0.load(as: UInt8.self)
                } ?? 0
                
                if (processByte & 192) == 192 {
                    processByte &= 63
                    buffer = try? file?.read(upToCount: 1)
                    offset += 1
                    try? file?.seek(toOffset: offset)
                    colorByte = buffer?.withUnsafeBytes {
                        $0.load(as: UInt8.self)
                    } ?? 0
                    
                    for _ in 0..<processByte {
                        texture[count] = colorByte
                        count += 1
                    }
                    
                } else {
                    texture[count] = processByte
                    count += 1
                }
            }
            
            //also check size against expected skin
            var palette = [Color](repeating: Color.black, count: 256)
            if let dat = try? file?.readToEnd() {
                let numBytes = dat.count
                offset = UInt64(numBytes)
                //try? file?.seek(toOffset: offset)
                let rawPal: [UInt8] = dat.elements()
                if rawPal[0] == 12 {
                    for i in 1..<256 {
                        let palIndex = i
                        let palOffset = palIndex * 3
                        palette[i] = Color(r: rawPal[palOffset + 1],
                                           g: rawPal[palOffset + 2],
                                           b: rawPal[palOffset + 0])
                    }
                    
                }
                
            }
            file?.closeFile()
            return (tex: texture, pal: palette)
            
        }
        return nil
    }
}

extension Data {
    func elements <T> () -> [T] {
        return withUnsafeBytes { dataBytes in
            
            let buffer: UnsafePointer<T> = dataBytes.baseAddress!.assumingMemoryBound(to: T.self)
            return Array( UnsafeBufferPointer<T>(start: buffer, count: count / MemoryLayout<T>.size) )
        }
    }
}
