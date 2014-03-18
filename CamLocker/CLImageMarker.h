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

@property (nonatomic, copy, readonly) NSArray *hiddenImages;

- (instancetype)initWithMarkerImage:(UIImage *)markerImage
                       hiddenImages:(NSArray *)hiddenImages;

@end
