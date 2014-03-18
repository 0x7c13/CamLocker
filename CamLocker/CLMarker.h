//
//  CLMarker.h
//  CamLocker
//
//  Created by FlyinGeek on 3/18/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLMarker : NSObject <NSCoding>

@property (nonatomic, copy, readonly) NSString *markerImageFileName;
@property (nonatomic, copy, readonly) NSString *markerImagePath;
@property (nonatomic, copy, readonly) NSString *cosName;

- (instancetype)initWithMarkerImage:(UIImage *)markerImage;

@end
