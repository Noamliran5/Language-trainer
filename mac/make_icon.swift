// Draws the app icon: swift make_icon.swift out.png
import AppKit

let size: CGFloat = 1024
let img = NSImage(size: NSSize(width: size, height: size))
img.lockFocus()

// Rounded square with the site's gradient
let inset: CGFloat = 100
let rect = NSRect(x: inset, y: inset, width: size - 2 * inset, height: size - 2 * inset)
let path = NSBezierPath(roundedRect: rect, xRadius: 185, yRadius: 185)
NSGradient(colors: [NSColor(red: 0.06, green: 0.05, blue: 0.16, alpha: 1),
                    NSColor(red: 0.19, green: 0.17, blue: 0.39, alpha: 1)])!
    .draw(in: path, angle: -60)

// Speech bubble
let bubble = NSBezierPath(roundedRect: NSRect(x: 230, y: 380, width: 564, height: 380),
                          xRadius: 90, yRadius: 90)
bubble.move(to: NSPoint(x: 330, y: 400))
bubble.line(to: NSPoint(x: 300, y: 270))
bubble.line(to: NSPoint(x: 440, y: 390))
bubble.close()
NSColor(red: 0.91, green: 0.27, blue: 0.38, alpha: 1).setFill()
bubble.fill()

// Text
let style = NSMutableParagraphStyle()
style.alignment = .center
let attrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 150, weight: .heavy),
    .foregroundColor: NSColor.white,
    .paragraphStyle: style,
]
("¡Hola!" as NSString).draw(in: NSRect(x: 230, y: 470, width: 564, height: 200), withAttributes: attrs)

img.unlockFocus()
let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!
try! rep.representation(using: .png, properties: [:])!
    .write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
