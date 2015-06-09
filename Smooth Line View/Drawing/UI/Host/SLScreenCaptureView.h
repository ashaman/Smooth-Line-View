//
//  SLScreenCaptureView.h
//  Smooth Line View
//
//  Created by Darya Shabadash on 6/9/15.
//  Copyright (c) 2015 dataart. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol SLScreenCaptureViewDelegate <NSObject>

-(void)recordingFinished:(NSString *)outputPath;

@end

@interface SLScreenCaptureView : UIView {
    //video writing
    AVAssetWriter *videoWriter;
    AVAssetWriterInput *videoWriterInput;
    AVAssetWriterInputPixelBufferAdaptor *avAdaptor;
    
    //recording state
    BOOL _recording;
    NSDate *startedAt;
    void* bitmapData;
    
}

-(BOOL)startRecording;
-(void)stopRecording;

@property(retain) UIImage* currentScreen;
@property(assign) float frameRate;
@property(nonatomic, weak) id<SLScreenCaptureViewDelegate> delegate;

@end
