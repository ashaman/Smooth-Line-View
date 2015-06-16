//
//  CameraServer.m
//  Encoder Demo
//
//  Created by Geraint Davies on 19/02/2013.
//  Copyright (c) 2013 GDCL http://www.gdcl.co.uk/license.htm
//

#import "CameraServer.h"
#import "AVEncoder.h"
#import "RTSPServer.h"


static CameraServer* theServer;

@interface CameraServer  () {
    AVEncoder* _encoder;
    RTSPServer* _rtsp;
}
@end


@implementation CameraServer

+ (void) initialize
{
    if (self == [CameraServer class])
    {
        theServer = [[CameraServer alloc] init];
    }
}

+ (CameraServer*) server
{
    return theServer;
}

- (void) startup
{
    if (_encoder == nil)
    {
        NSLog(@"Starting up server");
        
        // create an encoder
        _encoder = [AVEncoder encoderForHeight:1136 andWidth:640];
        [_encoder encodeWithBlock:^int(NSArray* data, double pts) {
            if (_rtsp != nil)
            {
                _rtsp.bitrate = _encoder.bitspersecond;
                [_rtsp onVideoData:data time:pts];
            }
            return 0;
        } onParams:^int(NSData *data) {
            _rtsp = [RTSPServer setupListener:data];
            return 0;
        }];
    }
}


- (void) shutdown
{
    NSLog(@"shutting down server");
    if (_rtsp)
    {
        [_rtsp shutdownServer];
    }
    if (_encoder)
    {
        [ _encoder shutdown];
    }
}

- (NSString*) getURL
{
    NSString* ipaddr = [RTSPServer getIPAddress];
    NSString* url = [NSString stringWithFormat:@"rtsp://%@/", ipaddr];
    return url;
}

#pragma mark -
- (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image
{
    CGSize frameSize = CGSizeMake(CGImageGetWidth(image),
                                  CGImageGetHeight(image));
    NSDictionary *options =
    [NSDictionary dictionaryWithObjectsAndKeys:
     [NSNumber numberWithBool:YES],
     kCVPixelBufferCGImageCompatibilityKey,
     [NSNumber numberWithBool:YES],
     kCVPixelBufferCGBitmapContextCompatibilityKey,
     nil];
    CVPixelBufferRef pxbuffer = NULL;
    
    CVReturn status =
    CVPixelBufferCreate(
                        kCFAllocatorDefault, frameSize.width, frameSize.height,
                        kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef)options,
                        &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(
                                                 pxdata, frameSize.width, frameSize.height,
                                                 8, CVPixelBufferGetBytesPerRow(pxbuffer),
                                                 rgbColorSpace,
                                                 (CGBitmapInfo)kCGBitmapByteOrder32Little |
                                                 kCGImageAlphaPremultipliedFirst);
    
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

-(void)passImageToEncoder:(UIImage *)frameImage atTime:(CMTime)time{
    CVPixelBufferRef pixelBuffer = NULL;
    CGImageRef cgImage = CGImageCreateCopy([frameImage CGImage]);
    
    pixelBuffer = [self pixelBufferFromCGImage:cgImage];

    CMSampleBufferRef newSampleBuffer = NULL;
  //  CMSampleTimingInfo timimgInfo = kCMTimingInfoInvalid;
    
    //timing

    CMSampleTimingInfo* pInfo = malloc(sizeof(CMSampleTimingInfo));
   // pInfo[0].decodeTimeStamp = time;// kCMTimingInfoInvalid;
    pInfo[0].presentationTimeStamp = time;
    
    
    CMVideoFormatDescriptionRef videoInfo = NULL;
    CMVideoFormatDescriptionCreateForImageBuffer(NULL, pixelBuffer, &videoInfo);
    CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault,
                                           pixelBuffer,
                                           true,
                                           NULL,
                                           NULL,
                                           videoInfo,
                                           pInfo,//&timimgInfo
                                           &newSampleBuffer);
        [_encoder encodeFrame:newSampleBuffer];
        
        
    //clean up

    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    CVPixelBufferRelease(pixelBuffer);
    CMSampleBufferInvalidate(newSampleBuffer);
    CFRelease(newSampleBuffer);
    newSampleBuffer = NULL;
    pixelBuffer = NULL;
    CGImageRelease(cgImage);

}


@end
