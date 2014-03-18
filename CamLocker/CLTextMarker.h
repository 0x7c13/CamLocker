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

@property (nonatomic, copy, readonly) NSString *hiddenText;

- (instancetype)initWithMarkerImage:(UIImage *)markerImage
                         hiddenText:(NSString *)hiddenText;

@end
