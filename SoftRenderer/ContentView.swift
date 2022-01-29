//
//  ContentView.swift
//  SoftRenderer
//
//  Created by Richard Pickup on 16/01/2022.
//

import SwiftUI

class DisplayLink: NSObject, ObservableObject {
    @Published var frameDuration: CFTimeInterval = 0
    @Published var frameChange: Bool = false
    
    static let sharedInstance: DisplayLink = DisplayLink()
    
    func createDisplayLink() {
        let displaylink = CADisplayLink(target: self, selector: #selector(frame))
        displaylink.add(to: .current, forMode: RunLoop.Mode.default)
    }
    
    @objc func frame(displaylink: CADisplayLink) {
        frameDuration = displaylink.targetTimestamp - displaylink.timestamp
      //  print(1 / frameDuration)
        frameChange.toggle()
    }
    
}

struct ContentView: View {
    @ObservedObject var displayLink = DisplayLink.sharedInstance
    @ObservedObject var gameApp = RendererScene()
    init() {
        DisplayLink.sharedInstance.createDisplayLink()
        gameApp.setup(width: 320, height: 240)
    }
    
    var body: some View {
        VStack {
            
            Canvas { context, size in
                if let image = gameApp.uiImage {
                    context.draw(Image(uiImage: image)
                                    .antialiased(false)
                                    .interpolation(.none),
                                 at: CGPoint(x: 0, y: 0), anchor: .topLeading)
                }
            }
            .frame(width: 320, height: 240)
            .onChange(of: displayLink.frameChange) { _ in
                gameApp.update()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
