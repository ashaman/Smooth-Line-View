//
//  CameraServer.h
//  Encoder Demo
//
//  Created by Geraint Davies on 19/02/2013.
//  Copyright (c) 2013 GDCL http://www.gdcl.co.uk/license.htm
//

#import <Foundation/Foundation.h>
#import "AVFoundation/AVMediaFormat.h"
#import "AVFoundation/AVAssetWriter.h"
#import "AVFoundation/AVAssetWriterInput.h"
#import "AVFoundation/AVMediaFormat.h"
#import "AVFoundation/AVVideoSettings.h"

@interface CameraServer : NSObject

+ (CameraServer*) server;
- (void) startup;
- (void) shutdown;
- (NSString*) getURL;

-(void)passImageToEncoder:(UIImage *)frameImage atTime:(CMTime)time;

@end
