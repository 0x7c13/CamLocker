//
//  CLTextMarker.m
//  CamLocker
//
//  Created by FlyinGeek on 3/18/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "CLTextMarker.h"

@implementation CLTextMarker

- (instancetype)initWithMarkerImage:(UIImage *)markerImage hiddenText:(NSString *)hiddenText
{
    if (self = [super initWithMarkerImage:markerImage]) {
        _hiddenText = hiddenText;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_hiddenText forKey:@"hiddenText"];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        _hiddenText = [decoder decodeObjectForKey:@"hiddenText"];
    }
    return self;
}

@end
