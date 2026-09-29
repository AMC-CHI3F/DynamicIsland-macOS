import Cocoa
import SwiftUI

class IslandPanel: NSPanel {
    init<Content: View>(contentView: Content) {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 110),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        self.isOpaque = false
        self.backgroundColor = .clear
        self.level = .floating
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.hasShadow = false
        
        self.contentView = NSHostingView(rootView: contentView)
        self.centerOnTop()
    }
    
    func centerOnTop() {
        if let screen = NSScreen.main {
            let x = (screen.frame.width - self.frame.width) / 2
            let y = screen.frame.maxY - self.frame.height - 4
            self.setFrameOrigin(NSPoint(x: x, y: y))
        }
    }
}