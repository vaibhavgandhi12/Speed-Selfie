//
//  UIImage+Filters.m
//  PhotoFilters
//
//  Created by Roberto Breve on 6/2/12.
//  Copyright (c) 2012 Icoms. All rights reserved.
//

#import "UIImage+Filters.h"

@implementation UIImage (Filters)


+ (NSData *)resizeImage:(UIImage *)image
{
    CGSize origImageSize = [image size];
    CGRect newRect = CGRectMake(0, 0, 76,76);
    float ratio = MAX(newRect.size.width / origImageSize.width,
                      newRect.size.height / origImageSize.height);
    // NSLog(@"ratio: ---> %f",ratio);
    UIGraphicsBeginImageContextWithOptions(newRect.size, NO, 0.0);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:newRect
                                                    cornerRadius:5.0];
    [path addClip];
    CGRect imageRect;
    imageRect.size.width = ratio * origImageSize.width;
    imageRect.size.height = ratio * origImageSize.height;
    imageRect.origin.x = (newRect.size.width - imageRect.size.width) / 2.0;
    imageRect.origin.y = (newRect.size.height - imageRect.size.height) / 2.0;
    [image drawInRect:imageRect];
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    
    NSData *data = UIImagePNGRepresentation(smallImage);
    UIGraphicsEndImageContext();
    return data;
}

- (UIImage*)saturateImage:(float)saturationAmount withContrast:(float)contrastAmount{
    UIImage *sourceImage = self;
    
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CIFilter *filter= [CIFilter filterWithName:@"CIColorControls"];
    
    CIImage *inputImage = [[CIImage alloc] initWithImage:sourceImage];
    
    [filter setValue:inputImage forKey:@"inputImage"];
    
    [filter setValue:[NSNumber numberWithFloat:saturationAmount] forKey:@"inputSaturation"];
    [filter setValue:[NSNumber numberWithFloat:contrastAmount] forKey:@"inputContrast"];
    
    
    return [self imageFromContext:context withFilter:filter];
    
}


- (UIImage*)vignetteWithRadius:(float)inputRadius andIntensity:(float)inputIntensity{
 

     CIContext *context = [CIContext contextWithOptions:nil];
     
     CIFilter *filter= [CIFilter filterWithName:@"CIVignette"];
     
     CIImage *inputImage = [[CIImage alloc] initWithImage:self];
     
     [filter setValue:inputImage forKey:@"inputImage"];
     
     [filter setValue:[NSNumber numberWithFloat:inputIntensity] forKey:@"inputIntensity"];
     [filter setValue:[NSNumber numberWithFloat:inputRadius] forKey:@"inputRadius"];
     
     return [self imageFromContext:context withFilter:filter];
}

-(UIImage*)worn{
    CIImage *beginImage = [[CIImage alloc] initWithImage:self];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIWhitePointAdjust" 
                                  keysAndValues: kCIInputImageKey, beginImage, 
                        @"inputColor",[CIColor colorWithRed:212 green:235 blue:200 alpha:1],
                        nil];
    CIImage *outputImage = [filter outputImage];
    
    CIFilter *filterB = [CIFilter filterWithName:@"CIColorControls" 
                                   keysAndValues: kCIInputImageKey, outputImage, 
                         @"inputSaturation", [NSNumber numberWithFloat:.8],
                         @"inputContrast", [NSNumber numberWithFloat:0.8], 
                         nil];
    CIImage *outputImageB = [filterB outputImage];
    
    CIFilter *filterC = [CIFilter filterWithName:@"CITemperatureAndTint" 
                                   keysAndValues: kCIInputImageKey, outputImageB, 
                         @"inputNeutral",[CIVector vectorWithX:6500 Y:3000 Z:0],
                         @"inputTargetNeutral",[CIVector vectorWithX:5000 Y:0 Z:0],
                         nil];
    CIImage *outputImageC = [filterC outputImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef imageRef = [context createCGImage:outputImageC fromRect:outputImageC.extent];
    UIImage *image = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return image;
}


-(UIImage* )blendMode:(NSString *)blendMode withImageNamed:(NSString *) imageName{
    
    /*
     Blend Modes
     
     CISoftLightBlendMode
     CIMultiplyBlendMode
     CISaturationBlendMode
     CIScreenBlendMode
     CIMultiplyCompositing
     CIHardLightBlendMode
     */
    
    CIImage *inputImage = [[CIImage alloc] initWithImage:self];
    
    //try with different textures
    CIImage *bgCIImage = [[CIImage alloc] initWithImage:[UIImage imageNamed:imageName]];


    CIContext *context = [CIContext contextWithOptions:nil];
    
    CIFilter *filter= [CIFilter filterWithName:blendMode];
    
    
    // inputBackgroundImage most be the same size as the inputImage

    [filter setValue:inputImage forKey:@"inputBackgroundImage"];
    [filter setValue:bgCIImage forKey:@"inputImage"];
    
    return [self imageFromContext:context withFilter:filter];
}


- (UIImage *)curveFilter
{
 
    
    CIImage *inputImage =[[CIImage alloc] initWithImage:self];
    
    CIContext *context = [CIContext contextWithOptions:nil];

    CIFilter *filter = [CIFilter filterWithName:@"CIToneCurve"];
    
    
    [filter setDefaults];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[CIVector vectorWithX:0.0  Y:0.0] forKey:@"inputPoint0"]; // default
    [filter setValue:[CIVector vectorWithX:0.25 Y:0.15] forKey:@"inputPoint1"]; 
    [filter setValue:[CIVector vectorWithX:0.5  Y:0.5] forKey:@"inputPoint2"];
    [filter setValue:[CIVector vectorWithX:0.75  Y:0.85] forKey:@"inputPoint3"];
    [filter setValue:[CIVector vectorWithX:1.0  Y:1.0] forKey:@"inputPoint4"]; // default
  
    return [self imageFromContext:context withFilter:filter];
}


- (UIImage*)imageFromContext:(CIContext*)context withFilter:(CIFilter*)filter
{
    
    CGImageRef imageRef = [context createCGImage:[filter outputImage] fromRect:filter.outputImage.extent];
    UIImage *image = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return image;
    
}





@end
