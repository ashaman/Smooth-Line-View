//
//  SLScreenCaptureView.m
//  Smooth Line View
//
//  Created by Darya Shabadash on 6/9/15.
//  Copyright (c) 2015 dataart. All rights reserved.
//

#import "SLScreenCaptureView.h"
#import <QuartzCore/QuartzCore.h>

@interface SLScreenCaptureView()
@property (strong, nonatomic) CADisplayLink *displayLink;
@property (strong, nonatomic) AVAssetWriter *videoWriter;
@property (strong, nonatomic) AVAssetWriterInput *videoWriterInput;
@property (strong, nonatomic) AVAssetWriterInputPixelBufferAdaptor *avAdaptor;
@property (strong, nonatomic) NSDate *startedAt;
@property (strong, nonatomic) dispatch_queue_t videoHandlingQueue;
@end

@implementation SLScreenCaptureView
{
    //recording state
    BOOL _recording;
}

#pragma mark - Initialization and memory management

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self initialize];
    }
    return self;
}

- (instancetype) init
{
    if ((self = [super init])) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    // self.clearsContextBeforeDrawing = YES;
    self.frameRate = 10.0f; //10 frames per seconds
    self.videoHandlingQueue = dispatch_queue_create("video-handling-queue", DISPATCH_QUEUE_SERIAL);
}

- (void)cleanupWriter
{
    self.avAdaptor = nil;
    self.videoWriterInput = nil;
    self.videoWriter = nil;
    self.startedAt = nil;
}

- (void)dealloc
{
    [self cleanupWriter];
}

#pragma mark - Helpers - video drawing

- (void)writeVideoFrame:(UIImage *)frame atTime:(CMTime)time
{
    if (![self.videoWriterInput isReadyForMoreMediaData]) {
        NSLog(@"WARNING: Not ready for video data");
    } else {
        CVPixelBufferRef pixelBuffer = NULL;
        CGImageRef cgImage = CGImageCreateCopy([frame CGImage]);
        CFDataRef rawImgData = CGDataProviderCopyData(CGImageGetDataProvider(cgImage));
        int status = 0;
        if((status = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, self.avAdaptor.pixelBufferPool, &pixelBuffer)) != 0){
            //could not get a buffer from the pool
            NSLog(@"ERROR: while creating pixel buffer:  status=%d", status);
        } else {
            // set rawImgData data into pixel buffer
            CVPixelBufferLockBaseAddress( pixelBuffer, 0 );
            UInt8 *destinationPixels = CVPixelBufferGetBaseAddress(pixelBuffer);
            //XXX:  will work if the pixel buffer is contiguous and has the same bytesPerRow as the input data
            CFDataGetBytes(rawImgData, CFRangeMake(0, CFDataGetLength(rawImgData)), destinationPixels);
            // append the next frame
            if (![self.avAdaptor appendPixelBuffer:pixelBuffer withPresentationTime:time])
                NSLog(@"Warning:  Unable to write buffer to video");
            //clean up
            CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );
            CVPixelBufferRelease( pixelBuffer );
        }
        CFRelease(rawImgData);
        CGImageRelease(cgImage);
    }
}

#pragma mark - Rendering

- (void)screenUpdated:(CADisplayLink *)timer
{
    if (_recording) {
        typeof(self) __weak this = self;
        UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [self.layer renderInContext:context];
        UIImage *capturedFrame = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        dispatch_async(self.videoHandlingQueue, ^{
            NSTimeInterval millisElapsed = [[NSDate date] timeIntervalSinceDate:this.startedAt] * 1000.0;
            [this writeVideoFrame:capturedFrame atTime:CMTimeMake((int64_t) round(millisElapsed), 1000)];
        });
    }
}

- (NSURL*) tempFileURL {
    NSString* outputPath = [[NSString alloc] initWithFormat:@"%@/%@", NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0], @"output.mp4"];
    NSURL* outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:outputPath]) {
        NSError* error;
        if (![fileManager removeItemAtPath:outputPath error:&error]) {
            NSLog(@"Could not delete old recording file at path:  %@", outputPath);
        }
    }
    return outputURL;
}

- (BOOL)setUpWriter
{
    NSError* error = nil;
    self.videoWriter = [[AVAssetWriter alloc] initWithURL:[self tempFileURL]
                                                 fileType:AVFileTypeMPEG4
                                                    error:&error];
    NSParameterAssert(self.videoWriter);
    
    //Configure video
    NSDictionary* videoCompressionProps = @{
            AVVideoAverageBitRateKey : @(1024.0 * 1024.0),
            AVVideoMaxKeyFrameIntervalKey: @(self.frameRate),
            AVVideoProfileLevelKey: AVVideoProfileLevelH264Main41
    };
    
    NSDictionary* videoSettings = @{
            AVVideoCodecKey : AVVideoCodecH264,
            AVVideoWidthKey : @(self.frame.size.width),
            AVVideoHeightKey : @(self.frame.size.height),
            AVVideoCompressionPropertiesKey : videoCompressionProps
    };
    
    self.videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    
    NSParameterAssert(self.videoWriterInput);
    self.videoWriterInput.expectsMediaDataInRealTime = YES;
    [self.videoWriter addInput:self.videoWriterInput];

    /**
    * Since image is scaled, sizes should be multiplied by the screen's scale
    */
    NSDictionary* bufferAttributes = @{
            (__bridge id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32ARGB),
            (__bridge id)kCVPixelBufferBytesPerRowAlignmentKey: @(4 * self.frame.size.width * self.window.screen.scale),
            (__bridge id)kCVPixelBufferCGImageCompatibilityKey: @(YES),
            (__bridge id)kCVPixelBufferWidthKey: @(self.frame.size.width * self.window.screen.scale),
            (__bridge id)kCVPixelBufferHeightKey: @(self.frame.size.height * self.window.screen.scale)
    };

    self.avAdaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:self.videoWriterInput
                                                                                 sourcePixelBufferAttributes:bufferAttributes];
    //add input
    [self.videoWriter startWriting];
    [self.videoWriter startSessionAtSourceTime:CMTimeMake(0, 1000)];
    return YES;
}

- (void) completeRecordingSession {
    @autoreleasepool {
        [self.videoWriterInput markAsFinished];
    
        // Wait for the video
        int status = self.videoWriter.status;
        while (status == AVAssetWriterStatusUnknown) {
            NSLog(@"Waiting...");
            [NSThread sleepForTimeInterval:0.5f];
            status = self.videoWriter.status;
        }
    
        @synchronized(self) {
            [self.videoWriter finishWritingWithCompletionHandler:^{

                id delegateObj = self.delegate;
                if (self.videoWriter.status != AVAssetWriterStatusFailed && self.videoWriter.status == AVAssetWriterStatusCompleted) {

                    NSString *outputPath = [[NSString alloc] initWithFormat:@"%@/%@", NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0], @"output.mp4"];
                    NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];

                    NSLog(@"Completed recording, file is stored at:  %@", outputURL);
                    if ([delegateObj respondsToSelector:@selector(recordingFinished:)]) {
                        [delegateObj performSelectorOnMainThread:@selector(recordingFinished:) withObject:outputURL waitUntilDone:YES];
                    }
                }
                else {
                    if ([delegateObj respondsToSelector:@selector(recordingFinished:)]) {
                        [delegateObj performSelectorOnMainThread:@selector(recordingFinished:) withObject:nil waitUntilDone:YES];
                    }

                }
                [self cleanupWriter];

            }];
        }
    
    }
}

#pragma mark - Record management

- (BOOL)startRecording
{
    BOOL result = NO;
    @synchronized(self) {
        if (! _recording) {
            result = [self setUpWriter];
            self.startedAt = [NSDate date];
            self.displayLink = [CADisplayLink displayLinkWithTarget:self
                                                           selector:@selector(screenUpdated:)];
            self.displayLink.frameInterval = (NSInteger) (60 / floor(self.frameRate));
            [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
            _recording = YES;
        }
    }
    return result;
}

- (void)stopRecording
{
    @synchronized(self) {
        if (_recording) {
            _recording = NO;
            [self.displayLink invalidate];
            [self completeRecordingSession];
        }
    }
}


@end
