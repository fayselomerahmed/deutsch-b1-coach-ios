import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

guard CommandLine.arguments.count == 3 else {
    fatalError("Usage: remove_mascot_chroma.swift input.png output.png")
}

let inputURL = URL(fileURLWithPath: CommandLine.arguments[1])
let outputURL = URL(fileURLWithPath: CommandLine.arguments[2])
guard let source = CGImageSourceCreateWithURL(inputURL as CFURL, nil),
      let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
else {
    fatalError("Could not read \(inputURL.path)")
}

let width = image.width
let height = image.height
let bytesPerRow = width * 4
var pixels = [UInt8](repeating: 0, count: bytesPerRow * height)
let colorSpace = CGColorSpaceCreateDeviceRGB()
let bitmapInfo = CGBitmapInfo.byteOrder32Big.rawValue
    | CGImageAlphaInfo.premultipliedLast.rawValue

guard let context = CGContext(
    data: &pixels,
    width: width,
    height: height,
    bitsPerComponent: 8,
    bytesPerRow: bytesPerRow,
    space: colorSpace,
    bitmapInfo: bitmapInfo
) else {
    fatalError("Could not create image context")
}

context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))

let transparentThreshold = 12.0
let opaqueThreshold = 220.0

for offset in stride(from: 0, to: pixels.count, by: 4) {
    let pixelIndex = offset / 4
    let x = pixelIndex % width
    let y = pixelIndex / width
    if x < 2 || x >= width - 2 || y < 2 || y >= height - 2 {
        pixels[offset] = 0
        pixels[offset + 1] = 0
        pixels[offset + 2] = 0
        pixels[offset + 3] = 0
        continue
    }

    let red = Double(pixels[offset])
    let green = Double(pixels[offset + 1])
    let blue = Double(pixels[offset + 2])
    let distance = sqrt(pow(red - 255, 2) + pow(green, 2) + pow(blue - 255, 2))

    let alpha: Double
    if distance <= transparentThreshold {
        alpha = 0
    } else if distance >= opaqueThreshold {
        alpha = 1
    } else {
        let normalized = (distance - transparentThreshold) / (opaqueThreshold - transparentThreshold)
        alpha = normalized * normalized * (3 - (2 * normalized))
    }

    guard alpha > 0 else {
        pixels[offset] = 0
        pixels[offset + 1] = 0
        pixels[offset + 2] = 0
        pixels[offset + 3] = 0
        continue
    }

    if alpha < 1 {
        let inverse = 1 - alpha
        let correctedRed = max(0, min(255, (red - (inverse * 255)) / alpha))
        let correctedGreen = max(0, min(255, green / alpha))
        let correctedBlue = max(0, min(255, (blue - (inverse * 255)) / alpha))
        pixels[offset] = UInt8((correctedRed * alpha).rounded())
        pixels[offset + 1] = UInt8((correctedGreen * alpha).rounded())
        pixels[offset + 2] = UInt8((correctedBlue * alpha).rounded())
    }
    pixels[offset + 3] = UInt8((alpha * 255).rounded())
}

guard let outputContext = CGContext(
    data: &pixels,
    width: width,
    height: height,
    bitsPerComponent: 8,
    bytesPerRow: bytesPerRow,
    space: colorSpace,
    bitmapInfo: bitmapInfo
), let outputImage = outputContext.makeImage(),
      let destination = CGImageDestinationCreateWithURL(
        outputURL as CFURL,
        UTType.png.identifier as CFString,
        1,
        nil
      )
else {
    fatalError("Could not prepare PNG output")
}

CGImageDestinationAddImage(destination, outputImage, nil)
guard CGImageDestinationFinalize(destination) else {
    fatalError("Could not write \(outputURL.path)")
}

print("Wrote transparent mascot atlas: \(width)x\(height)")
