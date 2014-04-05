//
//  CLAudioMarker.h
//  CamLocker
//
//  Created by FlyinGeek on 3/31/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "CLMarker.h"
#import <Foundation/Foundation.h>

@interface CLAudioMarker : CLMarker <NSCoding>

@property (nonatomic, copy, readonly) NSString *hiddenAudioPath;

- (instancetype) init __attribute__((unavailable("init not available")));
- (instancetype) initWithMarkerImage:(UIImage *)markerImage __attribute__ ((unavailable("initWithMarkerImage: not available")));

- (instancetype)initWithMarkerImage:(UIImage *)markerImage
                        hiddenAudio:(NSData *)hiddenAudioData;

- (void)decryptHiddenAudioWithCompletionBlock:(void (^)(NSData *hiddenAudioData))completion;
- (void)deleteContent;

@end