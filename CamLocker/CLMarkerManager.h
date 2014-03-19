//
//  CLMarkerManager.h
//  CamLocker
//
//  Created by FlyinGeek on 3/18/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

@class CLMarker;

#import <Foundation/Foundation.h>

@interface CLMarkerManager : NSObject

@property (nonatomic, readonly) NSMutableArray *markers;
@property (nonatomic) UIImage *tempMarkerImage;

+ (instancetype)sharedManager;

- (instancetype) init __attribute__((unavailable("init not available")));

- (CLMarker *)markerByCosName:(NSString *)cosName;

- (void)addTextMarkerWithMarkerImage:(UIImage *)image
                           hiddenText:(NSString *)hiddenText;

- (void)addImageMarkerWithMarkerImage:(UIImage *)image
                          hiddenImages:(NSArray *)hiddenImages;

- (void)deleteMarkerByCosName:(NSString *)cosName;

- (void)deleteAllMarkers;

- (void)activateMarkers;
- (void)deactivateMarkers;

- (NSString *)trackingFilePath;

@end
