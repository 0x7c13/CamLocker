//
//  CLImageMarker.m
//  CamLocker
//
//  Created by FlyinGeek on 3/18/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "CLImageMarker.h"

@implementation CLImageMarker

- (instancetype)initWithMarkerImage:(UIImage *)markerImage hiddenImages:(NSArray *)hiddenImages
{
    if (self = [super initWithMarkerImage:markerImage]) {
        _hiddenImages = hiddenImages;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_hiddenImages forKey:@"hiddenImages"];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        _hiddenImages = [decoder decodeObjectForKey:@"hiddenImages"];
    }
    return self;
}

@end
