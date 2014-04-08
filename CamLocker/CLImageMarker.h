//
//  CLImageMarker.h
//  CamLocker
//
//  Created by FlyinGeek on 3/18/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "CLMarker.h"
#import <Foundation/Foundation.h>

@interface CLImageMarker : CLMarker <NSCoding>

@property (nonatomic, copy, readonly) NSMutableArray *hiddenImagePaths;
@property (nonatomic, copy, readonly) NSString *keyOfHiddenImages;

- (instancetype) init __attribute__((unavailable("init not available")));
- (instancetype) initWithMarkerImage:(UIImage *)markerImage __attribute__ ((unavailable("initWithMarkerImage: not available")));

- (instancetype)initWithMarkerImage:(UIImage *)markerImage
                       hiddenImages:(NSArray *)hiddenImages;

- (void)decryptHiddenImagesWithCompletionBlock:(void (^)(NSArray *images))completion;
- (void)deleteContent;

@end
