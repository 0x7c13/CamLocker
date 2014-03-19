//
//  CLUtilities.m
//  CamLocker
//
//  Created by FlyinGeek on 3/18/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "CLUtilities.h"

@implementation CLUtilities

+ (void)addShadowToUIView: (UIView *)view
{
    [view.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [view.layer setShadowOffset:CGSizeMake(0.0f, 3.0f)];
    [view.layer setShadowOpacity:0.4];
    [view.layer setShadowRadius:4.0];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:view.bounds];
    view.layer.shadowPath = path.CGPath;
}

+ (void)addShadowToUIImageView: (UIImageView *)view
{
    [view.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [view.layer setShadowOffset:CGSizeMake(0.0f, 1.5f)];
    [view.layer setShadowOpacity:0.4];
    [view.layer setShadowRadius:2.0];
    
    // improve performance
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:view.bounds];
    view.layer.shadowPath = path.CGPath;
}

@end
