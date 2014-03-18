//
//  CLMarkerManager.h
//  CamLocker
//
//  Created by FlyinGeek on 3/18/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLMarkerManager : NSObject

@property (nonatomic, readonly) NSMutableArray *markers;

- (instancetype) init __attribute__((unavailable("init not available")));
+ (instancetype)sharedManager;

- (void)addTextMarkerWithMarkerImage:(UIImage *)image
                           hiddenText:(NSString *)hiddenText;

- (void)addImageMarkerWithMarkerImage:(UIImage *)image
                          hiddenImages:(NSArray *)hiddenImages;

- (void)deleteMarkerByCosName:(NSString *)cosName;

@end
