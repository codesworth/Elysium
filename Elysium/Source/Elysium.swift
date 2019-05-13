//
//  Elysium.swift
//  QuotesMaker
//
//  Created by Shadrach Mensah on 17/03/2019.
//  Copyright © 2019 Shadrach Mensah. All rights reserved.
//

import UIKit
import Accelerate
import ModelIO

public class Elysium{
    
    private var sourceImage:UIImage
    private var cgImage:CGImage{
        return sourceImage.cgImage!
    }
    
    private var scale:CGFloat{
        return UIScreen.main.scale
    }
    
    public init(source:UIImage) {
        sourceImage = source
        print("Image dimens is: \(source.size.width) X \(source.size.height)")
    }

    func makeScaledTo(_ quality:ImageQuality,_ sourceImage:UIImage)->UIImage?{
        //let sourceImage = sourceImage ?? self.sourceImage
        let quality = quality > 1 ? 1 : max(quality,0.0001)
        //Create Source Buffer

        var format = vImage_CGImageFormat(bitsPerComponent: 8, bitsPerPixel: 32, colorSpace: nil, bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.first.rawValue), version: 0, decode: nil, renderingIntent: CGColorRenderingIntent.defaultIntent)
        var sourceBuff = vImage_Buffer()
        
        defer {
            sourceBuff.data.deallocate()
        }
        
        var error = vImageBuffer_InitWithCGImage(&sourceBuff, &format, nil, cgImage, numericCast(kvImageNoFlags))
        guard error == kvImageNoError else {return nil}
        
        //Create Destination Buffer
        
        let destinationWidth = Int(sourceImage.size.width * quality)
        let destinationHeight = Int(sourceImage.size.height * quality)
        
        let bytPerPixel = cgImage.bitsPerPixel / 8
        let destinationBytesPerRow = destinationWidth * bytPerPixel
        
        let destinationData = UnsafeMutablePointer<UInt8>.allocate(capacity: destinationHeight * destinationBytesPerRow)
        
        defer{ destinationData.deallocate() }
       
        var destinationBuffer = vImage_Buffer(data: destinationData, height: vImagePixelCount(destinationHeight), width: vImagePixelCount(destinationWidth), rowBytes: destinationBytesPerRow)
        
        //scale Image
        
        error = vImageScale_ARGB8888(&sourceBuff, &destinationBuffer, nil, numericCast(kvImageHighQualityResampling))
        guard error == kvImageNoError else {return nil}
        
        // create a CGImage from vImage_Buffer
        
        let destCGImage = vImageCreateCGImageFromBuffer(&destinationBuffer, &format, nil, nil, numericCast(kvImageNoFlags), &error)?.takeRetainedValue()
        guard error == kvImageNoError else {return nil}
        
        //Create UIImage
        
        let scaledImage = destCGImage.flatMap{UIImage(cgImage: $0, scale: 0.0, orientation: sourceImage.imageOrientation)}
        return scaledImage
    }
    
    public func makeScaledImage(_ quality:Quality,image:UIImage)->UIImage?{
        return makeScaledTo(quality.rawValue,image)
    }
    
    public func makeStandardImage(_ image:UIImage)->UIImage?{
        if let image = makeScaledTo(0.5,image){
            if image.size.area > standardQaulity{
                return makeStandardImage(image)
            }
            return image
        }
        return nil
    }
    
    public func generateThumbnailImage()->UIImage?{
        let cfData = NSData(data: sourceImage.jpegData(compressionQuality: 1)!) as CFData
        let options:[NSString:NSObject] = [kCGImageSourceThumbnailMaxPixelSize: max(sourceImage.size.width,sourceImage.size.height) / 2 as NSObject, kCGImageSourceCreateThumbnailFromImageAlways: true as NSObject]
        guard let imageSource = CGImageSourceCreateWithData(cfData,nil) else {return nil}
        
        let scaled = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary).flatMap{UIImage(cgImage: $0)}
        return scaled
    }
    
    public func transformImage()->UIImage?{
        if let data = sourceImage.jpegData(compressionQuality: 0.5){
            print("ImageJPEG size is \(data.count)")
            return UIImage(data: data)
        }
        return nil
    }
    
    
}


public extension Elysium{
    
    typealias ImageQuality = CGFloat
    
    var standardQaulity:CGFloat{
        return 720 * 1280
    }
    
    public enum Quality:ImageQuality {
        case max = 1
        case min = 0.05
        case average = 0.5
        case `default` = 0.7
        case low = 0.35
    }
    
    
}


extension CGSize{
    
    
    var area:CGFloat{
        return width * height
    }
}
