//
//  CLTextMarker.h
//  CamLocker
//
//  Created by FlyinGeek on 3/18/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "CLMarker.h"
#import <Foundation/Foundation.h>

@interface CLTextMarker : CLMarker <NSCoding>

@property (nonatomic, copy, readonly) NSString *hiddenTextPath;
@property (nonatomic, copy, readonly) NSString *keyOfHiddenText;

- (instancetype) init __attribute__((unavailable("init not available")));
- (instancetype) initWithMarkerImage:(UIImage *)markerImage __attribute__ ((unavailable("initWithMarkerImage: not available")));

- (instancetype)initWithMarkerImage:(UIImage *)markerImage
                         hiddenText:(NSString *)hiddenText;

- (void)decryptHiddenTextWithCompletionBlock:(void (^)(NSString *hiddenText))completion;
- (void)deleteContent;

@end
