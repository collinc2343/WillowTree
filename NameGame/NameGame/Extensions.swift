//
//  Extensions.swift
//  NameGame
//
//  Created by Collin Chandler on 2/10/18.
//  Copyright © 2018 WillowTree Apps. All rights reserved.
//

import Foundation
import UIKit

extension UIColor
{
    struct appColors
    {
        static let placeHolderColor = UIColor(red: 42.0/255.0, green: 120.0/255.0, blue: 133.0/255.0, alpha: 1.0)
    }
}

//All this for Whitney French and it doesn't even work! To be fair I only adapted something I found online from swift 2 to swift 3 and then changed it from transparent to white.
extension UIImage {
    
    func imageByCroppingWhitePixels() -> UIImage {
        let rect = self.cropRectForImage(image: self)
        return cropImage(toRect: rect)
    }
    
    internal func cropImage(toRect: CGRect) -> UIImage
    {
        guard let cropCGImage = self.cgImage?.cropping(to: toRect) else
        {
            return UIImage()
        }
        return UIImage(cgImage: cropCGImage)
    }
    
    internal func cropRectForImage(image:UIImage) -> CGRect {
        guard let imageAsCGImage = image.cgImage else
        {
            return CGRect.zero
        }
        let context:CGContext? = self.createARGBBitmapContext(inImage: imageAsCGImage)
        if let context = context {
            let width = Int(imageAsCGImage.width)
            let height = Int(imageAsCGImage.height)
            let rect:CGRect = CGRect(x: 0.0, y: 0.0, width: CGFloat(width), height: CGFloat(height))
            context.draw(imageAsCGImage, in: rect)
            var lowX:Int = width
            var lowY:Int = height
            var highX:Int = 0
            var highY:Int = 0
            let data:UnsafeMutableRawPointer? = context.data
            if let data = data {
                let dataType:UnsafeMutablePointer<UInt8>? = data.assumingMemoryBound(to: UInt8.self)
                if let dataType = dataType {
                    for y in 0..<height {
                        for x in 0..<width {
                            let pixelRIndex:Int = ((width * y + x) * 4) + 1 /* 4 for A, R, G, B and + 1 for R*/;
                            let pixelGIndex:Int = ((width * y + x) * 4) + 2 /* 4 for A, R, G, B and + 2 for G*/;
                            let pixelBIndex:Int = ((width * y + x) * 4) + 3 /* 4 for A, R, G, B and + 3 for B*/;
                            if (dataType[pixelRIndex] != 1 || dataType[pixelGIndex] != 1 || dataType[pixelBIndex] != 1) {
                                //R or G or B value is not 1; pixel is not white.
                                if (x < lowX) { lowX = x };
                                if (x > highX) { highX = x };
                                if (y < lowY) { lowY = y};
                                if (y > highY) { highY = y};
                            }
                            else
                            {
                                print("White!")
                            }
                        }
                    }
                }
                free(data)
            } else {
                return CGRect.zero
            }
            return CGRect(x: CGFloat(lowX), y: CGFloat(lowY), width: CGFloat(highX-lowX), height: CGFloat(highY-lowY))
            
        }
        return CGRect.zero
    }
    
    internal func createARGBBitmapContext(inImage: CGImage) -> CGContext {
        var bitmapByteCount = 0
        var bitmapBytesPerRow = 0
        
        //Get image width, height
        let pixelsWide = inImage.width
        let pixelsHigh = inImage.height
        
        // Declare the number of bytes per row. Each pixel in the bitmap in this
        // example is represented by 4 bytes; 8 bits each of red, green, blue, and
        // alpha.
        bitmapBytesPerRow = Int(pixelsWide) * 4
        bitmapByteCount = bitmapBytesPerRow * Int(pixelsHigh)
        
        // Use the generic RGB color space.
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        // Allocate memory for image data. This is the destination in memory
        // where any drawing to the bitmap context will be rendered.
        let bitmapData = malloc(bitmapByteCount)
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
        
        // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
        // per component. Regardless of what the source image format is
        // (CMYK, Grayscale, and so on) it will be converted over to the format
        // specified here by CGBitmapContextCreate.
        let context = CGContext(data: bitmapData, width: pixelsWide, height: pixelsHigh, bitsPerComponent: 8, bytesPerRow: bitmapBytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        return context!
    }
}
